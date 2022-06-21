import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testActivateCoins(WidgetTester tester) async {
  try {
    const String ethByTicker = 'ETH';
    const String dogeByName = 'gecoi';
    const String kmdBep20ByTicker = 'KMD-BEP20';

    final Finder addAssetsButton = find.byKey(const Key('adding-coins'));
    final Finder searchCoinsField = find.byKey(const Key('coins-search-field'));
    final Finder confirmAddAssetsButton =
        find.byKey(const Key('done-activate-coins'));

    final Finder ethCoinItem = find.byKey(const Key('coin-activate-ETH'));
    final Finder dogeCoinItem = find.byKey(const Key('coin-activate-DOGE'));
    final Finder kmdBep20CoinItem =
        find.byKey(const Key('coin-activate-KMD-BEP20'));

    final Finder homeList = find.byKey(const Key('list-view-coins'));
    final Finder ethCoinHomeItem = find.byKey(const Key('coin-list-ETH'));

    // Press Add coins
    await tester.tap(addAssetsButton);
    await tester.pumpAndSettle();
    expect(searchCoinsField, findsOneWidget);

    // Try to find non-existent coin
    await tester.enterText(searchCoinsField, 'NOSUCHCOINEVER');
    await tester.pumpAndSettle();
    expect(ethCoinItem, findsNothing);
    // Try to find and activate ETH and DOGE coins
    await tester.enterText(searchCoinsField, ethByTicker);
    await tester.pumpAndSettle();
    expect(ethCoinItem, findsOneWidget);
    await tester.tap(ethCoinItem);
    await tester.pumpAndSettle();

    await tester.enterText(searchCoinsField, dogeByName);
    await tester.pumpAndSettle();
    expect(dogeCoinItem, findsOneWidget);
    await tester.tap(dogeCoinItem);
    await tester.pumpAndSettle();
    // Try to find and activate KMD-BEP20
    // (and auto-activate parent coin - BNB)
    await tester.enterText(searchCoinsField, kmdBep20ByTicker);
    await tester.pumpAndSettle();
    expect(kmdBep20CoinItem, findsOneWidget);
    await tester.tap(kmdBep20CoinItem);
    await tester.pumpAndSettle();
    // clear text
    await tester.enterText(searchCoinsField, '');
    await tester.pumpAndSettle();
    // ETH, DOGE, KMD-BEP20 and BNB should be active

    await tester.tap(confirmAddAssetsButton);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
        ethCoinHomeItem, homeList, const Offset(0, -15));
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
