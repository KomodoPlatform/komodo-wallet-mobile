import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';

Future<void> receiveTestCoins(WidgetTester tester,
    {required List<String> coins}) async {
  final Finder receiveCoin = find.byKey(const Key('receive-coin'));
  final Finder copyAddress = find.byKey(const Key('copy-address'));
  final Finder closeDialog = find.byKey(const Key('close-dialog'));
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
    for (String coin in coins) {
      final Finder elementCoinItem = find.byKey(Key('coin-list-$coin'));
      expect(elementCoinItem, findsOneWidget);

      await tester.drag(elementCoinItem, const Offset(500.0, 0.0));
      await tester.pumpAndSettle();
      await tester.tap(receiveCoin);
      await tester.pumpAndSettle();
      expect(
        find.byKey(Key('receive-dialog')),
        findsOneWidget,
        reason: 'Dialog is not opened',
      );
      await tester.tap(copyAddress);
      await tester.pumpAndSettle();
      await tester.tap(closeDialog);
      await tester.pumpAndSettle();
    }
  } catch (e) {
    print(e);
    rethrow;
  }
}
