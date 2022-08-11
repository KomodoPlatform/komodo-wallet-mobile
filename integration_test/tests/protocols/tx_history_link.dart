import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';

Future<void> openTxHistoryLink(WidgetTester tester,
    {List<String> coins}) async {
  final Finder txHistoryButton = find.byKey(const Key('tx-explorer-button'));
  final Finder coinsList = find.byKey(const Key('list-view-coins'));
  final Finder portfolioTab = find.byKey(const Key('main-nav-portfolio'));

  try {
    await tester.tap(portfolioTab);
    await tester.pumpAndSettle();
    expect(
      find.byType(CoinsPage),
      findsOneWidget,
      reason: 'Screen is not on the Coins page',
    );

    await tester.drag(coinsList, Offset(0, -200));
    await tester.pumpAndSettle();
    // Try to find and activated coins and deactivate them
    for (String coin in coins) {
      final Finder elementCoinItem = find.byKey(Key('coin-list-$coin'));
      expect(
        elementCoinItem,
        findsOneWidget,
        reason: '$coin is not in the Coins List',
      );

      await tester.tap(elementCoinItem);
      await tester.pumpAndSettle();
      await tester.tap(txHistoryButton);
      await tester.pumpAndSettle();
    }
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
