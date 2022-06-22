import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

Future<void> createPassword(WidgetTester tester) async {
  const String invalidPassword = 'abcd';
  const String password = 'pppaaasssDDD555444@@@';
  const String wrongPassword = 'teretet';

  final Finder passwordField = find.byKey(const Key('create-password-field'));
  final Finder passwordConfirmField =
      find.byKey(const Key('create-password-field-confirm'));
  final Finder confirmPasswordButton =
      find.byKey(const Key('confirm-password'));
  final Finder viewPasswordBtn = find.byKey(const Key('password-visibility'));

  // test invalid password
  await tester.enterText(passwordField, invalidPassword);
  await tester.enterText(passwordConfirmField, invalidPassword);
  await tester.pump(Duration(seconds: 1));
  expect(
    tester.widget<PrimaryButton>(confirmPasswordButton).onPressed == null,
    true,
    reason: 'Invalid password entered, but \'Confirm\' button is enabled',
  );

  // test wrong password
  await tester.enterText(passwordField, password);
  await tester.enterText(passwordConfirmField, wrongPassword);
  await tester.pump(Duration(seconds: 1));
  await tester.pump(Duration(seconds: 1));
  expect(
    tester.widget<PrimaryButton>(confirmPasswordButton).onPressed == null,
    true,
    reason: 'Passwords do not match, but \'Confirm\' button is enabled',
  );

  //  correct valid password
  await tester.enterText(passwordField, password);
  await tester.tap(viewPasswordBtn);
  await tester.pump(Duration(seconds: 1));
  await tester.tap(passwordConfirmField);
  await tester.enterText(passwordConfirmField, password);
  await tester.pump(Duration(seconds: 1));
  await tester.tap(confirmPasswordButton);
  await tester.pump(Duration(seconds: 1));
}
