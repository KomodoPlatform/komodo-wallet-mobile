import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testActivateCoins(WidgetTester tester) async {
  const String ethByTicker = 'ETH';
  const String dogeByName = 'gecoi';
  const String kmdBep20ByTicker = 'KMD-BEP20';

  final Finder walletTab = find.byKey(const Key('main-menu-wallet'));
  final Finder walletTabMobile =
      find.byKey(const Key('main-menu-mobile-button'));
  final Finder popupMenuWallet =
      find.byKey(const Key('mm-wallet-mobile-button'));
  final Finder totalAmount = find.byKey(const Key('overview-total-balance'));

  final Finder addAssetsButton = find.byKey(const Key('add-assets-button'));
  final Finder removeAssetsButton =
      find.byKey(const Key('remove-assets-button'));
  final Finder searchCoinsField =
      find.byKey(const Key('coins-manager-search-field'));
  final Finder switchButton =
      find.byKey(const Key('coins-manager-switch-button'));
  final Finder list = find.byKey(const Key('coins-manager-list'));

  final Finder ethCoinItem =
      find.byKey(const Key('coins-manager-list-item-eth'));
  final Finder dogeCoinItem =
      find.byKey(const Key('coins-manager-list-item-doge'));
  final Finder kmdBep20CoinItem =
      find.byKey(const Key('coins-manager-list-item-kmd-bep20'));
  final Finder bnbCoinItem =
      find.byKey(const Key('coins-manager-list-item-bnb'));

  // Enter Wallet View
  try {
    expect(walletTab, findsOneWidget);
    await tester.tap(walletTab);
    await tester.pumpAndSettle();
    expect(totalAmount, findsOneWidget);
  } on TestFailure {
    // Try mobile screen if default (desktop) fails
    expect(walletTabMobile, findsOneWidget);
    await tester.tap(walletTabMobile);
    await tester.pumpAndSettle();
    await tester.tap(popupMenuWallet);
    await tester.pumpAndSettle();
  }

  // Press Add coins
  await tester.tap(addAssetsButton);
  await tester.pumpAndSettle();
  expect(searchCoinsField, findsOneWidget);

  // Try to find non-existent coin
  await tester.enterText(searchCoinsField, 'NOSUCHCOINEVER');
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
  expect(ethCoinItem, findsNothing);
  // Try to find and activate ETH and DOGE coins
  await tester.enterText(searchCoinsField, ethByTicker);
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
  expect(ethCoinItem, findsOneWidget);
  await tester.tap(ethCoinItem);
  await tester.pumpAndSettle();
  await tester.enterText(searchCoinsField, dogeByName);
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
  expect(dogeCoinItem, findsOneWidget);
  await tester.tap(dogeCoinItem);
  await tester.pumpAndSettle();
  // Try to find and activate KMD-BEP20
  // (and auto-activate parent coin - BNB)
  await tester.enterText(searchCoinsField, kmdBep20ByTicker);
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
  expect(kmdBep20CoinItem, findsOneWidget);
  await tester.tap(kmdBep20CoinItem);
  await tester.pumpAndSettle();
  await tester.tap(switchButton);
  await tester.pumpAndSettle();

  // show my list in coins manager
  await tester.tap(removeAssetsButton);
  await tester.pumpAndSettle();

  // ETH, DOGE, KMD-BEP20 and BNB should be active
  await tester.dragUntilVisible(
    kmdBep20CoinItem,
    list,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle();
  expect(kmdBep20CoinItem, findsOneWidget);

  await tester.dragUntilVisible(
    ethCoinItem,
    list,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle();
  expect(ethCoinItem, findsOneWidget);

  await tester.dragUntilVisible(
    dogeCoinItem,
    list,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle();
  expect(dogeCoinItem, findsOneWidget);

  await tester.dragUntilVisible(
    bnbCoinItem,
    list,
    const Offset(0, -15),
  );
  await tester.pumpAndSettle();
  expect(bnbCoinItem, findsOneWidget);
}
