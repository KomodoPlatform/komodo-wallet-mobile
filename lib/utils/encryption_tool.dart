import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:uuid/uuid.dart';

class EncryptionTool {
  final storage = new FlutterSecureStorage();

  Future<void> writeData(KeyEncryption key, Wallet wallet, String password, String data) async{
    await storage.write(key: '${key.toString()}$password${wallet.name}${wallet.id}', value: data);
  }

  Future<String> readData(KeyEncryption key, Wallet wallet, String password) async{
    return await storage.read(key:'${key.toString()}$password${wallet.name}${wallet.id}');
  }

  Future<void> deleteData(KeyEncryption key, Wallet wallet, String password) async {
    await storage.delete(key: '${key.toString()}$password${wallet.name}${wallet.id}');
  }
}

enum KeyEncryption{
  SEED,
  PIN
}

