import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

class EncryptionTool {
  FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> writeData(
      KeyEncryption key, Wallet wallet, String password, String data) async {
    print(key);
    await storage.write(
        key:
            '${key.toString()}${await _computeHash(password)}${wallet.name}${wallet.id}',
        value: data);
  }

  Future<String> readData(
      KeyEncryption key, Wallet wallet, String password) async {
    print(key);
    return await storage.read(
        key:
            '${key.toString()}${await _computeHash(password)}${wallet.name}${wallet.id}');
  }

  Future<void> deleteData(
          KeyEncryption key, Wallet wallet, String password) async =>
      await storage.delete(
          key:
              '${key.toString()}${await _computeHash(password)}${wallet.name}${wallet.id}');

  Future<String> _computeHash(String data) async {
    String hashed = await PasswordHash.hashStorage(data);
    print(hashed);
    return hashed;
  }

  Future<void> write(String key, String data) async =>
      await storage.write(key: key, value: data);

  Future<String> read(String key) async => await storage.read(key: key);

  Future<void> delete(String key) async => await storage.delete(key: key);
}

enum KeyEncryption { SEED, PIN }
