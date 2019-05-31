import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:uuid/uuid.dart';

class EncryptionTool {
  final storage = new FlutterSecureStorage();

  Future<void> writeData(Wallet wallet, String password, String seed) async{
    await storage.write(key: '$password${wallet.name}${wallet.id}', value: seed);
  }

  Future<String> readData(Wallet wallet, String password) async{
    return await storage.read(key:'$password${wallet.name}${wallet.id}');
  }

  Future<void> deleteData(Wallet wallet, String password) async {
    await storage.delete(key: '$password${wallet.name}${wallet.id}');
  }
}

