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

Future<String> driveHandler(String payload) async {
  // NB: The seed matches the one in caretakers,
  // https://gitlab.com/artemciy/mm-pubsub-db/-/blob/e0196951/src/lib.rs#L619
  // in order to verify compatibility.
  final seed = Uint8List(32);
  final seedChars = 'test-seed'.codeUnits;
  for (int ix = 0; ix < seedChars.length; ++ix) seed[ix] = seedChars[ix];
  final b91seed = utf8.decode(base91js.encode(seed));
  print('b91seed: $b91seed');

  final key = KeyPair.fromMap(await Sodium.cryptoSignSeedKeypair(seed));
  final b91pk = utf8.decode(base91js.encode(key.publicKey));
  print('b91pk: $b91pk');

  final signature = await CryptoSign.sign(payload, key.secretKey);
  final b91sig = utf8.decode(base91js.encode(signature));
  print('b91sig ($payload): $b91sig');

  final receivedSig = base91js.decode(utf8.encode(b91sig));
  final valid = await CryptoSign.verify(receivedSig, payload, key.publicKey);
  if (!valid) throw Exception('Signature verification failed');

  return 'okay';
}

void main() {
  enableFlutterDriverExtension(handler: driveHandler);

  runApp(
      const MaterialApp(home: Scaffold(body: Text('EdDSA test in progress'))));
}
