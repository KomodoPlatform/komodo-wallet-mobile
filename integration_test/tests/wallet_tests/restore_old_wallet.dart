import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/screens/authentification/authenticate_page.dart';

Future<void> restoreOldWallet(WidgetTester tester) async {
  final Finder walletItem =
      find.byKey(const Key('logged-out-wallet-my-wallet'));

  try {
    expect(
      find.byType(AuthenticatePage),
      findsOneWidget,
      reason: 'Logout has been confirmed, but screen not on Authenticate Page',
    );
    await tester.tap(walletItem);
    await tester.pumpAndSettle();

    await _enterPassword(tester);
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}

Future<void> _enterPassword(WidgetTester tester) async {
  final Finder loginButton = find.byKey(const Key('unlock-wallet'));

  final Finder passwordField = find.byKey(const Key('enter-password-field'));
  const String password = 'pppaaasssDDD555444@@@';
// test invalid password
  await tester.enterText(passwordField, 'Invalid_Password');
  await tester.pumpAndSettle();
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
  expect(
    loginButton,
    findsOneWidget,
    reason: 'Invalid password entered, but wallet unlocked',
  );
  await tester.pumpAndSettle(Duration(seconds: 2));

// test valid password
  await tester.enterText(passwordField, password);
  await tester.pump();
  await tester.tap(loginButton);
  await tester.pumpAndSettle();
}
