import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:komodo_dex/utils/base91.dart';
import 'package:komodo_dex/utils/eddsa.dart';

class SignatureInfo {
  String signature;
  Uint8List publicKey;
}

// Exploratory.
class SigningTest extends StatefulWidget {
  @override
  _SigningTestState createState() => _SigningTestState();
}

class _SigningTestState extends State<SigningTest> {
  TextEditingController controller = TextEditingController();
  String text = '';
  bool validation = false;

  SignatureInfo sig;

  Future<void> submit(String message) async {
    final key = await EdDsaSigning.generateKey();
    final signature = await EdDsaSigning.sign(message, key.secretKey);
    final encodedSignature = base91.encode(signature);

    final s = SignatureInfo();
    s.publicKey = key.publicKey;
    s.signature = ascii.decode(encodedSignature);

    sig = s;
  }

  Future<void> validateSignature(String message) async {
    final s = sig;
    final signatureBytes = ascii.encode(s.signature);
    final decodedSignature = base91.decode(signatureBytes);

    final v =
        await EdDsaSigning.validate(decodedSignature, message, s.publicKey);
    print(v ? 'Validated' : 'Failed validation');
    setState(() {
      validation = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            key: const Key('message_text_field'),
            onSubmitted: submit,
          ),
          RaisedButton(
            key: const Key('submit_button'),
            onPressed: () async {
              await submit(controller.text);
            },
            child: const Text('Submit'),
          ),
          RaisedButton(
            key: const Key('validate_button'),
            onPressed: () async {
              await validateSignature(controller.text);
            },
            child: const Text('Validate'),
          ),
          RaisedButton(
            key: const Key('clear_button'),
            onPressed: () {
              setState(() {
                controller.text = '';
                sig = null;
                validation = false;
              });
            },
            child: const Text('Clear'),
          ),
          Text(
            validation ? 'Validated' : 'Failed validation',
            key: const Key('validation_text'),
          ),
        ],
      ),
    );
  }
}

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();

  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SigningTest(),
      ),
    ),
  );
}
