import 'package:komodo_dex/login/exceptions/auth_exceptions.dart';
import 'package:komodo_dex/login/models/pin_type.dart';
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

  // The previous method [onPinLoginSuccess] was refactored because
  // this method would log in without any authentication. Although we did first
  // check in the legacy bloc if the pin was set, this was not a good solution
  // for a public repository method. The effective name of the previous method
  // was 'loginWithoutAuthentication'.
  Future<void> loginWithPin(String pin, PinTypeName pinType) async {
    await verifyPin(pin, pinType);
    _performLogin(pinType);
  }

  Future<PinTypeName> loginWithPinAnyType(String pin) async {
    PinTypeName pinType = await verifyPinAnyType(pin);
    _performLogin(pinType);
    return pinType;
  }

  Future<void> loginWithPassword(String password) async {
    // Add logic here to verify the password if needed
    _performLogin(null);
  }

  Future<void> _performLogin(PinTypeName? pinType) async {
    //TODO (@ologunB): Please implement any logic here needed for specific
    // login types. Ignore and remove this comment If no changes are needed.

    bool loadSnapshot = true;
    if (pinType == PinTypeName.camo || camoBloc.isCamoActive) {
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

  Future<void> _writePin(
    String pin, {
    required PinTypeName type,
    required String password,
  }) async {
    final Wallet? wallet = await Db.getCurrentWallet();

    if (wallet != null) {
      throw UnimplementedError();
      // await EncryptionTool()
      //     .writeData(KeyEncryption.PIN, wallet, _password, _code.toString())
      //     .catchError((dynamic e) => Log.println('pin_page:90', e));
    }

    if (type == PinTypeName.normal) {
      await EncryptionTool().write('pin', pin);
    } else if (type == PinTypeName.camo) {
      await EncryptionTool().write('camoPin', pin);
    } else {
      throw UnimplementedError('Pin type not supported.');
    }
  }

  /// Either set or reset a given pin type. If the pin type is already set, the
  /// current pin must be provided. If the pin type is not set, the current pin
  /// must be null.
  Future<void> setPin({
    required String newPin,
    required PinTypeName type,
    String? currentPin,
  }) async {
    // Verify the current pin if it's provided

    // Check if the pin is already set for the provided type

    if (currentPin != null) {
      await verifyPin(currentPin, type);
    } else {
      try {
        await verifyPin('', type);
      } on PinNotFoundException {
        // The pin is not set for the provided type, continue with setting the pin
      }
    }

    // Check if the new pin is already set for any other type
    try {
      await verifyPinAnyType(newPin);
    } on PinNotFoundException {
      // The new pin is not set for other types, continue with setting the pin
    } on IncorrectPinException catch (e) {
      if (e.types.any((PinTypeName t) => t != type)) {
        throw PinAlreadySetForAnotherTypeException(e.types.single);
      }
    }

    final password = await EncryptionTool().read('passphrase');

    // Update the pin for the specified type
    await _writePin(newPin, type: type, password: password!);
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

  Future<void> verifyPassword(String password) async {
    final String? correctPassword = await EncryptionTool().read('passphrase');

    if (correctPassword == null) {
      throw PasswordNotSetException('Password not set.');
    }

    if (password != correctPassword) {
      throw IncorrectPasswordException('The password provided is incorrect.');
    }

    return;
  }

  /// Verifies the pin code. Throws an exception if the pin is incorrect.
  Future<void> verifyPin(String pin, PinTypeName type) async {
    String? correctPin;

    if (type == PinTypeName.camo) {
      correctPin = await EncryptionTool().read('camoPin');

      //
    } else if (type == PinTypeName.normal) {
      correctPin = await EncryptionTool().read('pin');

      //
    } else {
      throw UnimplementedError('Pin type not supported.');

      //
    }

    if (correctPin == null) {
      throw PinNotFoundException();
    }

    if (pin != correctPin) {
      throw IncorrectPinException(types: [type]);
    }

    return;
  }

  Future<PinTypeName> verifyPinAnyType(String pin) async {
    /// Checks all types of pins and if none exist, throws
    /// [PinNotFoundException]. If at least one exists, but the pin is incorrect,
    /// throws [IncorrectPinException]. If any of the pins are correct, returns
    /// the type of the pin.

    List<PinTypeName> incorrectTypes = [];
    List<PinTypeName> notFoundTypes = [];
    List<PinTypeName> verifiedPinTypes = [];

    for (PinTypeName type in PinTypeName.values) {
      try {
        await verifyPin(pin, type);
        verifiedPinTypes.add(type);
      } catch (e) {
        if (e is IncorrectPinException) {
          incorrectTypes.add(type);
        } else if (e is PinNotFoundException) {
          notFoundTypes.add(type);
        } else {
          // Rethrow any other exceptions
          rethrow;
        }
      }
    }

    assert(
      verifiedPinTypes.length <= 1,
      'Multiple pin types should not have the same pin.',
    );

    if (verifiedPinTypes.isNotEmpty) {
      return verifiedPinTypes.single;
    } else if (incorrectTypes.length == PinTypeName.values.length) {
      // If all pin types are incorrect, throw IncorrectPinException
      throw IncorrectPinException(types: incorrectTypes);
    } else {
      // If none of the pins are set, throw PinNotFoundException
      throw PinNotFoundException(types: notFoundTypes);
    }
  }
}
