import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';

class EncryptionTool {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String keyPassword(KeyEncryption key, Wallet wallet) =>
      'password${key.toString()}${wallet.name}${wallet.id}';

  String keyData(KeyEncryption key, Wallet wallet, String password) =>
      '${key.toString()}$password${wallet.name}${wallet.id}';

  // MRC: It seems our previous version of flutter_sodium was using Argon2id,
  // so I am setting it here as well to keep compatibility
  // On my testing it allows unlocking the wallet with the old password
  // Apparently libsodium started using Argon2id since 1.0.15, according to
  // https://libsodium.gitbook.io/doc/password_hashing/default_phf#notes

  Future<bool> isPasswordValid(
      KeyEncryption key, Wallet wallet, String password) async {
    if (key == KeyEncryption.SEED) {
      bool isValid = false;
      try {
        isValid = await argon2.verifyHashString(
          password,
          await storage.read(key: keyPassword(key, wallet)),
          type: Argon2Type.id,
        );
      } catch (_) {}

      return isValid;
    } else {
      return true;
    }
  }

  Future<String> _computeHash(String data) async {
    final s = Salt.newSalt();

    final result =
        await argon2.hashPasswordString(data, salt: s, type: Argon2Type.id);

    return result.encodedString;
  }

  Future<void> writeData(KeyEncryption key, Wallet wallet, String password,
          String data) async =>
      await storage
          .write(key: keyData(key, wallet, password), value: data)
          .then((_) async {
        if (key == KeyEncryption.SEED) {
          await storage.write(
              key: keyPassword(key, wallet),
              value: await _computeHash(password));
        }
      });

  Future<String> readData(
          KeyEncryption key, Wallet wallet, String password) async =>
      await isPasswordValid(key, wallet, password)
          .catchError((dynamic e) => throw e)
          .then((bool onValue) async =>
              await storage.read(key: keyData(key, wallet, password)));

  Future<void> deleteData(
          KeyEncryption key, Wallet wallet, String password) async =>
      await isPasswordValid(key, wallet, password)
          .catchError((dynamic e) => throw e)
          .then((bool res) async {
        await storage.delete(key: keyPassword(key, wallet));
      }).then((_) async =>
              await storage.delete(key: keyData(key, wallet, password)));

  Future<void> write(String key, String data) async =>
      await storage.write(key: key, value: data);

  Future<String> read(String key) async => await storage.read(key: key);

  Future<void> delete(String key) async => await storage.delete(key: key);
}

enum KeyEncryption { SEED, PIN, CAMOPIN }
