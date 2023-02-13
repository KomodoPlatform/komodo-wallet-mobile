import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';

Future<void> checkTestCoinsInMarket(WidgetTester tester) async {
  final Finder marketsTab = find.byKey(const Key('main-nav-markets'));
  final Finder kmdCoinItem = find.byKey(const Key('coin-KMD'));
  final Finder btcCoinItem = find.byKey(const Key('coin-BTC'));
  final Finder rickCoinItem = find.byKey(const Key('coin-RICK'));
  final Finder mortyCoinItem = find.byKey(const Key('coin-MORTY'));

  try {
    await tester.tap(marketsTab);
    await tester.pumpAndSettle();
    expect(
      find.byType(MarketsPage),
      findsOneWidget,
      reason: 'Screen is not on the Markets page',
    );

    expect(
      find.byType(MarketsPage),
      findsOneWidget,
      reason: 'Screen is not on the Markets page',
    );

    expect(
      kmdCoinItem,
      findsOneWidget,
      reason: 'KMD coin is not in the Markets page',
    );

    expect(
      btcCoinItem,
      findsOneWidget,
      reason: 'BTC coin is not in the Markets page',
    );

    expect(
      rickCoinItem,
      findsNothing,
      reason: 'RICK coin is in the Markets page',
    );

    expect(
      mortyCoinItem,
      findsNothing,
      reason: 'MORTY coin is in the Markets page',
    );
  } catch (e) {
    print(e);
    rethrow;
  }
}
