import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/main.dart';
import 'package:komodo_dex/screens/dex/dex_page.dart';
import 'package:komodo_dex/screens/dex/trade/simple/confirm/swap_confirmation_page_simple.dart';

Future<void> createSimpleSwap(WidgetTester tester) async {
  final Finder dexMenu = find.byKey(const Key('main-nav-dex'));
  final Finder simpleNextBtn = find.byKey(const Key('trade-button-simple'));
  final Finder startSwapBtn = find.byKey(Key('confirm-simple-swap-button'));
  final Finder sellMortyCoin = find.byKey(const Key('sell-MORTY'));
  final Finder amountField = find.byKey(const Key('amount-field'));
  final Finder buyRickCoin = find.byKey(const Key('sell-RICK-top-order'));
  final Finder backBtn = find.byTooltip('Back');
  final Finder orderTabBtn = find.byKey(const Key('orders-tab'));
  final Finder simpleTabBtn = find.byKey(const Key('simple-tab'));
  try {
    // Press dex menu
    expect(
      find.byType(MyHomePage),
      findsOneWidget,
      reason: 'Screen is not on the Home page',
    );
    await tester.tap(dexMenu);
    await tester.pumpAndSettle();
    await tester.tap(simpleTabBtn);
    await tester.pumpAndSettle();
    expect(
      find.byType(DexPage),
      findsOneWidget,
      reason: 'Screen is not on the Dex page',
    );

    // sell aspect
    await tester.tap(sellMortyCoin);
    await tester.pumpAndSettle();
    // Enter 0.1 morty
    await tester.enterText(amountField, '0.1');
    await tester.pumpAndSettle();
    await tester.tap(buyRickCoin);
    await tester.pumpAndSettle();
    await tester.tap(simpleNextBtn);
    await tester.pumpAndSettle();
    expect(
      find.byType(SwapConfirmationPageSimple),
      findsOneWidget,
      reason: 'Screen is not on the Swap Confirmation Page',
    );
    await tester.tap(startSwapBtn);
    await tester.pumpAndSettle();
    await tester.tap(backBtn);
    await tester.pumpAndSettle();
    await tester.tap(orderTabBtn);
    await tester.pumpAndSettle();
    // Order has been created
  } catch (e) {
    print(e?.message ?? e);
    rethrow;
  }
}
