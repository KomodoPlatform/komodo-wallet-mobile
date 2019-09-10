import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/trade/receive_orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  BuildContext mContext;

  Future<List<Orderbook>> loadOrderbooks() async {
    try {
      return orderbooksFromJson(await rootBundle
          .loadString('assets/mocks/data_orders_book_mock.json'));
    } catch (exception) {
      return null;
    }
  }

  Future<void> createWidget(WidgetTester tester, Widget widgetToTest) async {
    SharedPreferences.setMockInitialValues(<String, dynamic>{});
    const Locale locale = Locale('en');

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      locale: locale,
      home: Builder(builder: (BuildContext context) {
        mContext = context;
        return widgetToTest;
      }),
    ));
    await tester.idle();
    await tester.pump();
  }

  testWidgets('Test if title exist', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final List<Orderbook> ordersMock = await loadOrderbooks();
      await createWidget(
          tester, ReceiveOrders(orderbooks: ordersMock));

      final Finder titleFinder =
          find.text(AppLocalizations.of(mContext).receiveLower);
      expect(titleFinder, findsOneWidget);
    });
  });

  testWidgets('Test if widget have list coins', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final List<Orderbook> orderbooks = await loadOrderbooks();
      await createWidget(tester, ReceiveOrders(orderbooks: orderbooks));

      for (Orderbook orderbook in orderbooks) {
        final Finder iconFinder =
            find.byKey(Key('orderbook-item-${orderbook.base.toLowerCase()}'));
        expect(iconFinder, findsOneWidget);
        expect(find.byType(Image), findsWidgets);

        if (orderbook.asks.isEmpty) {
          expect(find.text(AppLocalizations.of(mContext).noOrderAvailable),
              findsOneWidget);
        }
      }
    });
  });

  testWidgets('Test if asks list have title', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final List<Orderbook> orderbooks = await loadOrderbooks();
      final Orderbook orderbook = orderbooks
          .where((Orderbook orderbook) => orderbook.base == 'MORTY')
          .toList()
          .first;

      await createWidget(
          tester,
          AsksOrder(
            asks: orderbook.asks,
            sellAmount: 10.0,
            baseCoin: 'MORTY',
          ));

      expect(find.byType(Image), findsOneWidget);
    });
  });

  testWidgets('Test if asks list have 0 orders', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final List<Orderbook> orderbooks = await loadOrderbooks();
      final Orderbook orderbook = orderbooks
          .where((Orderbook orderbook) => orderbook.base == 'BTC')
          .toList()
          .first;

      await createWidget(
          tester,
          AsksOrder(
            asks: orderbook.asks,
            sellAmount: 10.0,
            baseCoin: 'BTC',
          ));

      expect(find.byKey(const Key('ask-item-0')), findsNothing);
    });
  });
}
