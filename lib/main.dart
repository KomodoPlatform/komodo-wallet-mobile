import 'package:flutter/material.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/coin_detail.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<CoinBalance> listCoinElectrum = new List<CoinBalance>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CoinBalance>>(
        future: MarketMakerService().loadCoins(),
        builder: (context, snapshot) {
          if ((snapshot.hasData &&
              !(snapshot.connectionState == ConnectionState.waiting)) || listCoinElectrum.length > 0) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  listCoinElectrum = snapshot.data;
                  Coin item = snapshot.data[index].coin;
                  Balance balance = snapshot.data[index].balance;

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CoinDetail(snapshot.data[index])),
                      );
                    },
                    leading: Text(balance.balance.toString()),
                    title: Text(
                      item.name,
                      style: Theme.of(context).textTheme.headline,
                    ),
                  );
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
