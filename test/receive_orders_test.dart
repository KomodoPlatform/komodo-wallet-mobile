import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/startup_provider.dart';
import 'package:komodo_dex/screens/dex/trade/receive_orders.dart';



class CexProviderMock extends Mock implements CexProvider {}
class AddressBookProviderMock extends Mock implements AddressBookProvider {}
class OrderBookProviderMock extends Mock implements OrderBookProvider {}
class StartupProviderMock extends Mock implements StartupProvider {}


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
    CexProvider cexProvider;
    AddressBookProvider addressBookProvider;
    StartupProvider startupProvider;


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
                create: (mContext) => orderBookProvider,
                dispose: (mContext, value) => {
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
    await tester.pumpAndSettle();
  }
    


  testWidgets('Test if title exists', (WidgetTester tester) async  {
    await tester.runAsync(() async {  
      final List<Orderbook> orderbooks = await loadOrderbooks();

      await createWidget(tester, ReceiveOrders(orderbooks: orderbooks));

      final Finder titleFinder = 
        find.text(AppLocalizations.of(mContext).receiveLower);
      print('\n');
      print('\n');
      print('---------------- debugPrints -------------');
      debugPrint(titleFinder.description);
      debugPrint(titleFinder.toString());
      print('---------------- debugPrints -------------');
      print('\n');
      print('\n');
      expect(titleFinder, findsOneWidget);

    });
  });

  testWidgets('Test if search exists', (WidgetTester tester) async  {
    await tester.runAsync(() async {  
      final List<Orderbook> orderbooks = await loadOrderbooks();

      await createWidget(tester, ReceiveOrders(orderbooks: orderbooks));

      final Finder searchForTicker = 
        find.text('Search for Ticker');
      print('\n');
      print('\n');
      print('---------------- debugPrints -------------');
      debugPrint(searchForTicker.description);
      print('-----------------------------');
      print('\n');
      print('\n');
      expect(searchForTicker, findsOneWidget);

    });
  });

  testWidgets('Test if widget have list coins', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final List<Orderbook> orderbooks = await loadOrderbooks();
      await createWidget(tester, ReceiveOrders(orderbooks: orderbooks));

      for (Orderbook orderbook in orderbooks) {
        final Finder iconFinder =
            find.byKey(Key('orderbook-item-${orderbook.rel.toLowerCase()}'));

        print('\n');
        print('\n');
        print('---------------- debugPrints -------------');
        debugPrint(iconFinder.description);
        debugPrint(iconFinder.toString());
        print('---------------- debugPrints -------------');
        print('\n');
        print('\n');

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
      CexProvider cexProvider;
      AddressBookProvider addressBookProvider;
      StartupProvider startupProvider;

      await createWidget(
        tester,
        ChangeNotifierProvider<StartupProvider>(
          create: (context) => startupProvider,
          child: ChangeNotifierProvider<CexProvider>(
            lazy: false,
            create: (context) => cexProvider,
            child: ChangeNotifierProvider<AddressBookProvider>(
              lazy: false,
              create: (context) => addressBookProvider,
              child: AsksOrder(
                sellAmount: 10.0,
                baseCoin: 'MORTY',
              ),
            )
          ) 
        )
      );

      final Finder asksTitle = find.byType(Image);
      final Finder anotherTitle = find.text(AppLocalizations.of(mContext).receiveLower);

      print('\n');
      print('\n');
      print('---------------- debugPrints -------------');
      debugPrint(asksTitle.description);
      debugPrint(anotherTitle.description);
      print('---------------- debugPrints -------------');
      print('\n');
      print('\n');
      
      
      expect(asksTitle, findsOneWidget);
      expect(anotherTitle, findsOneWidget);
    });
  });



  testWidgets('Test if asks list have 0 orders', (WidgetTester tester) async {
    await tester.runAsync(() async {


      await createWidget(
        tester,
        ChangeNotifierProvider<StartupProvider>(
          create: (context) => startupProvider,
          child:ChangeNotifierProvider<CexProvider>(
            lazy: false,
            create: (context) => cexProvider,
            child: ChangeNotifierProvider<AddressBookProvider>(
              lazy: false,
              create: (context) => addressBookProvider,
              child:  const AsksOrder(
                sellAmount: 10.0,
                baseCoin: 'BTC',
              ),
            ),
          )
        )
      );

      expect(find.byKey(const Key('ask-item-0')), findsNothing);

    });
  });

}