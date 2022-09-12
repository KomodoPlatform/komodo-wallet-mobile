import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/screens/settings/setting_page.dart';

Future<void> enableTestCoin(WidgetTester tester) async {
  final Finder drawerMenu = find.byKey(const Key('main-nav-more'));
  final Finder settingsButton = find.byKey(const Key('side-nav-settings'));
  final Finder scrollSettings = find.byKey(const Key('settings-scrollable'));
  final Finder showTestCoins = find.byKey(const Key('show-test-coins'));
  final Finder backButton = find.byTooltip('Back');

  try {
    expect(
      find.byType(MyHomePage),
      findsOneWidget,
      reason: 'Screen is not on the Home page',
    );
    await tester.pumpAndSettle();
    await tester.tap(drawerMenu);
    await tester.pumpAndSettle();
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();
    expect(
      find.byType(SettingPage),
      findsOneWidget,
      reason: 'Screen is not on the Setting Page',
    );
    await tester.drag(scrollSettings, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(showTestCoins);
    await tester.pumpAndSettle();
    await tester.tap(backButton);
    await tester.pumpAndSettle();
    expect(
      find.byType(MyHomePage),
      findsOneWidget,
      reason: 'Screen is not on the Home page',
    );
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
