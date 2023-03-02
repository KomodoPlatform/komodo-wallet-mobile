import 'package:shared_preferences/shared_preferences.dart';

import '../../generic_blocs/authenticate_bloc.dart';
import '../../generic_blocs/camo_bloc.dart';
import '../../generic_blocs/coins_bloc.dart';
import '../../localizations.dart';
import '../../model/wallet.dart';
import '../../model/wallet_security_settings_provider.dart';
import '../../services/db/database.dart';
import '../../services/mm_service.dart';
import '../../utils/encryption_tool.dart';
import '../../utils/log.dart';
import '../../utils/utils.dart';

class LoginRepository {
  LoginRepository();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized)
      throw Exception('AuthenticationRepository is already initialized');

    // do any necessary initialization here:

    //

    // Set initialized
    _isInitialized = true;
  }

  String? _correctPin;
  String? _camoPin;
  PinStatus? _pinStatus;
  String? _password;
  String? _code;
  Function()? _onSuccess;
  Function()? _postSuccess;
  Function()? _postFailed;
  bool _isFromChangingPin = false;
  AppLocalizations loc = AppLocalizations();

  Future<void> initParameters(
      String? password,
      String? code,
      Function()? onSuccess,
      Function()? uiOnSuccess,
      Function()? uiOnFailed,
      PinStatus? pinStatus,
      bool isFromChangingPin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _pinStatus = pinStatus;
    _password = password;
    _code = code;
    _onSuccess = onSuccess;
    _isFromChangingPin = isFromChangingPin;

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

  Future<void> onCodeSuccess() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (_pinStatus) {
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
        if (_onSuccess != null) {
          _onSuccess!();
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
              .writeData(KeyEncryption.PIN, wallet, _password, _code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('pin', _code.toString());
        authBloc.showLock = false;
        authBloc.updateStatusPin(PinStatus.NORMAL_PIN);
        if (!_isFromChangingPin) {
          if (!mmSe.running) {
            await authBloc.login(
                await EncryptionTool().read('passphrase'), _password);
          }
        } else {
          _postSuccess!();
        }
        _postSuccess!();

        await prefs.remove('pin_create');
        await prefs.remove('is_pin_creation_in_progress');

        break;

      case PinStatus.CONFIRM_CAMO_PIN:
        final Wallet? wallet = await Db.getCurrentWallet();
        if (wallet != null) {
          await EncryptionTool()
              .writeData(
                  KeyEncryption.CAMOPIN, wallet, _password, _code.toString())
              .catchError((dynamic e) => Log.println('pin_page:90', e));
        }

        await EncryptionTool().write('camoPin', _code.toString());

        await prefs.remove('camo_pin_create');
        await prefs.remove('is_camo_pin_creation_in_progress');

        camoBloc.shouldWarnBadCamoPin = true;
        if (_onSuccess != null) {
          _onSuccess!();
        }
        _postSuccess!();
        break;

      case PinStatus.DISABLED_PIN:
        walletSecuritySettingsProvider.activatePinProtection = true;
        _postSuccess!();
        break;
      case PinStatus.DISABLED_PIN_BIOMETRIC:
        walletSecuritySettingsProvider.activateBioProtection = false;
        _postSuccess!();
        break;
      default:
        break;
    }
  }

  Future<void> _onCodeFail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (_pinStatus) {
      case PinStatus.CREATE_PIN:
        await prefs.setBool('is_pin_creation_in_progress', true);
        await prefs.setString('pin_create', _code!);

        print(12);
        _postFailed!();

        break;

      case PinStatus.CHANGE_PIN:
        await prefs.setString('pin_create', _code!);

        _postFailed!();
        break;

      case PinStatus.CREATE_CAMO_PIN:
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_camo_pin_creation_in_progress', true);
        await prefs.setString('camo_pin_create', _code!);

        _postFailed!();
        break;

      default:
        if (_isCamoPinCode()) {
          if (!camoBloc.isCamoActive) {
            coinsBloc.resetCoinBalance();
            camoBloc.isCamoActive = true;
            _postFailed!();
          }
          onCodeSuccess();
        } else {
          _onErrorPinEntered();
        }
        break;
    }
  }

  void _onErrorPinEntered() {
    camoBloc.isCamoActive = false;

    throw AppLocalizations().errorTryAgain;
  }

  bool _isCamoPinCode() {
    return _pinStatus == PinStatus.NORMAL_PIN &&
        (!walletSecuritySettingsProvider.activateBioProtection &&
            camoBloc.isCamoEnabled) &&
        _camoPin != null &&
        _code == _camoPin;
  }

  Future<void> setPin(String pin) async {
    //
    print('isInitialized: $_isInitialized');
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

  Future<void> validatePin() async {
    if (_code == _correctPin) {
      await onCodeSuccess();
    } else {
      await _onCodeFail();
    }
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
