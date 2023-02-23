import 'package:shared_preferences/shared_preferences.dart';

import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/camo_bloc.dart';
import '../../generic_blocs/coins_bloc.dart';
import '../../localizations.dart';
import '../../model/wallet.dart';
import '../../model/wallet_security_settings_provider.dart';
import '../../screens/authentification/pin_page.dart';
import '../../services/db/database.dart';
import '../../services/mm_service.dart';
import '../../utils/encryption_tool.dart';
import '../../utils/log.dart';
import '../../utils/utils.dart';
import '../../widgets/page_transition.dart';

class AuthenticationRepository {
  AuthenticationRepository();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized)
      throw Exception('AuthenticationRepository is already initialized');

    // do any necessary initialization here:

    //

    // Set initialized
    _isInitialized = true;
  }

  String? _error;
  String? _correctPin;
  String? _camoPin;

  Future<void> _initCorrectPin(PinStatus pinStatus) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (pinStatus == PinStatus.CREATE_PIN ||
        pinStatus == PinStatus.CHANGE_PIN) {
      _correctPin = null;
    } else if (pinStatus == PinStatus.CONFIRM_PIN) {
      authBloc.showLock = false;
      _correctPin = prefs.getString('pin_create');
    } else if (pinStatus == PinStatus.CREATE_CAMO_PIN) {
      _correctPin = null;
    } else if (pinStatus == PinStatus.CONFIRM_CAMO_PIN) {
      authBloc.showLock = false;
      _correctPin = prefs.getString('camo_pin_create');
    } else {
      final EncryptionTool encryptionTool = EncryptionTool();
      await pauseUntil(() async => await encryptionTool.read('pin') != null);

      final String? normalPin = await encryptionTool.read('pin');
      final String? camoPin = await encryptionTool.read('camoPin');

      _correctPin = normalPin;
      _camoPin = camoPin;
    }
  }

  Future<void> onCodeSuccess(String password, String code, Function? onSuccess,
      PinStatus pinStatus, bool isFromChangingPin) async {
    final walletSecuritySettingsProvider =
        context.read<WalletSecuritySettingsProvider>();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (pinStatus) {
      case PinStatus.NORMAL_PIN:
        bool loadSnapshot = true;
        if (camoBloc.isCamoActive) {
          coinsBloc.resetCoinBalance();
          loadSnapshot = false;
        }

        authBloc.showLock = false;
        if (!mmSe.running) {
          await authBloc.login(await EncryptionTool().read('passphrase'), null,
              loadSnapshot: loadSnapshot);
        }
        if (onSuccess != null) {
          onSuccess();
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
        final Wallet? wallet = await Db.getCurrentWallet();

        if (wallet != null) {
          await EncryptionTool()
              .writeData(KeyEncryption.PIN, wallet, password, code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('pin', code.toString());
        authBloc.showLock = false;
        authBloc.updateStatusPin(PinStatus.NORMAL_PIN);
        if (!isFromChangingPin) {
          if (!mmSe.running) {
            await authBloc.login(
                await EncryptionTool().read('passphrase'), password);
          }
        } else {
          //  Navigator.pop(context);
        }
        //  Navigator.pop(context);

        await prefs.remove('pin_create');
        await prefs.remove('is_pin_creation_in_progress');

        break;

      case PinStatus.CONFIRM_CAMO_PIN:
        final Wallet? wallet = await Db.getCurrentWallet();
        if (wallet != null) {
          await EncryptionTool()
              .writeData(
                  KeyEncryption.CAMOPIN, wallet, password, code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('camoPin', code.toString());

        await prefs.remove('camo_pin_create');
        await prefs.remove('is_camo_pin_creation_in_progress');

        camoBloc.shouldWarnBadCamoPin = true;
        if (onSuccess != null) {
          onSuccess();
        }
        // Navigator.popUntil(context, ModalRoute.withName('/camoSetup'));
        break;

      case PinStatus.DISABLED_PIN:
        walletSecuritySettingsProvider.activatePinProtection = true;
        // Navigator.pop(context);
        break;
      case PinStatus.DISABLED_PIN_BIOMETRIC:
        walletSecuritySettingsProvider.activateBioProtection = false;
        // Navigator.pop(context);
        break;
    }
  }

  /* Future<void> _onCodeFail(dynamic code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (widget.pinStatus) {
      case PinStatus.CREATE_PIN:
        await prefs.setBool('is_pin_creation_in_progress', true);
        await prefs.setString('pin_create', code);
        final materialPage = PageTransition(
            child: PinPage(
          title: AppLocalizations.of(context)!.confirmPin,
          subTitle: AppLocalizations.of(context)!.confirmPin,
          code: code,
          pinStatus: PinStatus.CONFIRM_PIN,
          password: widget.password,
        ));

        Navigator.push<dynamic>(context, materialPage);
        break;

      case PinStatus.CHANGE_PIN:
        await prefs.setString('pin_create', code);
        final materialPage = PageTransition(
            child: PinPage(
          title: AppLocalizations.of(context)!.confirmPin,
          subTitle: AppLocalizations.of(context)!.confirmPin,
          code: code,
          pinStatus: PinStatus.CONFIRM_PIN,
          password: widget.password,
          isFromChangingPin: true,
        ));

        Navigator.pushReplacement<dynamic, dynamic>(context, materialPage);
        break;

      case PinStatus.CREATE_CAMO_PIN:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_camo_pin_creation_in_progress', true);
        await prefs.setString('camo_pin_create', code);
        final materialPage = PageTransition(
            child: PinPage(
          title: AppLocalizations.of(context)!.camouflageSetup,
          subTitle: AppLocalizations.of(context)!.confirmCamouflageSetup,
          code: code,
          onSuccess: widget.onSuccess,
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

  void _onErrorPinEntered() {
    camoBloc.isCamoActive = false;

    setState(() {
      _error = AppLocalizations.of(context)!.errorTryAgain;
    });
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
  }*/

  Future<void> setPin(String pin) async {
    //
    print('isInitialized: ${_isInitialized}');
  }

  Future<void> setCamoPin(String pin) async {
    //
  }

  Future<void> setCamoPinEnabled(bool value) async {
    //
  }

  Future<void> setBioProtection(bool value) async {
    //
  }

  Future<bool> getBioProtection() async {
    // TODO: implement getBioProtection
    throw UnimplementedError();
  }

  Future<void> setLogOutOnExit(bool value) async {
    // TODO: implement setLogOutOnExit
    throw UnimplementedError();
  }

  Future<bool> getLogOutOnExit(bool value) async {
    // TODO: implement getLogOutOnExit
    throw UnimplementedError();
  }

  Future<bool> validatePin(String pin) async {
    // TODO: implement validatePin
    throw UnimplementedError();
  }

  Future<void> loginWithPin(String pin) async {
    // TODO: implement loginWithPin
    throw UnimplementedError();
  }

  Future<bool> validateCamoPin(String pin) async {
    // TODO: implement validateCamoPin
    throw UnimplementedError();
  }

  Future<void> loginWithCamoPin(String pin) async {
    //
  }
}
