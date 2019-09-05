import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:password/password.dart';

import 'mode.dart';

class EncryptionTool {
  FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> writeData(
      KeyEncryption key, Wallet wallet, String password, String data) async {
    await storage.write(
        key:
            '${key.toString()}${await convertToPbkdf2(password, wallet)}${wallet.name}${wallet.id}',
        value: data);
  }

  Future<String> readData(
      KeyEncryption key, Wallet wallet, String password) async {
    return await storage.read(
        key:
            '${key.toString()}${await convertToPbkdf2(password, wallet)}${wallet.name}${wallet.id}');
  }

  Future<void> deleteData(
      KeyEncryption key, Wallet wallet, String password) async {
    await storage.delete(
        key:
            '${key.toString()}${await convertToPbkdf2(password, wallet)}${wallet.name}${wallet.id}');
  }

  Future<String> convertToPbkdf2(String data, Wallet wallet) async {
    print(wallet.isFastEncryption ? 'FAST ENCRYPTION' : 'SLOW ENCRYPTION');

    // Workarround for run this in debug mode for driver testing https://github.com/flutter/flutter/issues/24703
    dynamic res;
    if (!isInDebugMode) {
      res = wallet.isFastEncryption
          ? await compute(_computeHash, DataCompute(data: data, iteration: 50))
          : await compute(
              _computeHash, DataCompute(data: data, iteration: 10000));
    } else {
      res = _computeHash(DataCompute(data: data, iteration: 1));
    }
    return res;
  }

  static String _computeHash(DataCompute dataCompute) {
    return Password.hash(
        dataCompute.data, PBKDF2(iterationCount: dataCompute.iteration));
  }

  Future<void> write(String key, String data) async {
    await storage.write(key: key, value: data);
  }

  Future<String> read(String key) async {
    return await storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }
}

class DataCompute {
  DataCompute({this.data, this.iteration});
  String data;
  int iteration;
}

enum KeyEncryption { SEED, PIN }
