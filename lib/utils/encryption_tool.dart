import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

class EncryptionTool {
  FlutterSecureStorage storage = FlutterSecureStorage();

  String keyPassword(KeyEncryption key, Wallet wallet) =>
      'password${key.toString()}${wallet.name}${wallet.id}';

  String keyData(KeyEncryption key, Wallet wallet, String password) =>
      '${key.toString()}$password${wallet.name}${wallet.id}';

  Future<bool> isPasswordValid(
      KeyEncryption key, Wallet wallet, String password) async {
    if (key == KeyEncryption.SEED) {
      return await PasswordHash.verifyStorage(
              await storage.read(key: keyPassword(key, wallet)), password)
          .then((bool onValue) =>
              onValue ? onValue : throw Exception('Invalid password.'));
    } else {
      return true;
    }
  }

  Future<String> _computeHash(String data) async =>
      await PasswordHash.hashStorage(data);

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

enum KeyEncryption { SEED, PIN }
