import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testCoinsProtocolFilter(WidgetTester tester) async {
  const String mclByTicker = 'MCL';
  const String bat = 'bat';

  final Finder addAssetsButton = find.byKey(const Key('adding-coins'));
  final Finder searchCoinsField = find.byKey(const Key('coins-search-field'));
  final Finder confirmAddAssetsButton = find.byKey(Key('done-activate-coins'));
  final Finder showFilterDropdown = find.byKey(Key('show-filter-protocol'));
  final Finder clearFilter = find.byKey(const Key('clear-filter-protocol'));
  final Finder utxoFilter = find.byKey(const Key('filter-item-utxo'));
  final Finder smartChainFilter = find.byKey(Key('filter-item-smartChain'));
  final Finder bepFilter = find.byKey(const Key('filter-item-bep'));
  final Finder mclCoinItem = find.byKey(const Key('coin-activate-MCL'));
  final Finder dashCoinItem = find.byKey(const Key('coin-activate-DASH'));
  final Finder batBep20CoinItem = find.byKey(Key('coin-activate-BAT-BEP20'));

  try {
    // Press Add coins
    await tester.tap(addAssetsButton);
    await tester.pumpAndSettle();

    // Try to click on utxo protocol and search for dash
    await tester.tap(showFilterDropdown);
    await tester.pumpAndSettle();
    await tester.tap(utxoFilter);
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, 'd');
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, 'da');
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, 'das');
    await tester.pumpAndSettle();
    expect(
      dashCoinItem,
      findsOneWidget,
      reason: 'Dash was searched but not found',
    );
    await tester.tap(dashCoinItem);
    await tester.pumpAndSettle();

    // clear filter
    await tester.tap(clearFilter);
    await tester.pumpAndSettle();
    // clear text
    await tester.enterText(searchCoinsField, '');
    await tester.pumpAndSettle();

    //  Try to click on smartchain protocol, search and activate MCL
    await tester.tap(showFilterDropdown);
    await tester.pumpAndSettle();
    await tester.tap(smartChainFilter);
    await tester.pumpAndSettle();
    await tester.enterText(searchCoinsField, mclByTicker);
    await tester.pumpAndSettle();
    expect(
      mclCoinItem,
      findsOneWidget,
      reason: 'Mcl was searched but not found',
    );
    await tester.tap(mclCoinItem);
    await tester.pumpAndSettle();

    // clear filter
    await tester.tap(clearFilter);
    await tester.pumpAndSettle();
    // clear text
    await tester.enterText(searchCoinsField, '');
    await tester.pumpAndSettle();

    // Try to search for bat and choose bep20 protocol
    await tester.enterText(searchCoinsField, bat);
    await tester.pumpAndSettle();
    await tester.tap(showFilterDropdown);
    await tester.pumpAndSettle();
    await tester.tap(bepFilter);
    await tester.pumpAndSettle();
    expect(
      batBep20CoinItem,
      findsOneWidget,
      reason: 'bat-bep20 was searched but not found',
    );
    await tester.tap(batBep20CoinItem);
    await tester.pumpAndSettle();

    // clear text
    await tester.enterText(searchCoinsField, '');
    await tester.pumpAndSettle();
    // MCL, DASH, and BAT-BEP20 should be active

    await tester.tap(confirmAddAssetsButton);
    await tester.pumpAndSettle();
  } catch (e) {
    print(e);
    rethrow;
  }
}
