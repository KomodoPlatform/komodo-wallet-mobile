import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> restoreOldWallet(WidgetTester tester) async {
  final Finder walletItem =
      find.byKey(const Key('logged-out-wallet-my-wallet'));
  final Finder passwordField = find.byKey(const Key('enter-password-field'));
  const String password = 'pppaaasssDDD555444@@@';

  try {
    // todo: check if we're on auth sceen
    await tester.tap(walletItem);
    await tester.pumpAndSettle();
    await tester.tap(passwordField);

    // todo: add test for wrong password input

    await tester.enterText(passwordField, password);
    await tester.pump();
    // todo: replace receiveAction with tapping on 'Login' button
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
