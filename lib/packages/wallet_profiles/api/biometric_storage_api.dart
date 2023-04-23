import 'dart:io';

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
// TODO: Pass parameters for prompt info either through constructor or methods.
class BiometricStorageApi {
  BiometricStorageApi({
    required BiometricStorage biometricStorage,
    required String baseStorageKey,
  })  : _biometricStorage = biometricStorage,
        _baseStorageKey = baseStorageKey;

  final BiometricStorage _biometricStorage;

  final String _baseStorageKey;

  String _storageKeyPattern(String id) => !_baseStorageKey.contains('.')
      ? '$_baseStorageKey.$id'
      : throw Exception('baseStorageKey should not contain a period.');

  StorageFileInitOptions _storageFileInitOptions() => StorageFileInitOptions(
        authenticationValidityDurationSeconds: 30,
        authenticationRequired: true,
        androidBiometricOnly: false,
      );

  /// If [forceInit] is true, throws an exception if the storage file was
  /// already created in the current session.
  Future<BiometricStorageFile> _getStorageFile(
    String id, {
    bool forceInit = false,
  }) async {
    final key = _storageKeyPattern(id);
    return await _biometricStorage.getStorage(
      key,
      forceInit: forceInit,
      options: _storageFileInitOptions(),
    );
  }

  Future<String?> read(String id) async {
    final storageFile = await _getStorageFile(id);
    return await storageFile.read();
  }

  Future<void> create({
    required String id,
    required String data,
  }) async {
    _validateData(data);

    final storageFile = await _getStorageFile(id);

    final maybeContent = await storageFile.read();

    if (maybeContent != null) {
      throw FileAlreadyExistsException(
        'Biometric file already exists for id: $id'
        ' of key: ${_storageKeyPattern(id)}',
      );
    }

    await storageFile.write(data);
  }

  Future<void> update({
    required String id,
    required String data,
  }) async {
    _validateData(data);

    final storageFile = await _getStorageFile(id);

    final maybeContent = await storageFile.read();

    if (maybeContent == null) {
      throw FileAlreadyExistsException(
        'Biometric file does not exist for id: $id'
        ' of key: ${_storageKeyPattern(id)}',
      );
    }

    await storageFile.write(data);
  }

  Future<void> delete(String id) async {
    final storageFile = await _getStorageFile(id);
    await storageFile.delete();
  }

  void _validateData(String data) {
    if (data.length > 100000) {
      throw Exception('Data is too big to be stored in biometric storage');
    }
  }

  Future<CanAuthenticateResponse> biometricsAvailable() async {
    final response = await _biometricStorage.canAuthenticate();
    debugPrint('biometricsAvailable: $response');

    return response;
  }
}

class FileAlreadyExistsException implements IOException {
  FileAlreadyExistsException(this.message);

  @override
  final String message;

  @override
  String toString() => "FileAlreadyExistsException: $message";
}
