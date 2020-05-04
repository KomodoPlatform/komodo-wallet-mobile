import 'dart:typed_data';

import 'package:flutter_sodium/flutter_sodium.dart';

class EdDsaSigning {
  static Future<KeyPair> generateKey() async {
    final ed25519Sk = await CryptoSign.generateKeyPair();
    return ed25519Sk;
  }

  static Future<Uint8List> sign(String message, Uint8List secretKey) async {
    final result = await CryptoSign.sign(message, secretKey);
    return result;
  }

  static Future<bool> validate(
    Uint8List signature,
    String message,
    Uint8List publicKey,
  ) async {
    final result = await CryptoSign.verify(signature, message, publicKey);
    return result;
  }
}
