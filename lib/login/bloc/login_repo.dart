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
  LoginRepository({
    required this.prefs,
  });

  bool _isInitialized = false;

  final SharedPreferences prefs;

  Future<void> init() async {
    if (_isInitialized)
      throw Exception('AuthenticationRepository is already initialized');

    // do any necessary initialization here:

    //

    // Set initialized
    _isInitialized = true;
  }

  AppLocalizations loc = AppLocalizations();

  Future<void> onPinLoginSuccess() async {
    bool loadSnapshot = true;
    if (camoBloc.isCamoActive) {
      coinsBloc.resetCoinBalance();
      loadSnapshot = false;
    }

    authBloc.showLock = false;
    if (!mmSe.running) {
      await authBloc.login(await EncryptionTool().read('passphrase'), null,
          loadSnapshot: loadSnapshot);

      // Wait for mmService to be ready
      await pauseUntil(() => mmSe.running, maxMs: 10000);
    }
  }

  void _onErrorPinEntered() {
    camoBloc.isCamoActive = false;

    throw AppLocalizations().errorTryAgain;
  }

  Future<bool> isPinSet() async {
    final String? pin = await EncryptionTool().read('pin');
    return pin != null;
  }

  Future<void> setNewPin(String pin) async {
    // Check if the pin is correct or if it has not already been set.
    if (await isPinSet()) {
      throw PinAlreadySetException();
    }

    await _writePin(pin, password: '');
  }

  Future<void> _writePin(String pin, {required String password}) async {
    // TODO: verify password

    final Wallet? wallet = await Db.getCurrentWallet();

    if (wallet != null) {
      throw UnimplementedError();
      // await EncryptionTool()
      //     .writeData(KeyEncryption.PIN, wallet, _password, _code.toString())
      //     .catchError((dynamic e) => Log.println('pin_page:90', e));
    }

    await EncryptionTool().write('pin', pin);
  }

  Future<void> resetPin({
    required String currentPin,
    required String newPin,
  }) async {
    await verifyPin(currentPin);

    await _writePin(newPin, password: '');
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

  /// Verifies the pin code. Throws an exception if the pin is incorrect.
  Future<void> verifyPin(String pin) async {
    final _correctPin = await EncryptionTool().read('pin');

    if (_correctPin == null) {
      throw PinNotFoundException();
    }

    if (pin != _correctPin) {
      throw IncorrectPinException();
    }

    return;
  }

  Future<void> loginWithPin(String pin) async {
    // TODO: implement loginWithPin
    throw UnimplementedError();
  }

  Future<bool> verifyCamoPin(String pin) async {
    // TODO: implement validateCamoPin
    throw UnimplementedError();
  }

  Future<void> loginWithCamoPin(String pin) async {
    //
  }
}

// List of exceptions that can be thrown by the repository.
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);
}

class PinNotFoundException extends AuthenticationException {
  PinNotFoundException() : super('Pin not found. Try setting a pin first.');
}

class IncorrectPinException extends AuthenticationException {
  IncorrectPinException() : super('Incorrect pin.');
}

class PinAlreadySetException extends AuthenticationException {
  PinAlreadySetException() : super('Pin already set. Try resetting it first.');
}
