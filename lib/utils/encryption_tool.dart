import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

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

  Future<String> encryptData(String password, String data) async {
    final message = utf8.encode(data);

    final algorithm = AesGcm.with128bits();
    final iv1 = algorithm.newNonce();
    final iv2 = algorithm.newNonce();
    final secretKey = await _pbkdf2Key(password, iv2);

    final secretBox = await algorithm.encrypt(
      message,
      secretKey: secretKey,
      nonce: iv1,
    );

    final encrypted = jsonEncode(<String, dynamic>{
      '0': base64.encode(secretBox.cipherText),
      '1': base64.encode(iv1),
      '2': base64.encode(iv2),
      '3': base64.encode(secretBox.mac.bytes),
    });
    return encrypted;
  }

  Future<String> decryptData(String password, String encryptedData) async {
    try {
      final Map<String, dynamic> json = jsonDecode(encryptedData);
      final List<int> data = base64.decode(json['0']);
      final List<int> iv1 = base64.decode(json['1']);
      final List<int> iv2 = base64.decode(json['2']);
      final List<int> mac = base64.decode(json['3']);

      final algorithm = AesGcm.with128bits();
      final secretKey = await _pbkdf2Key(password, iv2);
      final secretBox = SecretBox(data, nonce: iv1, mac: Mac(mac));

      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return utf8.decode(decrypted);
    } catch (_) {
      return _decryptLegacy(password, encryptedData);
    }
  }

  String _decryptLegacy(String password, String encryptedData) {
    try {
      final String length32Key =
          crypto.md5.convert(utf8.encode(password)).toString();
      final key = encrypt.Key.fromUtf8(length32Key);
      final iv = encrypt.IV.allZerosOfLength(16);

      final encrypt.Encrypter encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypt.Encrypted encrypted =
          encrypt.Encrypted.fromBase64(encryptedData);
      final decryptedData = encrypter.decrypt(encrypted, iv: iv);

      return decryptedData;
    } catch (_) {
      return null;
    }
  }

  Future<SecretKey> _pbkdf2Key(String password, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 128,
    );

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    return secretKey;
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
