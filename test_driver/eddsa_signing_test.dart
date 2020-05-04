import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<void> main() async {
  FlutterDriver driver;
  final Map<String, String> envVars = Platform.environment;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  final List<String> messages = [
    'test message',
    'message one',
    'to be or not to be',
  ];

  group('Sign and validate', () {
    final SerializableFinder textField = find.byValueKey('message_text_field');
    final SerializableFinder clearButton = find.byValueKey('clear_button');
    final SerializableFinder submitButton = find.byValueKey('submit_button');
    final SerializableFinder validateButton =
        find.byValueKey('validate_button');
    final SerializableFinder validationText =
        find.byValueKey('validation_text');

    for (String message in messages) {
      test('Message $message', () async {
        await driver.tap(textField);
        await driver.enterText(message);
        await driver.tap(submitButton);
        await Future<dynamic>.delayed(const Duration(milliseconds: 500));
        await driver.tap(validateButton);
        await Future<dynamic>.delayed(const Duration(milliseconds: 500));
        final String result = await driver.getText(validationText);
        print(result);
        await driver.tap(clearButton);
        await Future<dynamic>.delayed(const Duration(milliseconds: 500));
        final bool success = result == 'Validated';
        expect(success, true);
      });
    }
  });
}
