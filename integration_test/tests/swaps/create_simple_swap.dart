import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> createSimpleSwap(WidgetTester tester) async {
  try {
    final Finder dexMenu = find.byKey(const Key('main-nav-dex'));
    final Finder simpleNextBtn = find.byKey(const Key('trade-button-simple'));
    final Finder startSwapBtn = find.byKey(Key('confirm-simple-swap-button'));
    final Finder sellMortyCoin = find.byKey(const Key('sell-MORTY'));
    final Finder amountField = find.byKey(const Key('amount-field'));
    final Finder buyRickCoin = find.byKey(const Key('sell-RICK-top-order'));
    final Finder backBtn = find.byTooltip('Back');
    final Finder orderBtn = find.byKey(const Key('orders-tab'));

    // Press dex menu
    await tester.tap(dexMenu);
    await tester.pumpAndSettle();
    await tester.tap(sellMortyCoin);
    await tester.pumpAndSettle();
    // Enter 0.1 morty
    await tester.enterText(amountField, '0.1');
    await tester.pumpAndSettle();
    await tester.tap(buyRickCoin);
    await tester.pumpAndSettle();
    await tester.tap(simpleNextBtn);
    await tester.pumpAndSettle();
    await tester.tap(startSwapBtn);
    await tester.pumpAndSettle();
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    await tester.tap(orderBtn);
    await tester.pumpAndSettle();
    // Order has been created
  } catch (e) {
    print(e?.message ?? e);
  }
}
