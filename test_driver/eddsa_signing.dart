import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:komodo_dex/utils/base91.dart';

// Libsodium won't work on an average desktop,
// we need a “flutter drive” test to touch it.
// Run with
//
//     flutter drive --target=test_driver/eddsa_signing.dart

/// Invoked from “eddsa_signing_test.dart” to test EdDSA signatures
Future<String> driveHandler(String payload) async {
  final regex = RegExp(r'(\w+) "(\w+)"');
  final res = regex.firstMatch(payload);
  if (res == null) throw Exception('No payload');
  final op = res[1];
  final p = res[2];
  if (op == 'sign') {
    return signingTest(p);
  } else if (op == 'encrypt') {
    return encryptionTest(p);
  }
  throw Exception('No operation given');
}

Future<String> signingTest(String payload) async {
  // NB: The seed matches the one in caretakers,
  // https://gitlab.com/artemciy/mm-pubsub-db/-/blob/e0196951/src/lib.rs#L619
  // in order to verify compatibility.
  final seed = Uint8List(32);
  final seedChars = 'test-seed'.codeUnits;
  for (int ix = 0; ix < seedChars.length; ++ix) seed[ix] = seedChars[ix];
  final b91seed = utf8.decode(base91js.encode(seed));
  if (b91seed != 'fPNK}f8e;RyAAAAAAAAAAAAAAAAAAAAAAAAAAA')
    throw Exception('Unexpected seed');

  final key = KeyPair.fromMap(await Sodium.cryptoSignSeedKeypair(seed));
  final b91pk = utf8.decode(base91js.encode(key.publicKey));
  if (b91pk != 'xpq/5Il,F#,{wV_qrn|oHbVSOE_:QOveQC:u[24E')
    throw Exception('Unexpected key');

  final signature = await CryptoSign.sign(payload, key.secretKey);
  final b91sig = utf8.decode(base91js.encode(signature));
  if (b91sig !=
      "je)@oUloqsoW\$oB>x;IJ8C%n:iEoP'j'Z3cz|>!WMMg7d>Ssi]hZC?gP_|r#f1~12UClN2p{zN#Y;jA")
    throw Exception('Unexpected signature');

  final receivedSig = base91js.decode(utf8.encode(b91sig));
  final valid = await CryptoSign.verify(receivedSig, payload, key.publicKey);
  if (!valid) throw Exception('Signature verification failed');

  return 'okay';
}

Future<String> encryptionTest(String payload) async {
  final alicePair = await CryptoBox.generateKeyPair();
  final bobPair = await CryptoBox.generateKeyPair();

  final nonce = await CryptoBox.generateNonce();

  final encrypted = await CryptoBox.encrypt(
      payload, nonce, bobPair.publicKey, alicePair.secretKey);
  final decrypted = await CryptoBox.decrypt(
      encrypted, nonce, alicePair.publicKey, bobPair.secretKey);
  if (payload != decrypted)
    throw Exception("Payload and decrypted content don't match");
  return 'okay';
}

void main() {
  enableFlutterDriverExtension(handler: driveHandler);

  runApp(
      const MaterialApp(home: Scaffold(body: Text('EdDSA test in progress'))));
}
