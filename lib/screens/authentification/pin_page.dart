import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/authenticate_bloc.dart';
import 'package:komodo_dex/blocs/camo_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/model/wallet_security_settings_provider.dart';
import 'package:komodo_dex/screens/authentification/app_bar_status.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinPage extends StatefulWidget {
  const PinPage({
    Key key,
    this.title,
    this.subTitle,
    this.pinStatus,
    this.isFromChangingPin = false,
    this.password,
    this.onSuccess,
    this.code,
  }) : super(key: key);

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
  bool _isLoading = false;
  String _correctPin;
  String _camoPin;

  @override
  void initState() {
    _initCorrectPin();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pinStatus == PinStatus.NORMAL_PIN) {
        dialogBloc.closeDialog(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !_isLoading
          ? AppBarStatus(
              pinStatus: widget.pinStatus,
              title: widget.title,
              context: context,
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: !_isLoading
          ? PinCode(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
              keyTextStyle: Theme.of(context).textTheme.headline6,
              errorDelaySeconds:
                  widget.pinStatus == PinStatus.NORMAL_PIN ? 5 : null,
              codeLength: 6,
              correctPin: _correctPin,
              onCodeFail: _onCodeFail,
              onCodeSuccess: _onCodeSuccess,
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

  void _onErrorPinEntered() {
    camoBloc.isCamoActive = false;

    setState(() {
      _error = AppLocalizations.of(context).errorTryAgain;
    });
  }

  Future<void> _setNormalPin() async {
    final EncryptionTool encryptionTool = EncryptionTool();
    await pauseUntil(() async => await encryptionTool.read('pin') != null);

    final String normalPin = await encryptionTool.read('pin');
    final String camoPin = await encryptionTool.read('camoPin');
    setState(() {
      _correctPin = normalPin;
      _camoPin = camoPin;
    });
  }

  Future<void> _initCorrectPin() async {
    final PinStatus pinStatus = widget.pinStatus;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (pinStatus == PinStatus.CREATE_PIN ||
        pinStatus == PinStatus.CHANGE_PIN) {
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
      await _setNormalPin();
    }
  }

  Future<void> _onCodeSuccess(String code) async {
    final walletSecuritySettingsProvider =
        context.read<WalletSecuritySettingsProvider>();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.pinStatus) {
      case PinStatus.NORMAL_PIN:
        if (camoBloc.isCamoActive) {
          coinsBloc.resetCoinBalance();
          camoBloc.isCamoActive = false;
        }

        authBloc.showLock = false;
        if (!mmSe.running) {
          await authBloc.login(await EncryptionTool().read('passphrase'), null);
        }
        if (widget.onSuccess != null) {
          widget.onSuccess();
        }
        break;

      case PinStatus.CHANGE_PIN:
        break;
      case PinStatus.CREATE_PIN:
        await prefs.setBool('is_pin_creation_in_progress', true);
        break;
      case PinStatus.CREATE_CAMO_PIN:
        await prefs.setBool('is_camo_pin_creation_in_progress', true);
        break;

      case PinStatus.CONFIRM_PIN:
        final Wallet wallet = await Db.getCurrentWallet();
        setState(() {
          _isLoading = true;
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

        await prefs.remove('pin_create');
        await prefs.remove('is_pin_creation_in_progress');
        if (mounted)
          setState(() {
            _isLoading = false;
          });
        break;

      case PinStatus.CONFIRM_CAMO_PIN:
        final Wallet wallet = await Db.getCurrentWallet();
        if (wallet != null) {
          await EncryptionTool()
              .writeData(KeyEncryption.CAMOPIN, wallet, widget.password,
                  code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('camoPin', code.toString());

        await prefs.remove('camo_pin_create');
        await prefs.remove('is_camo_pin_creation_in_progress');

        camoBloc.shouldWarnBadCamoPin = true;
        Navigator.popUntil(context, ModalRoute.withName('/camoSetup'));
        break;

      case PinStatus.DISABLED_PIN:
        walletSecuritySettingsProvider.activatePinProtection = true;
        Navigator.pop(context);
        break;
      case PinStatus.DISABLED_PIN_BIOMETRIC:
        walletSecuritySettingsProvider.activateBioProtection = false;
        Navigator.pop(context);
        break;
    }
  }

  Future<void> _onCodeFail(dynamic code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.pinStatus) {
      case (PinStatus.CREATE_PIN):
        await prefs.setBool('is_pin_creation_in_progress', true);
        await prefs.setString('pin_create', code);
        final MaterialPageRoute<dynamic> materialPage =
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => PinPage(
                      title: AppLocalizations.of(context).confirmPin,
                      subTitle: AppLocalizations.of(context).confirmPin,
                      code: code,
                      pinStatus: PinStatus.CONFIRM_PIN,
                      password: widget.password,
                    ));

        Navigator.push<dynamic>(context, materialPage);
        break;

      case (PinStatus.CHANGE_PIN):
        await prefs.setString('pin_create', code);
        final MaterialPageRoute<dynamic> materialPage =
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => PinPage(
                      title: AppLocalizations.of(context).confirmPin,
                      subTitle: AppLocalizations.of(context).confirmPin,
                      code: code,
                      pinStatus: PinStatus.CONFIRM_PIN,
                      password: widget.password,
                      isFromChangingPin: true,
                    ));

        Navigator.pushReplacement<dynamic, dynamic>(context, materialPage);
        break;

      case (PinStatus.CREATE_CAMO_PIN):
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_camo_pin_creation_in_progress', true);
        await prefs.setString('camo_pin_create', code);
        final MaterialPageRoute<dynamic> materialPage =
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => PinPage(
                      title: AppLocalizations.of(context).camouflageSetup,
                      subTitle:
                          AppLocalizations.of(context).confirmCamouflageSetup,
                      code: code,
                      pinStatus: PinStatus.CONFIRM_CAMO_PIN,
                      password: widget.password,
                    ));

        Navigator.pushReplacement<dynamic, dynamic>(context, materialPage);
        break;

      default:
        if (_isCamoPinCode(code)) {
          _onCamoPinEntered(code);
        } else {
          _onErrorPinEntered();
        }
        break;
    }
  }

  bool _isCamoPinCode(dynamic code) {
    return widget.pinStatus == PinStatus.NORMAL_PIN &&
        (!walletSecuritySettingsProvider.activateBioProtection &&
            camoBloc.isCamoEnabled) &&
        _camoPin != null &&
        code == _camoPin;
  }

  void _onCamoPinEntered(dynamic code) {
    if (!camoBloc.isCamoActive) {
      coinsBloc.resetCoinBalance();
      camoBloc.isCamoActive = true;
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }

    _onCodeSuccess(code);
  }
}
