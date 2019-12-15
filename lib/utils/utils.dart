import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keccak/keccak.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localizations.dart';

void copyToClipBoard(BuildContext context, String str) {
  Scaffold.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 2),
    content: Text(AppLocalizations.of(context).clipboard),
  ));
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

String replaceAllTrainlingZero(String data) {
  for (int i = 0; i < 8; i++) {
    data = data.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
  return data;
}

String replaceAllTrainlingZeroERC(String data) {
  for (int i = 0; i < 16; i++) {
    data = data.replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');
  }
  return data;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

void showAddressDialog(BuildContext mContext, String address, Coin coin) {
  dialogBloc.dialog = showDialog<dynamic>(
    context: mContext,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        contentPadding: const EdgeInsets.all(16),
        titlePadding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(6.0)),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    copyToClipBoard(mContext, address);
                  },
                  child: QrImage(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    data: address,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  copyToClipBoard(mContext, address);
                },
                child: Container(
                  child: Center(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                    child: AutoSizeText(
                      address,
                      style: Theme.of(context).textTheme.body1,
                      maxLines: 2,
                    ),
                  )),
                ),
              ),
              Row(
                children: <Widget>[
                  coin.abbr == 'RICK' || coin.abbr == 'MORTY'
                      ? RaisedButton(
                          child: Text(AppLocalizations.of(context).faucetName,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context).primaryColor)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          elevation: 0,
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: address));
                            launchURL(
                                'https://www.atomicexplorer.com/#/faucet/${coin.abbr.toLowerCase()}');
                          },
                        )
                      : Expanded(
                          child: Container(),
                        ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context).close.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ).then((dynamic data) {
    dialogBloc.dialog = null;
  });
}

void showMessage(BuildContext mContext, String error) {
  Scaffold.of(mContext).showSnackBar(SnackBar(
    duration: const Duration(seconds: 3),
    backgroundColor: Theme.of(mContext).primaryColor,
    content: Text(
      error,
      style: Theme.of(mContext).textTheme.body1,
    ),
  ));
}

void showErrorMessage(BuildContext mContext, String error) {
  Scaffold.of(mContext).showSnackBar(SnackBar(
    duration: const Duration(seconds: 2),
    backgroundColor: Theme.of(mContext).errorColor,
    content: Text(
      error,
      style: Theme.of(mContext).textTheme.body1,
    ),
  ));
}

Future<bool> checkBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  bool canCheckBiometrics = false;
  try {
    canCheckBiometrics = await auth.canCheckBiometrics;
    Log.println('utils:204', canCheckBiometrics);
  } on PlatformException catch (e) {
    Log.println('utils:206', e);
  }
  return canCheckBiometrics;
}

Future<bool> authenticateBiometrics(
    BuildContext context, PinStatus pinStatus) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('switch_pin_biometric')) {
    final LocalAuthentication localAuth = LocalAuthentication();
    bool didAuthenticate = false;

    try {
      didAuthenticate = await localAuth.authenticateWithBiometrics(
          stickyAuth: true,
          localizedReason: AppLocalizations.of(context).lockScreenAuth);
    } on PlatformException catch (e) {
      print(e.message);
    }

    if (didAuthenticate) {
      if (pinStatus == PinStatus.DISABLED_PIN) {
        SharedPreferences.getInstance().then((SharedPreferences data) {
          data.setBool('switch_pin', false);
        });
        Navigator.pop(context);
      }
      authBloc.showPin(false);
      if (pinStatus == PinStatus.NORMAL_PIN &&
          !MarketMakerService().ismm2Running) {
        await authBloc.login(await EncryptionTool().read('passphrase'), null);
      }
    }
    return didAuthenticate;
  } else {
    return false;
  }
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
                  style: Theme.of(context).textTheme.body1,
                  children: <TextSpan>[
                TextSpan(text: AppLocalizations.of(context).deleteSpan1),
                TextSpan(
                    text: '${coin.name}',
                    style: Theme.of(context)
                        .textTheme
                        .body1
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
                await coinsBloc.removeCoin(coin).then((dynamic value) {
                  if (value is ErrorDisableCoinActiveSwap) {
                    showMessage(mContext, value.error);
                  }
                  if (value is DisableCoin) {
                    if (value.result.cancelledOrders.isNotEmpty) {
                      showMessage(
                          mContext,
                          AppLocalizations.of(context)
                              .orderCancel(value.result.coin));
                    }
                  }
                });
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
  Log.println('utils:306', url);
  if (await canLaunch(url)) {
    mainBloc.isUrlLaucherIsOpen = true;
    await launch(url);
    mainBloc.isUrlLaucherIsOpen = false;
  } else {
    throw 'Could not launch $url';
  }
}
