import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/foundation.dart';

/// A class responsible for handling biometric storage operations.
///
/// The BiometricStorageApi class provides methods for reading and writing
/// wallet passphrases using biometric storage.
///
/// Example:
///
/// ```dart
/// final biometricStorage = BiometricStorage();
/// final biometricStorageApi = BiometricStorageApi(biometricStorage: biometricStorage);
/// ```
class BiometricStorageApi {
  final BiometricStorage _biometricStorage;
  String _storageKeyPattern({required String walletId}) =>
      'wallet_passphrase_$walletId';

  BiometricStorageApi({
    required BiometricStorage biometricStorage,
  }) : _biometricStorage = biometricStorage;

  Future<BiometricStorageFile> getStorageFile(String walletId) async {
    final key = _storageKeyPattern(walletId: walletId);
    return await _biometricStorage.getStorage(key);
  }

  Future<String?> read(String walletId) async {
    final storageFile = await getStorageFile(walletId);
    return await storageFile.read();
  }

  Future<void> write(String walletId, String data) async {
    final storageFile = await getStorageFile(walletId);
    await storageFile.write(data);
  }

  Future<CanAuthenticateResponse> biometricsAvailable() async {
    final response = await _biometricStorage.canAuthenticate();
    debugPrint('biometricsAvailable: $response');

    return response;
  }
}
