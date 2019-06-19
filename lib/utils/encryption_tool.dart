import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:password/password.dart';

class EncryptionTool {
  final storage = new FlutterSecureStorage();

  Future<void> writeData(KeyEncryption key, Wallet wallet, String password, String data) async{
    await storage.write(key: '${key.toString()}${await convertToPbkdf2(password)}${wallet.name}${wallet.id}', value: data);
  }

  Future<String> readData(KeyEncryption key, Wallet wallet, String password) async{
    return await storage.read(key:'${key.toString()}${await convertToPbkdf2(password)}${wallet.name}${wallet.id}');
  }

  Future<void> deleteData(KeyEncryption key, Wallet wallet, String password) async {
    await storage.delete(key: '${key.toString()}${await convertToPbkdf2(password)}${wallet.name}${wallet.id}');
  }

  Future<String> convertToPbkdf2(String data) async{
    var res = await compute(_computeHash, data);
    print(res);
    return res;
  }

  static String _computeHash(String data) {
    return Password.hash(data, new PBKDF2());
  }

  Future<void> write(String key, String data) async{
    await storage.write(key: key, value: data);
  }

  Future<String> read(String key) async{
    return await storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

}

enum KeyEncryption{
  SEED,
  PIN
}

