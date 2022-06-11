import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'enter_pin.dart';

Future<void> restoreWalletToTest(WidgetTester tester) async {
  // Restores wallet to be used in following tests
  try {
    const String testSeed =
        'hazard slam top rail jacket ecology trash first stock nut swift thought youth rack slot regular wasp bulk spatial legal staff change way brush';
    const String walletName = 'my-wallet';
    const String password = 'pppaaasssDDD555444@@@';
    const String pin = '123456';
    final Finder restoreWalletButton = find.byKey(const Key('restoreWallet'));
    final Finder nameField = find.byKey(const Key('name-wallet-field'));
    final Finder importSeedField = find.byKey(const Key('restore-seed-field'));
    final Finder confirmSeedButton =
        find.byKey(const Key('confirm-seed-button'));
    final Finder passwordField = find.byKey(const Key('create-password-field'));
    final Finder passwordConfirmField =
        find.byKey(const Key('create-password-field-confirm'));
    final Finder confirmPasswordButton =
        find.byKey(const Key('confirm-password'));
    final Finder eulaCheckBox = find.byKey(const Key('checkbox-eula'));
    final Finder tocCheckBox = find.byKey(const Key('checkbox-toc'));
    final Finder disclaimerScroll = find.byKey(const Key('scroll-disclaimer'));
    final Finder endListDisclaimer =
        find.byKey(const Key('end-list-disclaimer'));
    final Finder disclaimerButton = find.byKey(const Key('next-disclaimer'));

    // authenticate_page.dart
    await tester.ensureVisible(restoreWalletButton);
    await tester.tap(restoreWalletButton);
    await tester.pumpAndSettle();
    // welcome_page.dart
    await tester.tap(nameField);
    await tester.enterText(nameField, walletName);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // restore_seed_page.dart
    await tester.pump(Duration(seconds: 1));
    await tester.enterText(importSeedField, testSeed);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(Duration(seconds: 1));
    await tester.ensureVisible(confirmSeedButton);
    await tester.tap(confirmSeedButton);
    await tester.pump(Duration(seconds: 1));
    // create_password_page.dart
    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, password);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    // disclaimer_page.dart
    await tester.tap(eulaCheckBox);
    await tester.tap(tocCheckBox);
    await tester.dragUntilVisible(
      endListDisclaimer,
      disclaimerScroll,
      const Offset(0, -1500),
    );
    await tester.pump(Duration(seconds: 1));
    await tester.tap(disclaimerButton);
    await tester.pump(Duration(seconds: 1));
    // pin_page.dart
    await tester.pumpAndSettle();
    await enterPinCode(tester, pin: pin);
    await tester.pumpAndSettle();
    await enterPinCode(tester, pin: pin);

    await tester.pumpAndSettle();
  } catch (e) {
    print(e?.message ?? e);
  }
}
