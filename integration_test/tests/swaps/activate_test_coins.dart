import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> activateTestCoins(WidgetTester tester) async {
  try {
    const String mortyByTicker = 'MORTY';
    const String rickByName = 'RICK';

    final Finder addAssetsButton = find.byKey(const Key('adding-coins'));
    final Finder searchCoinsField = find.byKey(const Key('coins-search-field'));
    final Finder confirmAddAssetsButton =
        find.byKey(const Key('done-activate-coins'));

    final Finder mortyCoinItem = find.byKey(const Key('coin-activate-MORTY'));
    final Finder rickCoinItem = find.byKey(const Key('coin-activate-RICK'));

    // Press Add coins
    await tester.tap(addAssetsButton);
    await tester.pumpAndSettle();
    expect(searchCoinsField, findsOneWidget);

    // Try to find and activate MORTY coins
    await tester.enterText(searchCoinsField, mortyByTicker);
    await tester.pumpAndSettle();
    expect(mortyCoinItem, findsOneWidget);
    await tester.tap(mortyCoinItem);
    await tester.pumpAndSettle();

    // Try to find and activate RICK coins
    await tester.enterText(searchCoinsField, rickByName);
    await tester.pumpAndSettle();
    expect(rickCoinItem, findsOneWidget);
    await tester.tap(rickCoinItem);
    await tester.pumpAndSettle();

    // clear text
    await tester.enterText(searchCoinsField, '');
    await tester.pumpAndSettle();

    await tester.tap(confirmAddAssetsButton);
    await tester.pumpAndSettle();
    // RICK and MORTY should be active
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
