import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keccak/keccak.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/services/lock_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/cex_fiat_preview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rational/rational.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../localizations.dart';

void copyToClipBoard(BuildContext context, String str) {
  ScaffoldState scaffold;
  try {
    scaffold = Scaffold.of(context);
  } catch (_) {}

  if (scaffold != null) {
    scaffold.showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(AppLocalizations.of(context).clipboard),
    ));
  }
  Clipboard.setData(ClipboardData(text: str));
}

bool isAddress(String address) {
  if (RegExp('!/^(0x)?[0-9a-f]{40}\$/i').hasMatch(address)) {
    return false;
  } else if (RegExp('/^(0x)?[0-9a-f]{40}\$/').hasMatch(address) ||
      RegExp('/^(0x)?[0-9A-F]{40}\$/').hasMatch(address)) {
    return true;
  } else {
    return isChecksumAddress(address);
  }
}

bool isChecksumAddress(String address) {
  // Check each case
  address = address.replaceFirst('0x', '');
  final Uint8List inputData =
      Uint8List.fromList(address.toLowerCase().codeUnits);
  final Uint8List addressHash = keccak(inputData);
  final String output = hex.encode(addressHash);
  for (int i = 0; i < 40; i++) {
    // the nth letter should be uppercase if the nth digit of casemap is 1
    // int.parse(addressHash[i].toString(), radix: 16)
    if ((int.parse(output[i].toString(), radix: 16) > 7 &&
            address[i].toUpperCase() != address[i]) ||
        (int.parse(output[i].toString(), radix: 16) <= 7 &&
            address[i].toLowerCase() != address[i])) {
      return false;
    }
  }
  return true;
}

/// Convers a null, a string or a double into a Decimal.
Decimal deci(dynamic dv) {
  if (dv == null) return Decimal.fromInt(0);
  if (dv is int) return Decimal.fromInt(dv);
  if (dv is String)
    return dv.isEmpty
        ? Decimal.fromInt(0)
        : Decimal.parse(dv.replaceAll(',', '.'));
  if (dv is double) return Decimal.parse(dv.toStringAsFixed(16));
  if (dv is Rational) return Decimal.parse(dv.toDecimalString());
  if (dv is Decimal) return dv;
  throw Exception('Neither string nor double: $dv');
}

Rational fract2rat(Map<String, dynamic> fract) {
  try {
    final rat = Rational.fromInt(
      int.parse(fract['numer']),
      int.parse(fract['denom']),
    );
    return rat;
  } catch (_) {
    return null;
  }
}

/// Precise but readable representation (no trailing zeroes).
String deci2s(Decimal dv, [int fractions = 8]) {
  if (dv.isInteger) return dv.toStringAsFixed(0); // Fast path.
  String sv = dv.toStringAsFixed(fractions);
  final dot = sv.indexOf('.');
  if (dot == -1) return sv;
  sv = sv.replaceFirst(RegExp(r'0+$'), '', dot);
  if (sv.length - 1 == dot) sv = sv.substring(0, dot);
  return sv;
}

/// Decode a small unsigned base62 number
int base62udec(String bv) {
  int uv = 0;
  for (int ch in bv.codeUnits) {
    final int v = ch >= 48 && ch <= 57
        ? ch - 48
        : ch >= 65 && ch <= 90
            ? ch - 65 + 10
            : ch >= 97 && ch <= 122
                ? ch - 97 + 36
                : throw Exception('!base62: $ch');
    uv = uv * 62 + v;
  }
  return uv;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

void showMessage(BuildContext mContext, String error) {
  Scaffold.of(mContext).showSnackBar(SnackBar(
    duration: const Duration(seconds: 3),
    backgroundColor: Theme.of(mContext).primaryColor,
    content: Text(
      error,
      style: Theme.of(mContext).textTheme.bodyText2,
    ),
  ));
}

void showErrorMessage(BuildContext mContext, String error) {
  Scaffold.of(mContext).showSnackBar(SnackBar(
    duration: const Duration(seconds: 2),
    backgroundColor: Theme.of(mContext).errorColor,
    content: Text(
      error,
      style: Theme.of(mContext).textTheme.bodyText2,
    ),
  ));
}

bool _canCheckBiometrics;

Future<bool> get canCheckBiometrics async {
  final LocalAuthentication auth = LocalAuthentication();
  if (_canCheckBiometrics == null) {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
      Log.println('utils:276', 'canCheckBiometrics: $_canCheckBiometrics');
    } on PlatformException catch (ex) {
      Log.println('utils:278', 'canCheckBiometrics exception: $ex');
    }
  }
  return _canCheckBiometrics;
}

/// This function is used to bring up the biometric authentication prompt.
/// It is invoked from the widget tree builders, such as LockScreen's.
/// Widget tree builders would often invoke this function several times in a row
/// (due to poor BLoC optimization perhaps?), leading to a flickering prompt on iOS.
/// We use `_activeAuthenticateWithBiometrics` in order to ignore such double-invocations.
Future<bool> authenticateBiometrics(
    BuildContext context, PinStatus pinStatus) async {
  if (mainBloc.isInBackground) {
    StreamSubscription listener;
    listener = mainBloc.outIsInBackground.listen((bool isInBackground) {
      listener.cancel();
      if (!isInBackground) authenticateBiometrics(context, pinStatus);
    });
    return false;
  }

  Log.println('utils:291', 'authenticateBiometrics');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('switch_pin_biometric')) {
    final LocalAuthentication localAuth = LocalAuthentication();
    bool didAuthenticate = false;

    // Avoid flicker by ignoring duplicate invocations
    // while an existing authenticateWithBiometrics is still active.
    // AG: The duplicate invocation might also crash the app (observed on 2020-02-07, Android, debug).
    if (lockService.inBiometrics) return false;
    final int lockCookie = lockService.enteringBiometrics();

    try {
      didAuthenticate = await localAuth.authenticateWithBiometrics(
          stickyAuth: true,
          localizedReason: AppLocalizations.of(context).lockScreenAuth);
    } on PlatformException catch (e) {
      // AG, 2020-02-07, observed a race:
      // "ex: Can not perform this action after onSaveInstanceState" is thrown and unlocks `_activeAuthenticateWithBiometrics`;
      // a second `authenticateWithBiometrics` then leads to "ex: Authentication in progress" and crash.
      // Rewriting the biometrics support (cf. #668) might be one way to fix that.
      Log.println('utils:312', 'authenticateWithBiometrics ex: ' + e.message);
    }

    lockService.biometricsReturned(lockCookie);

    if (didAuthenticate) {
      if (pinStatus == PinStatus.DISABLED_PIN) {
        SharedPreferences.getInstance().then((SharedPreferences data) {
          data.setBool('switch_pin', false);
        });
        Navigator.pop(context);
      }
      authBloc.showLock = false;
      if (pinStatus == PinStatus.NORMAL_PIN && !mmSe.running) {
        await authBloc.login(await EncryptionTool().read('passphrase'), null);
      }
    }
    return didAuthenticate;
  } else {
    return false;
  }
}

Future<void> showCantRemoveDefaultCoin(BuildContext mContext, Coin coin) async {
  return dialogBloc.dialog = showDialog<void>(
      context: mContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).cantDeleteDefaultCoinTitle +
              coin.abbr),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                    text: '${coin.name}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        AppLocalizations.of(context).cantDeleteDefaultCoinSpan),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context)
                    .cantDeleteDefaultCoinOk
                    .toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }).then((_) {
    dialogBloc.dialog = null;
  });
}

Future<void> showConfirmationRemoveCoin(
    BuildContext mContext, Coin coin) async {
  return dialogBloc.dialog = showDialog<void>(
      context: mContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteConfirm),
          content: RichText(
              text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2,
                  children: <TextSpan>[
                TextSpan(text: AppLocalizations.of(context).deleteSpan1),
                TextSpan(
                    text: '${coin.name}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.bold)),
                TextSpan(text: AppLocalizations.of(context).deleteSpan2),
              ])),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context).cancel.toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              color: Theme.of(context).errorColor,
              child: Text(
                AppLocalizations.of(context).confirm.toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () async {
                try {
                  await coinsBloc.removeCoin(coin);
                } on ErrorString catch (ex) {
                  showMessage(mContext, ex.error);
                }
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }).then((_) {
    dialogBloc.dialog = null;
  });
}

Future<void> launchURL(String url) async {
  Log.println('utils:388', url);
  if (await canLaunch(url)) {
    mainBloc.isUrlLaucherIsOpen = true;
    await launch(url);
    mainBloc.isUrlLaucherIsOpen = false;
  } else {
    throw 'Could not launch $url';
  }
}

Duration durationSum(List<Duration> list) {
  int ms = 0;
  for (int i = 0; i < list.length; i++) {
    ms += list[i]?.inMilliseconds ?? 0;
  }
  return Duration(milliseconds: ms);
}

/// Returns String of milliseconds ('555ms') if [duration] < 1s,
/// seconds ('55s') if < 1min,
/// minutes and seconds ('5m 5s') if < 1 hour,
/// and hours, minutes, and seconds ('25h 25m 25s') if > 1 hour
String durationFormat(Duration duration) {
  if (duration == null) return '-';

  final int hh = duration.inHours;
  final int mm = duration.inMinutes;
  final int ss = duration.inSeconds;
  final int ms = duration.inMilliseconds;

  if (ms < 1000) return '$ms' + AppLocalizations().milliseconds;

  String formatted = '';
  if (ss.remainder(60) > 0) {
    formatted = '${ss.remainder(60)}' + AppLocalizations().seconds;
  }
  if (mm > 0) {
    formatted =
        '${mm.remainder(60)}' + AppLocalizations().minutes + ' ' + formatted;
  }
  if (hh > 0) {
    formatted = '$hh' + AppLocalizations().hours + ' ' + formatted;
  }

  return formatted;
}

double mean(List<double> values) {
  if (values == null || values.isEmpty) return null;
  final double sum = values.reduce((sum, current) => sum + current);
  return sum / values.length;
}

double deviation(List<double> values) {
  final double average = mean(values);
  final List<double> squares = [];
  for (var i = 0; i < values.length; i++) {
    squares.add(pow(values[i] - average, 2));
  }
  final averageSquares = mean(squares);

  return sqrt(averageSquares);
}

Directory _applicationDocumentsDirectory;

void setDebugDocumentsDirectory(Directory directory) {
  if (!isInDebugMode) throw Exception('Not in debug');
  _applicationDocumentsDirectory = directory;
}

Future<Directory> get applicationDocumentsDirectory async {
  _applicationDocumentsDirectory ??= await getApplicationDocumentsDirectory();
  return _applicationDocumentsDirectory;
}

/// Cached synchronous access to the application directory.
/// Returns `null` if the application directory is not known yet.
Directory get applicationDocumentsDirectorySync =>
    _applicationDocumentsDirectory;

Future<void> sleepMs(int ms) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}

Future<void> pauseUntil(Function cond, {int maxMs}) async {
  maxMs ??= 10000;
  final int start = DateTime.now().millisecondsSinceEpoch;

  while ((!await cond()) &&
      DateTime.now().millisecondsSinceEpoch - start < maxMs) {
    await Future<dynamic>.delayed(Duration(milliseconds: 100));
  }
}

/// Decode a lowercase hex into an integer.
///
/// There's actually more than one way to decode a hex
/// (e.g. big-endian versus little-endian)
/// and most libraries have the decoding underspecified
/// hence the explicit decoding might be more easily reproducible and transparent.
int hex2int(String sv) {
  int iv = 0;
  for (int ix = 0; ix < sv.length; ++ix) {
    final ch = sv.codeUnitAt(ix);
    int cv;
    if (ch >= 0x30 && ch <= 0x39) {
      cv = ch - 0x30; // 0-9, http://ascii-table.com/
    } else if (ch >= 0x61 && ch <= 0x66) {
      cv = ch - 0x61 + 10; // a-f
    } else {
      throw Exception('Not a hex: $ch in $sv at $ix');
    }
    iv += cv << (ix * 4);
  }
  return iv;
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

String humanDate(int epoch) {
  DateTime _dateTime;
  try {
    _dateTime = DateTime.fromMillisecondsSinceEpoch(epoch);
  } catch (e) {
    Log('utils:508', 'humanDate] $e');
  }

  if (_dateTime == null) return null;

  final DateTime _now = DateTime.now();
  final bool _isThisYear = _dateTime.year == _now.year;
  final bool _isThisMonth = _isThisYear && _dateTime.month == _now.month;
  final bool _isToday = _isThisMonth && _dateTime.day == _now.day;

  if (_isToday) return DateFormat('HH:mm').format(_dateTime);
  if (_isThisYear) return DateFormat('MMMM d, HH:mm').format(_dateTime);
  return DateFormat('MMMM d y, HH:mm').format(_dateTime);
}

String formatPrice(dynamic value, [int digits = 6, int fraction = 2]) {
  if (value == null) return null;

  if (value is String) value = double.parse(value);
  final String rounded = value.toStringAsFixed(fraction);
  if (rounded.length >= digits + 1) {
    return rounded;
  } else if (value > 0 && value <= 0.00000001) {
    return '0.00000001';
  } else if (value > 0 && value <= 0.000001) {
    return value.toStringAsFixed(8);
  } else {
    return value.toStringAsPrecision(digits);
  }
}

String cutTrailingZeros(String str) {
  if (str == null) return null;

  String loop(String input) {
    if (input.length == 1) return input;
    if (!(input.contains('.') || input.contains(','))) return input;

    if (input[input.length - 1] == '0' ||
        input[input.length - 1] == '.' ||
        input[input.length - 1] == ',') {
      input = input.substring(0, input.length - 1);
      return loop(input);
    } else {
      return input;
    }
  }

  return loop(str);
}

Widget truncateMiddle(String string, {TextStyle style}) {
  if (string.length < 6)
    return Text(
      string,
      style: style,
    );

  return Row(
    children: <Widget>[
      Flexible(
        child: Text(
          string.substring(0, string.length - 5),
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
      Text(
        string.substring(string.length - 5),
        style: style,
      )
    ],
  );
}

bool isInfinite(dynamic value) {
  if (value == null) return false;
  if (value == 0.0 || value == '0.0' || value == '0') return false;

  if (value is String) value = double.parse(value);
  value = value.abs();

  if (value > double.maxFinite || 1 / value > double.maxFinite) return true;
  if (value < double.minPositive || 1 / value < double.minPositive) return true;

  return false;
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

class PaymentUriInfo {
  PaymentUriInfo({this.scheme, this.abbr, this.address, this.amount});

  factory PaymentUriInfo.fromUri(Uri uri) {
    String address;
    double amount;
    String abbr;

    if (uri.scheme == 'bitcoin') {
      abbr = 'BTC';
      if (uri != null) {
        if (uri.path != null && uri.pathSegments.isNotEmpty)
          address = uri.pathSegments[0];
        if (uri.queryParameters != null) {
          if (uri.queryParameters.containsKey('amount'))
            amount = double.tryParse(uri.queryParameters['amount']);
        }
      }
    } else if (uri.scheme == 'ethereum') {
      abbr = 'ETH';
      if (uri != null) {
        if (uri.path != null && uri.pathSegments.isNotEmpty)
          address = uri.pathSegments[0];
        if (uri.queryParameters != null) {
          if (uri.queryParameters.containsKey('value'))
            amount = double.tryParse(uri.queryParameters['value']);
          if (amount != null) amount = amount * pow(10, -18);
        }
      }
    } else {
      return null;
    }

    return PaymentUriInfo(
      scheme: uri.scheme,
      abbr: abbr,
      address: address,
      amount: amount?.toString(),
    );
  }

  final String scheme;
  final String abbr;
  final String address;
  final String amount;
}

void showUriDetailsDialog(
    BuildContext context, PaymentUriInfo uriInfo, Function callbackIfAccepted) {
  dialogBloc.dialog = showDialog<void>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          AppLocalizations.of(context).paymentUriDetailsTitle,
          style: TextStyle(fontSize: 24),
        ),
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              Text(
                cutTrailingZeros(formatPrice(uriInfo.amount)),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundImage:
                        AssetImage('assets/${uriInfo.abbr.toLowerCase()}.png'),
                  ),
                  SizedBox(width: 6),
                  Text(
                    uriInfo.abbr,
                    style: TextStyle(fontSize: 26),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CexFiatPreview(
                amount: uriInfo.amount,
                coinAbbr: uriInfo.abbr,
                textStyle: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).paymentUriDetailsAddressSpan + ':',
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            uriInfo.address,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).paymentUriDetailsDeny),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                child:
                    Text(AppLocalizations.of(context).paymentUriDetailsAccept),
                onPressed: () {
                  Navigator.of(context).pop();
                  callbackIfAccepted();
                },
              )
            ],
          ),
        ],
      );
    },
  ).then((dynamic _) => dialogBloc.dialog = null);
}
