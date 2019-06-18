import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

class EncryptionTool {
  final storage = new FlutterSecureStorage();

  Future<void> writeData(KeyEncryption key, Wallet wallet, String password, String data) async{
    await storage.write(key: '${key.toString()}${convertToSha256(password)}${wallet.name}${wallet.id}', value: data);
  }

  Future<String> readData(KeyEncryption key, Wallet wallet, String password) async{
    return await storage.read(key:'${key.toString()}${convertToSha256(password)}${wallet.name}${wallet.id}');
  }

  Future<void> deleteData(KeyEncryption key, Wallet wallet, String password) async {
    await storage.delete(key: '${key.toString()}${convertToSha256(password)}${wallet.name}${wallet.id}');
  }

  String convertToSha256(String data){
    return sha256.convert(utf8.encode(data)).toString();
  }
}

enum KeyEncryption{
  SEED,
  PIN
}

