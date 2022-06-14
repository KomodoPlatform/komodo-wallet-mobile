import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> logOut(WidgetTester tester) async {
  final Finder settingsMenu = find.byKey(const Key('main-nav-more'));
  final Finder logOutButton = find.byKey(const Key('side-nav-logout'));
  final Finder confirmLogoutButton =
      find.byKey(const Key('settings-logout-yes'));
  await tester.pumpAndSettle();
  await tester.tap(settingsMenu);
  await tester.pumpAndSettle();
  await tester.tap(logOutButton);
  await tester.pumpAndSettle();
  await tester.tap(confirmLogoutButton);
  await tester.pumpAndSettle();
}
