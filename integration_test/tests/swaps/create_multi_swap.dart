import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';

Future<void> createMultiSwap(WidgetTester tester) async {
  final Finder dexMenu = find.byKey(const Key('main-nav-dex'));
  final Finder multiTabBtn = find.byKey(const Key('multi-tab'));

  final Finder nextBtn = find.byKey(const Key('create-multi-order'));
  final Finder startSwapBtn = find.byKey(Key('confirm-create-multi-order'));
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
    await tester.tap(multiTabBtn);
    await tester.pumpAndSettle();
    expect(
      find.byType(DexPage),
      findsOneWidget,
      reason: 'Screen is not on the Dex page',
    );

    // sell aspect
    await _sellAspect(tester, amount: '0.1');

    // receive aspect
    await _receiveAspect(tester);

    // proceed and confirm order
    await tester.tap(nextBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(startSwapBtn);
    await tester.pumpAndSettle();
    expect(
      find.byType(OrdersPage),
      findsOneWidget,
      reason: 'Screen is not on the Orders page',
    );
    expect(
      tester.widgetList<ListView>(activeOrderList).length,
      1,
      reason: 'Order was not created',
    );
    // Order has been created
  } catch (e) {
    print(e);
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

Future<void> _receiveAspect(WidgetTester tester) async {
  final Finder enableRick = find.byKey(const Key('coin-select-buy-rick'));
  final Finder enableTqtum = find.byKey(const Key('coin-select-buy-tqtum'));
  final Finder buyRickAmount = find.byKey(const Key('input-text-buy-rick'));
  final Finder buyTqtumAmount = find.byKey(const Key('input-text-buy-tqtum'));

  await tester.tap(enableRick);
  await tester.pumpAndSettle();
  await tester.enterText(buyRickAmount, '0.1');
  await tester.pumpAndSettle();

  await tester.tap(enableTqtum);
  await tester.pumpAndSettle();
  await tester.enterText(buyTqtumAmount, '0.3');
  await tester.pumpAndSettle();
}
