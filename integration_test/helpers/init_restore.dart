import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> restoreWalletToTest(WidgetTester tester) async {
  // Restores wallet to be used in following tests
  const String testSeed =
      'hazard slam top rail jacket ecology trash first stock nut swift thought youth rack slot regular wasp bulk spatial legal staff change way brush';
  const String walletName = 'my-wallet0';
  const String password = 'pppaaasssDDD555444@@@';
  final Finder restoreWalletButton = find.byKey(const Key('restoreWallet'));
  final Finder letsGoButton = find.byKey(const Key('welcome-setup'));
  final Finder nameField = find.byKey(const Key('name-wallet-field'));
  final Finder welcomePageScroll = find.byKey(const Key('welcome-scrollable'));
  final Finder importSeedField = find.byKey(const Key('restore-seed-field'));
  final Finder confirmSeedButton = find.byKey(const Key('confirm-seed-button'));
  final Finder passwordField = find.byKey(const Key('create-password-field'));
  final Finder passwordConfirmField =
      find.byKey(const Key('create-password-field-confirm'));
  final Finder confirmPasswordButton =
      find.byKey(const Key('confirm-password'));
  /*

  final Finder eulaCheckBox = find.byKey(const Key('checkbox-eula'));
  final Finder tocCheckBox = find.byKey(const Key('checkbox-toc'));*/

  // authenticate_page.dart
  await tester.ensureVisible(restoreWalletButton);
  await tester.tap(restoreWalletButton);
  await tester.pumpAndSettle();
  // welcome_page.dart
  await tester.tap(nameField);
  await tester.enterText(nameField, walletName);
  await tester.dragUntilVisible(
    letsGoButton,
    welcomePageScroll,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle(Duration(seconds: 3));
  await tester.press(letsGoButton);
  print(2);

  await tester.pumpAndSettle();
  // restore_seed_page.dart
  await tester.tap(importSeedField);
  await tester.enterText(importSeedField, testSeed);
  await tester.tap(confirmSeedButton);
  await tester.pumpAndSettle();
  // create_password_page.dart
  await tester.tap(passwordField);
  await tester.enterText(passwordField, password);
  await tester.tap(passwordConfirmField);
  await tester.enterText(passwordConfirmField, password);
  await tester.tap(confirmPasswordButton);
  await tester.pumpAndSettle();

  /*

  await tester.enterText(importSeedField, testSeed);
  await tester.tap(eulaCheckBox);
  await tester.pumpAndSettle();
  await tester.tap(tocCheckBox);
  await tester.dragUntilVisible(
    importConfirmButton,
    frontPageScroll,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle();
  await tester.tap(importConfirmButton);
  await tester.pumpAndSettle();
  await tester.enterText(passwordField, password);
  await tester.enterText(passwordConfirmField, password);
  await tester.dragUntilVisible(
    importConfirmButton,
    frontPageScroll,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle();
  await tester.tap(importConfirmButton);*/
  await tester.pumpAndSettle();
}
