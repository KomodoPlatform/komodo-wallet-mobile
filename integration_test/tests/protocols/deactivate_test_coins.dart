import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';

Future<void> deactivateTestCoins(WidgetTester tester,
    {required List<String> coinsToDeactivate}) async {
  final Finder disableCoin = find.byKey(const Key('disable-coin'));
  final Finder confirmDisable = find.byKey(const Key('confirm-disable'));
  final Finder coinsList = find.byKey(const Key('list-view-coins'));

  try {
    expect(
      find.byType(CoinsPage),
      findsOneWidget,
      reason: 'Screen is not on the Coins page',
    );

    await tester.drag(coinsList, Offset(0, -200));
    await tester.pumpAndSettle();
    // Try to find and activated coins and deactivate them
    for (String coin in coinsToDeactivate) {
      final Finder elementCoinItem = find.byKey(Key('coin-list-$coin'));
      expect(
        elementCoinItem,
        findsOneWidget,
        reason: '$coin is not in the Coins List',
      );

      await tester.drag(elementCoinItem, const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();
      await tester.tap(disableCoin);
      await tester.pumpAndSettle();
      await tester.tap(confirmDisable);
      await tester.pumpAndSettle();

      expect(
        elementCoinItem,
        findsNothing,
        reason: '$coin is in the Coins List',
      );
    }

    expect(
      find.byKey(Key('coin-list-KMD')),
      findsOneWidget,
      reason: 'KMD is not on the Coins List',
    );

    expect(
      find.byKey(Key('coin-list-BTC')),
      findsOneWidget,
      reason: 'BTC is not on the Coins List',
    );
    // BTC and KMD should be active

  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
