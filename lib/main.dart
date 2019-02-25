import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coin_json_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/orderbook_bloc.dart';
import 'package:komodo_dex/screens/bloc_coins_page.dart';
import 'package:komodo_dex/screens/bloc_market_page.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoinsBloc>(
      bloc: CoinsBloc(),
      child: BlocProvider<OrderbookBloc>(
        bloc: OrderbookBloc(),
        child: BlocProvider<CoinJsonBloc>(
          bloc: CoinJsonBloc(),
          child: MaterialApp(
            title: 'Komodo DEX',
            theme: ThemeData(
              primaryColor: Color.fromRGBO(42, 54, 71, 1),
              backgroundColor: Color.fromRGBO(30, 42, 58, 1),
              primaryColorDark: Color.fromRGBO(42, 54, 71, 1),
              accentColor: Color.fromRGBO(65, 234, 213, 1),
              textSelectionColor: Colors.white,
              dialogBackgroundColor: Color.fromRGBO(42, 54, 71, 1),
              fontFamily: 'Ubuntu',
              textTheme: TextTheme(
                  headline: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  title: TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  subtitle: TextStyle(fontSize: 18.0, color: Colors.white),
                  body1: TextStyle(fontSize: 16.0, color: Colors.white),
                  body2: TextStyle(
                      fontSize: 14.0, color: Colors.white.withOpacity(0.5)),
                  caption: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400)),
            ),
            home: MyHomePage(title: 'Komodo DEX'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    BlocCoinsPage(),
    BlocMarketPage(),
    BlocCoinsPage()
  ];

  @override
  Widget build(BuildContext context) {
    final CoinsBloc coinsBloc = BlocProvider.of<CoinsBloc>(context);
    final OrderbookBloc orderbookBloc = BlocProvider.of<OrderbookBloc>(context);
    final CoinJsonBloc coinJsonBloc = BlocProvider.of<CoinJsonBloc>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _children[_currentIndex],
      bottomNavigationBar: Material(
        elevation: 8.0,
        child: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).primaryColor,
              primaryColor: Theme.of(context).accentColor,
              textTheme: Theme.of(context).textTheme.copyWith(
                  caption: new TextStyle(
                      color: Theme.of(context)
                          .textSelectionColor
                          .withOpacity(0.5)))),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: onTabTapped,
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  title: Text("Portfolio")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart), title: Text("Market")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), title: Text("Settings")),
            ],
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
