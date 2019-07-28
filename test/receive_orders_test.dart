import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/trade/receive_orders.dart';

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
        return Scaffold(body: widgetToTest);
      }),
    ));
    await tester.idle();
    await tester.pump();
  }

  testWidgets('Test if title exist', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await createWidget(
          tester, ReceiveOrders(orderbooks: await loadOrderbooks()));

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
          ));

      final Finder titleFinder =
          find.text(AppLocalizations.of(mContext).receiveLower);
      expect(titleFinder, findsOneWidget);
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
          ));

      expect(find.byKey(const Key('ask-item-0')), findsNothing);
    });
  });

  testWidgets('Test if asks list have 3 orders', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final List<Orderbook> orderbooks = await loadOrderbooks();
      final Orderbook orderbook = orderbooks
          .where((Orderbook orderbook) => orderbook.base == 'MORTY')
          .toList()
          .first;
      const double sellAmount = 10.0;

      await createWidget(
          tester, AsksOrder(asks: orderbook.asks, sellAmount: sellAmount));

      for (int i = 0; i < orderbook.asks.length; i++) {
        expect(find.byKey(Key('ask-item-$i')), findsOneWidget);
        expect(find.byType(Image), findsNWidgets(3));
      }

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
      expect(find.text(AppLocalizations.of(mContext).noOrderAvailable),
          findsOneWidget);
    });
  });
}
