import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/success_step.dart';
import 'package:komodo_dex/screens/portfolio/coins_page.dart';

Future<void> sendTestCoins(WidgetTester tester,
    {String address, String amount = '1', List<String> coins}) async {
  final Finder openSendButton = find.byKey(const Key('open-SEND'));
  final Finder addressField = find.byKey(const Key('send-address-field'));
  final Finder amountField = find.byKey(const Key('send-amount-field'));
  final Finder sendNow = find.byKey(const Key('primary-button-withdraw'));
  final Finder confirmSend = find.byKey(const Key('primary-button-confirm'));
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

      await tester.tap(elementCoinItem);
      await tester.pumpAndSettle();
      await tester.tap(openSendButton);
      await tester.pumpAndSettle();
      await tester.enterText(addressField, address);
      await tester.pumpAndSettle();
      await tester.enterText(amountField, amount);
      await tester.pumpAndSettle();
      await tester.tap(sendNow);
      await tester.pumpAndSettle();
      await tester.tap(confirmSend);
      await tester.pumpAndSettle();
      expect(
        find.byType(SuccessStep),
        findsOneWidget,
        reason: 'Coin was not sent',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
