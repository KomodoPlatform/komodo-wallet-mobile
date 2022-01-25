/*
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
Future<String> driveHandler(String test) async {
  if (test == 'sign foobar') {
    return await sign();
  } else if (test == 'encrypt foobar') {
    return await encrypt();
  }
  throw Exception('Unknown test: $test');
}

Uint8List testSeed() {
  // NB: The seed matches the one in caretakers,
  // https://gitlab.com/artemciy/mm-pubsub-db/-/blob/e0196951/src/lib.rs#L619
  // in order to verify compatibility.
  final seed = Uint8List(32);
  final seedChars = 'test-seed'.codeUnits;
  for (int ix = 0; ix < seedChars.length; ++ix) seed[ix] = seedChars[ix];
  return seed;
}

Future<String> sign() async {
  final seed = testSeed();
  final b91seed = utf8.decode(base91js.encode(seed));
  if (b91seed != 'fPNK}f8e;RyAAAAAAAAAAAAAAAAAAAAAAAAAAA') {
    throw Exception('Unexpected seed');
  }

  final key = KeyPair.fromMap(await Sodium.cryptoSignSeedKeypair(seed));
  final b91pk = utf8.decode(base91js.encode(key.publicKey));
  if (b91pk != 'xpq/5Il,F#,{wV_qrn|oHbVSOE_:QOveQC:u[24E') {
    throw Exception('Unexpected key');
  }

  final signature = await CryptoSign.sign('foobar', key.secretKey);
  final b91sig = utf8.decode(base91js.encode(signature));
  if (b91sig !=
      "je)@oUloqsoW\$oB>x;IJ8C%n:iEoP'j'Z3cz|>!WMMg7d>Ssi]hZC?gP_|r#f1~12UClN2p{zN#Y;jA") {
    throw Exception('Unexpected signature');
  }

  final receivedSig = base91js.decode(utf8.encode(b91sig));
  final valid = await CryptoSign.verify(receivedSig, 'foobar', key.publicKey);
  if (!valid) throw Exception('Signature verification failed');

  return 'okay';
}

/// Demonstrate “authenticated encryption”,
/// cf. https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption
Future<String> encrypt() async {
  // NB: We're using well-known seeds in order to be able
  // to demonstrate and verify the base91-encoded encryption results
  // and that they are the same across different platforms.
  final seed = testSeed();
  final aliceKey = KeyPair.fromMap(await Sodium.cryptoBoxSeedKeypair(seed));
  seed[seed.length - 1] += 1;
  final bobKey = KeyPair.fromMap(await Sodium.cryptoBoxSeedKeypair(seed));

  final b91seed = utf8.decode(base91js.encode(seed));
  if (b91seed != 'fPNK}f8e;RyAAAAAAAAAAAAAAAAAAAAAAAAACA')
    throw Exception('Unexpected seed');

  // The ephemeral streaming key for https://en.wikipedia.org/wiki/Salsa20
  // is derived partially from the nonce. It “doesn't have to be confidential,
  // but it should be used with just one invocation of crypto_box_easy()
  // for a particular pair of public and secret keys”.
  //
  // Note that random nonces aren't truly unique.
  // It is preferable to track the nonces we've used in order to make them unique.
  //final nonce = await CryptoBox.generateNonce();
  final nonce = Uint8List(24);
  nonce[0] = 1;

  // The first 16 bytes of the `ciphertext` are the https://en.wikipedia.org/wiki/Poly1305 MAC.
  // The rest is the `payload` encrypted with the streaming https://en.wikipedia.org/wiki/Salsa20.
  final ciphertext = await CryptoBox.encrypt(
      'foobar', nonce, bobKey.publicKey, aliceKey.secretKey);

  final b91ciphertext = utf8.decode(base91js.encode(ciphertext));
  print('b91ciphertext $b91ciphertext');
  if (b91ciphertext != 'qlFkB1JOVM+\$=?TwW2f`d,pz{FGB') {
    throw Exception('Unexpected ciphertext');
  }

  final decrypted = await CryptoBox.decrypt(
      ciphertext, nonce, aliceKey.publicKey, bobKey.secretKey);
  if (decrypted != 'foobar') throw Exception('Not foobar');

  return 'okay';
}

void main() {
  enableFlutterDriverExtension(handler: driveHandler);

  runApp(
      const MaterialApp(home: Scaffold(body: Text('EdDSA test in progress'))));
}
*/
