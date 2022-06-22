import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> createAdvancedSwap(WidgetTester tester) async {
  try {
    final Finder dexMenu = find.byKey(const Key('main-nav-dex'));
    final Finder advancedTabBtn = find.byKey(const Key('advanced-tab'));
    final Finder openSellDialog = find.byKey(const Key('coin-select-sell'));
    final Finder sellMortyCoin =
        find.byKey(const Key('item-dialog-morty-sell'));
    final Finder sellAmountField = find.byKey(const Key('input-text-sell'));
    final Finder openReceiveDialog = find.byKey(const Key('coin-select-buy'));
    final Finder buyRickCoin = find.byKey(const Key('orderbook-item-rick'));
    final Finder selectOrder = find.byKey(const Key('ask-item-0'));
    final Finder confirmOrder = find.byKey(const Key('confirm-details'));
    final Finder clearBtn = find.byKey(const Key('clear-trade-button'));
    final Finder nextBtn = find.byKey(const Key('trade-button'));
    final Finder cancelBtn = find.byKey(const Key('cancel-swap-button'));
    final Finder startSwapBtn = find.byKey(Key('confirm-swap-button'));
    final Finder backBtn = find.byTooltip('Back');
    final Finder orderTabBtn = find.byKey(const Key('orders-tab'));

    // Press dex menu
    await tester.tap(dexMenu);
    await tester.pumpAndSettle();
    await tester.tap(advancedTabBtn);

    // sell aspect
    await tester.pumpAndSettle();
    await tester.tap(openSellDialog);
    await tester.pumpAndSettle();
    await tester.tap(sellMortyCoin);
    await tester.pumpAndSettle();
    await tester.enterText(sellAmountField, '0.1');
    await tester.pumpAndSettle();

    // receive aspect
    await tester.tap(openReceiveDialog);
    await tester.pumpAndSettle();
    await tester.tap(buyRickCoin);
    await tester.pumpAndSettle();
    await tester.longPress(selectOrder);
    await tester.pumpAndSettle(Duration(seconds: 1));

    // proceed, cancel and clear fields
    await tester.tap(nextBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();
    await tester.tap(clearBtn);
    await tester.pumpAndSettle();

    // sell aspect
    await tester.pumpAndSettle();
    await tester.tap(openSellDialog);
    await tester.pumpAndSettle();
    await tester.tap(sellMortyCoin);
    await tester.pumpAndSettle();
    await tester.enterText(sellAmountField, '0.2');
    await tester.pumpAndSettle();

    // receive aspect
    await tester.tap(openReceiveDialog);
    await tester.pumpAndSettle();
    await tester.tap(buyRickCoin);
    await tester.pumpAndSettle();
    await tester.tap(selectOrder);
    await tester.pumpAndSettle();
    await tester.tap(confirmOrder);
    await tester.pumpAndSettle();

    // proceed and confirm order
    await tester.tap(nextBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(startSwapBtn);
    await tester.pumpAndSettle();

    // go back to order page to see order
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    await tester.tap(orderTabBtn);
    await tester.pumpAndSettle();
    // Order has been created
  } catch (e) {
    print(e?.message ?? e);
  }
}
