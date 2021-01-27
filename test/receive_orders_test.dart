import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/startup_provider.dart';
import 'package:komodo_dex/screens/dex/trade/receive_orders.dart';
import 'package:provider/provider.dart';
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
    OrderBookProvider orderBookProvider;

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: 
        <LocalizationsDelegate<dynamic>>[
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
      ],
      locale: locale,
      home: Builder(builder: 
          (BuildContext context) {
            mContext = context;
            return Provider<OrderBookProvider>(
                lazy: false,
                create: (context) => orderBookProvider,
                dispose: (context, value) => {
                  if (value != null){
                    value.dispose()
                  }
                },
                child: widgetToTest,
            ); 
          },
        )
      )
    );
    await tester.idle();
    await tester.pump();
  }
    


  testWidgets('Test if title exists', (WidgetTester tester) async  {
    await tester.runAsync(() async {  
      final List<Orderbook> orderbooks = await loadOrderbooks();

      await createWidget(tester, ReceiveOrders(orderbooks: orderbooks));

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
            find.byKey(Key('orderbook-item-${orderbook.rel.toLowerCase()}'));
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
      await createWidget(
        tester,
        ChangeNotifierProvider<CexProvider>(
          lazy: false,
          create: (context) => CexProvider(true),
          child: ListenableProvider<AddressBookProvider>(
            lazy: false,
            create: (context) => AddressBookProvider(),
            child: AsksOrder(
              sellAmount: 10.0,
              baseCoin: 'MORTY',
            ),
          )
        ) 
      );
    });
    
      expect(find.byType(Image), findsOneWidget);
    });



  testWidgets('Test if asks list have 0 orders', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await createWidget(
        tester,
        ChangeNotifierProvider<CexProvider>(
          lazy: false,
          create: (mContext) => CexProvider(),
          child: ListenableProvider<AddressBookProvider>(
            lazy: false,
            create: (mContext) => AddressBookProvider(),
            child:  const AsksOrder(
            sellAmount: 10.0,
            baseCoin: 'BTC',
          ),
        ),
      ));

      expect(find.byKey(const Key('ask-item-0')), findsNothing);
    });
  });

}