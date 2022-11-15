import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testActivateCoins(WidgetTester tester) async {
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

  try {
    // Press Add coins
    await tester.tap(addAssetsButton);
    await tester.pumpAndSettle();
    expect(searchCoinsField, findsOneWidget);

    expect(
      find.byKey(Key('selected-coins-preview')),
      findsNothing,
      reason: 'Selected Coin Preview is available',
    );
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

    await _testSelectedCoinPreview(tester);

    await tester.tap(confirmAddAssetsButton);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
        ethCoinHomeItem, homeList, const Offset(0, -15));
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}

Future<void> _testSelectedCoinPreview(WidgetTester tester) async {
  final Finder selectedCoinsPreview = find.byKey(Key('selected-coins-preview'));
  final Finder chipETH = find.byKey(Key('selected-chip-ETH'));
  final Finder chipDOGE = find.byKey(Key('selected-chip-DOGE'));
  final Finder chipKMD = find.byKey(Key('selected-chip-KMD-BEP20'));

  expect(
    selectedCoinsPreview,
    findsOneWidget,
    reason: 'Selected Coin Preview is not available',
  );

  // find and check if ETH chip is present
  await tester.dragUntilVisible(
    chipETH,
    selectedCoinsPreview,
    Offset(30, 0),
  );
  expect(
    chipETH,
    findsOneWidget,
    reason: 'ETH chip is not present',
  );

  // find and check if DOGE chip is present
  await tester.dragUntilVisible(
    chipDOGE,
    selectedCoinsPreview,
    Offset(30, 0),
  );
  expect(
    chipDOGE,
    findsOneWidget,
    reason: ' DOGE chip is not present',
  );

  // find and check if KMD-BEP20 chip is present
  await tester.dragUntilVisible(
    chipKMD,
    selectedCoinsPreview,
    Offset(30, 0),
  );
  expect(
    chipKMD,
    findsOneWidget,
    reason: 'KMD-BEP20 chip is not present',
  );
}
