import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/camo_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/screens/authentification/logout_confirmation.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinPage extends StatefulWidget {
  const PinPage({
    Key key,
    this.firstCreationPin,
    this.title,
    this.subTitle,
    this.pinStatus,
    this.isFromChangingPin,
    this.password,
    this.onSuccess,
    this.code,
  }) : super(key: key);

  final bool firstCreationPin;
  @required
  final String title;
  @required
  final String subTitle;
  @required
  final PinStatus pinStatus;
  final String code;
  final bool isFromChangingPin;
  final String password;
  final VoidCallback onSuccess;

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _error = '';
  bool isLoading = false;
  String _correctPin;
  String _camoPin;

  @override
  void initState() {
    _initCorrectPin(widget.pinStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pinStatus == PinStatus.NORMAL_PIN) {
        dialogBloc.closeDialog(context);
      }
    });
    super.initState();
  }

  Future<void> setNormalPin() async {
    final String normalPin = await EncryptionTool().read('pin');
    final String camoPin = await EncryptionTool().read('camoPin');
    setState(() {
      _correctPin = normalPin;
      _camoPin = camoPin;
    });
  }

  Future<void> _initCorrectPin(PinStatus pinStatus) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (pinStatus == PinStatus.CREATE_PIN) {
      setState(() {
        _correctPin = null;
      });
    } else if (pinStatus == PinStatus.CONFIRM_PIN) {
      authBloc.showLock = false;
      setState(() {
        _correctPin = prefs.getString('pin_create');
      });
    } else if (pinStatus == PinStatus.CREATE_CAMO_PIN) {
      setState(() {
        _correctPin = null;
      });
    } else if (pinStatus == PinStatus.CONFIRM_CAMO_PIN) {
      authBloc.showLock = false;
      setState(() {
        _correctPin = prefs.getString('camo_pin_create');
      });
    } else {
      await setNormalPin();
    }
  }

  Future<void> _onCodeSuccess(PinStatus pinStatus, String code) async {
    switch (pinStatus) {
      case PinStatus.CREATE_PIN:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isPinIsCreated', true);
        break;

      case PinStatus.CONFIRM_PIN:
        final Wallet wallet = await Db.getCurrentWallet();
        setState(() {
          isLoading = true;
        });
        if (wallet != null) {
          await EncryptionTool()
              .writeData(
                  KeyEncryption.PIN, wallet, widget.password, code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('pin', code.toString());
        authBloc.showLock = false;
        authBloc.updateStatusPin(PinStatus.NORMAL_PIN);
        if (!widget.isFromChangingPin) {
          if (!mmSe.running) {
            await authBloc.login(
                await EncryptionTool().read('passphrase'), widget.password);
          }
        } else {
          Navigator.pop(context);
        }
        Navigator.pop(context);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isPinIsCreated', false);

        setState(() {
          isLoading = false;
        });
        break;

      case PinStatus.CREATE_CAMO_PIN:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isCamoPinCreated', true);
        break;

      case PinStatus.CONFIRM_CAMO_PIN:
        await EncryptionTool().write('camoPin', code.toString());

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isCamoPinCreated', false);

        camoBloc.shouldWarnBadCamoPin = true;
        Navigator.popUntil(context, ModalRoute.withName('/camoSetup'));
        break;

      case PinStatus.NORMAL_PIN:
        authBloc.showLock = false;
        if (!mmSe.running) {
          await authBloc.login(await EncryptionTool().read('passphrase'), null);
        }
        if (widget.onSuccess != null) {
          widget.onSuccess();
        }

        break;

      case PinStatus.DISABLED_PIN:
        SharedPreferences.getInstance().then((SharedPreferences data) {
          data.setBool('switch_pin', false);
        });
        Navigator.pop(context);
        break;
      case PinStatus.DISABLED_PIN_BIOMETRIC:
        SharedPreferences.getInstance().then((SharedPreferences data) {
          data.setBool('switch_pin_biometric', false);
        });
        Navigator.pop(context);
        break;

      case PinStatus.CHANGE_PIN:
        Navigator.pushReplacement<dynamic, dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => PinPage(
                      title: AppLocalizations.of(context).createPin,
                      subTitle: AppLocalizations.of(context).enterNewPinCode,
                      pinStatus: PinStatus.CREATE_PIN,
                      password: widget.password,
                      isFromChangingPin: true,
                    )));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !isLoading
          ? AppBarStatus(
              pinStatus: widget.pinStatus,
              title: widget.title,
              context: context,
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: !isLoading
          ? PinCode(
              title: Text(
                widget.subTitle,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              subTitle: const Text(
                '',
              ),
              obscurePin: true,
              error: _error,
              errorDelayProgressColor:
                  settingsBloc.isLightTheme ? Colors.black : Colors.white,
              keyTextStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline6.color,
                  fontSize: Theme.of(context).textTheme.headline6.fontSize),
              errorDelaySeconds:
                  widget.pinStatus == PinStatus.NORMAL_PIN ? 5 : null,
              codeLength: 6,
              correctPin: _correctPin,
              onCodeFail: (dynamic code) async {
                if (widget.pinStatus == PinStatus.CREATE_PIN) {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isPinIsCreated', true);
                  await prefs.setString('pin_create', code);
                  final MaterialPageRoute<dynamic> materialPage =
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => PinPage(
                                title: AppLocalizations.of(context).confirmPin,
                                subTitle:
                                    AppLocalizations.of(context).confirmPin,
                                code: code,
                                pinStatus: PinStatus.CONFIRM_PIN,
                                password: widget.password,
                                isFromChangingPin: widget.isFromChangingPin,
                              ));

                  if (widget.firstCreationPin != null &&
                      widget.firstCreationPin) {
                    Navigator.push<dynamic>(context, materialPage);
                  } else {
                    Navigator.pushReplacement<dynamic, dynamic>(
                        context, materialPage);
                  }
                } else if (widget.pinStatus == PinStatus.CREATE_CAMO_PIN) {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isCamoPinCreated', true);
                  await prefs.setString('camo_pin_create', code);
                  final MaterialPageRoute<dynamic> materialPage =
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => PinPage(
                                title: 'Camouflage PIN Setup',
                                subTitle: 'Confirm Camouflage PIN',
                                code: code,
                                pinStatus: PinStatus.CONFIRM_CAMO_PIN,
                                password: widget.password,
                              ));

                  Navigator.pushReplacement<dynamic, dynamic>(
                      context, materialPage);
                } else {
                  final bool shouldEnterCamoMode =
                      widget.pinStatus == PinStatus.NORMAL_PIN &&
                          camoBloc.isCamoEnabled &&
                          _camoPin != null &&
                          code == _camoPin;

                  if (shouldEnterCamoMode) {
                    if (!camoBloc.isCamoActive) {
                      coinsBloc.resetCoinBalance();
                      camoBloc.isCamoActive = true;
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    }

                    _onCodeSuccess(widget.pinStatus, code);
                  } else {
                    _errorPin();
                    camoBloc.isCamoActive = false;
                  }
                }
              },
              onCodeSuccess: (dynamic code) {
                if (widget.pinStatus == PinStatus.NORMAL_PIN &&
                    camoBloc.isCamoActive) {
                  coinsBloc.resetCoinBalance();
                  camoBloc.isCamoActive = false;
                }
                _onCodeSuccess(widget.pinStatus, code);
              },
            )
          : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            color: Theme.of(context).errorColor,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(AppLocalizations.of(context).configureWallet)
        ],
      ),
    );
  }

  void _errorPin() {
    setState(() {
      _error = AppLocalizations.of(context).errorTryAgain;
    });
  }
}

class AppBarStatus extends StatelessWidget with PreferredSizeWidget {
  AppBarStatus({
    Key key,
    @required this.pinStatus,
    @required this.context,
    @required this.title,
  }) : super(key: key);

  final PinStatus pinStatus;
  final BuildContext context;
  final String title;

  @override
  Widget build(BuildContext context) {
    switch (pinStatus) {
      case PinStatus.CREATE_PIN:
      case PinStatus.CONFIRM_PIN:
      case PinStatus.CREATE_CAMO_PIN:
      case PinStatus.CONFIRM_CAMO_PIN:
        return AppBar(
          centerTitle: true,
          title: Text(title),
        );
        break;
      default:
        return AppBar(
          centerTitle: true,
          automaticallyImplyLeading: pinStatus != PinStatus.NORMAL_PIN,
          actions: <Widget>[
            IconButton(
              key: Key('settings-pin-logout'),
              onPressed: () => showLogoutConfirmation(context),
              color: Theme.of(context).errorColor,
              icon: Icon(
                Icons.exit_to_app,
              ),
            ),
          ],
          title: Text(title),
          elevation: 0,
        );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
