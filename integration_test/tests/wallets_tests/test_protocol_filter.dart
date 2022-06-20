import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testCoinsProtocolFilter(WidgetTester tester) async {
  try {
    const String ethByTicker = 'ETH';
    const String aave = 'Aave';

    final Finder addAssetsButton = find.byKey(const Key('adding-coins'));
    final Finder searchCoinsField = find.byKey(const Key('coins-search-field'));
    final Finder confirmAddAssetsButton =
        find.byKey(const Key('done-activate-coins'));

    final Finder showFilterDropdown =
        find.byKey(const Key('show-filter-protocol'));
    final Finder clearFilter = find.byKey(const Key('clear-filter-protocol'));
    final Finder utxoFilter = find.byKey(const Key('filter-item-utxo'));
    final Finder ercFilter = find.byKey(const Key('filter-item-erc'));
    final Finder bepFilter = find.byKey(const Key('filter-item-bep'));

    final Finder ethCoinItem = find.byKey(const Key('coin-activate-ETH'));
    final Finder dogeCoinItem = find.byKey(const Key('coin-activate-DOGE'));
    final Finder aaveBep20CoinItem =
        find.byKey(const Key('coin-activate-AAVE-BEP20'));

    final Finder homeList = find.byKey(const Key('list-view-coins'));
    final Finder ethCoinHomeItem = find.byKey(const Key('coin-list-ETH'));

    // Press Add coins
    await tester.tap(addAssetsButton);
    await tester.pumpAndSettle();
    expect(searchCoinsField, findsOneWidget);

    // Try to click on utxo protocol and search for doge
    await tester.tap(showFilterDropdown);
    await tester.pumpAndSettle();
    await tester.tap(utxoFilter);
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, 'd');
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, 'do');
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, 'dog');
    await tester.pumpAndSettle();
    expect(dogeCoinItem, findsOneWidget);
    await tester.tap(dogeCoinItem);
    await tester.pumpAndSettle();

    // clear filter
    await tester.tap(clearFilter);
    await tester.pumpAndSettle();

    //  Try to click on erc protocol, search and activate ETH and DOGE coins
    await tester.tap(showFilterDropdown);
    await tester.pumpAndSettle();
    await tester.tap(ercFilter);
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, ethByTicker);
    await tester.pumpAndSettle();
    expect(ethCoinItem, findsOneWidget);
    await tester.tap(ethCoinItem);
    await tester.pumpAndSettle();

    // clear filter
    await tester.tap(clearFilter);
    await tester.pumpAndSettle();

    // Try to search for aave and choose bep20 protocol
    await tester.enterText(searchCoinsField, aave);
    await tester.pumpAndSettle();
    await tester.tap(showFilterDropdown);
    await tester.pumpAndSettle();
    await tester.tap(bepFilter);
    await tester.pumpAndSettle();
    expect(aaveBep20CoinItem, findsOneWidget);
    await tester.tap(aaveBep20CoinItem);
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
  }
}
