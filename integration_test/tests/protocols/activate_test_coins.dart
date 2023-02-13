import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';

Future<void> activateTestCoins(WidgetTester tester,
    {List<String>? coinsToActivate}) async {
  coinsToActivate = coinsToActivate ?? appConfig.defaultTestCoins;
  final Finder addAssetsButton = find.byKey(const Key('adding-coins'));
  final Finder portfolioTab = find.byKey(const Key('main-nav-portfolio'));
  final Finder searchCoinsField = find.byKey(const Key('coins-search-field'));
  final Finder confirmAddAssetsButton = find.byKey(Key('done-activate-coins'));

  try {
    await tester.tap(portfolioTab);
    await tester.pumpAndSettle();
    expect(
      find.byType(CoinsPage),
      findsOneWidget,
      reason: 'Screen is not on the Coins page',
    );

    // Press Add coins
    await tester.tap(addAssetsButton);
    await tester.pumpAndSettle();
    expect(searchCoinsField, findsOneWidget);

    // Try to find and activate coins
    for (String element in coinsToActivate) {
      await tester.enterText(searchCoinsField, element);
      await tester.pumpAndSettle();
      final Finder elementCoinItem = find.byKey(Key('coin-activate-$element'));
      expect(elementCoinItem, findsOneWidget);
      await tester.tap(elementCoinItem);
      await tester.pumpAndSettle();
    }

    // clear text
    await tester.enterText(searchCoinsField, '');
    await tester.pumpAndSettle();

    await tester.tap(confirmAddAssetsButton);
    await tester.pumpAndSettle();
    // RICK and MORTY should be active
  } catch (e) {
    print(e);
    rethrow;
  }
}
