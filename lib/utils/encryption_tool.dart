import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/wallet.dart';

class EncryptionTool {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String keyPassword(KeyEncryption key, Wallet wallet) =>
      'password${key.toString()}${wallet.name}${wallet.id}';

  String keyData(KeyEncryption key, Wallet wallet, String? password) =>
      '${key.toString()}$password${wallet.name}${wallet.id}';

  // MRC: It seems our previous version of flutter_sodium was using Argon2id,
  // so I am setting it here as well to keep compatibility
  // On my testing it allows unlocking the wallet with the old password
  // Apparently libsodium started using Argon2id since 1.0.15, according to
  // https://libsodium.gitbook.io/doc/password_hashing/default_phf#notes

  Future<bool> isPasswordValid(
      KeyEncryption key, Wallet wallet, String? password) async {
    if (password == null) throw PasswordNotSetException('Password not set');

    if (key == KeyEncryption.SEED) {
      bool isValid = false;
      try {
        final String? seed = await storage.read(key: keyPassword(key, wallet));

        if (seed == null) {
          throw SeedNotSetException('Seed not set');
        }

        isValid = await argon2.verifyHashString(
          password,
          seed,
          type: Argon2Type.id,
        );
      } catch (e) {
        print('Error while verifying password: ${e.toString()}');
        if (e is! PasswordException) {
          throw PasswordException(e.toString());
        }
        rethrow;
      }

      if (!isValid) {
        throw PasswordException('Password is not valid');
      }

      return isValid;
    } else {
      return true;
    }
  }

  // Future<bool> validatePassword(String password) async {
  //   final String? correctPassword = await read('passphrase');

  //   if (correctPassword == null) {
  //     throw PasswordNotSetException('Password not set.');
  //   }

  //   return password == correctPassword;
  // }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _computeHash(String data) async {
    final s = Salt.newSalt();

    final result =
        await argon2.hashPasswordString(data, salt: s, type: Argon2Type.id);

    return result.encodedString;
  }

  String encryptData(String password, String data) {
    final iv = IV.fromSecureRandom(16);
    final mac = IV.fromSecureRandom(16);

    final key = Key.fromUtf8(password)
        .stretch(16, iterationCount: 10000, salt: iv.bytes);

    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

    final encrypted =
        encrypter.encrypt(data, iv: iv, associatedData: mac.bytes);
    return iv.base64 + mac.base64 + encrypted.base64;
  }

  String? decryptData(String password, String encryptedData) {
    try {
      String ivString = encryptedData.substring(0, 24);
      String macString = encryptedData.substring(24, 48);
      String dataString = encryptedData.substring(48);

      final iv = IV.fromBase64(ivString);
      final mac = IV.fromBase64(macString);

      final key = Key.fromUtf8(password)
          .stretch(16, iterationCount: 10000, salt: iv.bytes);

      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final Encrypted encrypted = Encrypted.fromBase64(dataString);
      final decryptedData =
          encrypter.decrypt(encrypted, iv: iv, associatedData: mac.bytes);
      return decryptedData;
    } catch (_) {
      return _decryptLegacy(password, encryptedData);
    }
  }

  String? _decryptLegacy(String password, String encryptedData) {
    try {
      final String length32Key = md5.convert(utf8.encode(password)).toString();
      final key = Key.fromUtf8(length32Key);
      final iv = IV.allZerosOfLength(16);

      final Encrypter encrypter = Encrypter(AES(key));
      final Encrypted encrypted = Encrypted.fromBase64(encryptedData);
      final decryptedData = encrypter.decrypt(encrypted, iv: iv);

      return decryptedData;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeData(KeyEncryption key, Wallet wallet, String? password,
          String? data) async =>
      await storage
          .write(key: keyData(key, wallet, password), value: data)
          .then((_) async {
        if (key == KeyEncryption.SEED) {
          await storage.write(
              key: keyPassword(key, wallet),
              value: await _computeHash(password!));
        }
      });

  Future<String?> readData(
          KeyEncryption key, Wallet wallet, String password) async =>
      await isPasswordValid(key, wallet, password)
          .catchError((dynamic e) => throw e)
          .then(
            (bool onValue) async => await storage.read(
              key: keyData(key, wallet, password),
            ),
          );

  // TODO: Refactor according to style guidelines. This code seems to be
  // following a similar pattern to Javascript's promises. Prefer async
  // blocks and await instead.
  Future<void> deleteData(
          KeyEncryption key, Wallet wallet, String? password) async =>
      await isPasswordValid(key, wallet, password)
          .catchError((dynamic e) => throw e)
          .then((bool res) async {
        await storage.delete(key: keyPassword(key, wallet));
      }).then(((_) async =>
              await storage.delete(key: keyData(key, wallet, password))));

  Future<void> write(String key, String? data) async =>
      await storage.write(key: key, value: data);

  Future<String?> read(String key) async => await storage.read(key: key);

  Future<void> delete(String key) async => await storage.delete(key: key);
}

enum KeyEncryption { SEED, PIN, CAMOPIN }

class PasswordException implements Exception {
  final String message;

  PasswordException(this.message);
}

class IncorrectPasswordException implements PasswordException {
  final String message;

  IncorrectPasswordException(this.message);
}

class PasswordNotSetException implements PasswordException {
  final String message;

  PasswordNotSetException(this.message);
}

class SeedNotSetException implements PasswordException {
  final String message;

  SeedNotSetException(this.message);
}
