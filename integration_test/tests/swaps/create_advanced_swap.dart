import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';

Future<void> createAdvancedSwap(WidgetTester tester) async {
  final Finder dexMenu = find.byKey(const Key('main-nav-dex'));
  final Finder advancedTabBtn = find.byKey(const Key('advanced-tab'));

  final Finder clearBtn = find.byKey(const Key('clear-trade-button'));
  final Finder nextBtn = find.byKey(const Key('trade-button'));
  final Finder cancelBtn = find.byKey(const Key('cancel-swap-button'));
  final Finder startSwapBtn = find.byKey(Key('confirm-swap-button'));
  final Finder backBtn = find.byTooltip('Back');
  final Finder orderTabBtn = find.byKey(const Key('orders-tab'));
  final Finder activeOrderList = find.byKey(const Key('active-order-list'));

  try {
    expect(
      find.byType(MyHomePage),
      findsOneWidget,
      reason: 'Screen is not on the Home page',
    );

    // Press dex menu
    await tester.tap(dexMenu);
    await tester.pumpAndSettle();
    await tester.tap(advancedTabBtn);
    await tester.pumpAndSettle();
    expect(
      find.byType(DexPage),
      findsOneWidget,
      reason: 'Screen is not on the Dex page',
    );

    // sell aspect
    await _sellAspect(tester, amount: '1');

    // receive aspect
    await _receiveAspect(tester);

    // proceed, cancel and clear fields
    await tester.tap(nextBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();
    await tester.tap(clearBtn);
    await tester.pumpAndSettle();

    // sell aspect
    await _sellAspect(tester, amount: '1');

    // receive aspect
    await _receiveAspect(tester, confirm: false);

    // proceed and confirm order
    await tester.tap(nextBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(startSwapBtn);
    await tester.pumpAndSettle();

    // go back to order page to see order
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    expect(
      find.byType(DexPage),
      findsOneWidget,
      reason: 'Screen is not on the Dex page',
    );
    await tester.tap(orderTabBtn);
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<ListView>(activeOrderList).length,
      1,
      reason: 'Order was not created',
    );
    // Order has been created
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}

Future<void> _sellAspect(WidgetTester tester, {required String amount}) async {
  final Finder openSellDialog = find.byKey(const Key('coin-select-sell'));
  final Finder sellMortyCoin = find.byKey(const Key('item-dialog-morty-sell'));
  final Finder sellAmountField = find.byKey(const Key('input-text-sell'));

  await tester.tap(openSellDialog);
  await tester.pumpAndSettle();
  expect(
    find.byKey(Key('sell-coin-dialog')),
    findsOneWidget,
    reason: 'Sell dialog is not on Opened',
  );
  await tester.tap(sellMortyCoin);
  await tester.pumpAndSettle();
  await tester.enterText(sellAmountField, amount);
  await tester.pumpAndSettle();
}

Future<void> _receiveAspect(WidgetTester tester, {bool confirm = true}) async {
  final Finder openReceiveDialog = find.byKey(const Key('coin-select-buy'));
  final Finder buyRickCoin = find.byKey(const Key('orderbook-item-rick'));
  final Finder selectOrder = find.byKey(const Key('ask-item-0'));
  final Finder confirmOrder = find.byKey(const Key('confirm-details'));

  await tester.tap(openReceiveDialog);
  await tester.pumpAndSettle();
  expect(
    find.byKey(Key('buy-coin-dialog')),
    findsOneWidget,
    reason: 'Receive dialog is not on Opened',
  );
  await tester.tap(buyRickCoin);
  await tester.pumpAndSettle();
  if (!confirm) {
    await tester.longPress(selectOrder);
  } else {
    await tester.tap(selectOrder);
    await tester.pumpAndSettle();
    await tester.tap(confirmOrder);
    await tester.pumpAndSettle();
  }
  await tester.pumpAndSettle(Duration(seconds: 1));
}
