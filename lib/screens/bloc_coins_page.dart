import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/coin_detail.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/utils/bottom_wave_clipper.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BlocCoinsPage extends StatefulWidget {
  @override
  _BlocCoinsPageState createState() => _BlocCoinsPageState();
}

class _BlocCoinsPageState extends State<BlocCoinsPage> {
  @override
  Widget build(BuildContext context) {
    double _heightScreen = MediaQuery.of(context).size.height; 
    final CoinsBloc coinsBloc = BlocProvider.of<CoinsBloc>(context);
    coinsBloc.updateBalanceForEachCoin();

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: BottomWaveClipper(),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              stops: [0.01, 1],
              colors: [
                Color.fromRGBO(39, 71, 110, 1),
                Theme.of(context).accentColor,
              ],
            )),
            height: _heightScreen * 0.4,
          ),
        ),
        Align(
            alignment: Alignment.topCenter,
            child: Padding(
                padding: EdgeInsets.only(top: _heightScreen * 0.12, left: 16, right: 16),
                child: AutoSizeText(
                  "\$156,125.91 USD",
                  style: Theme.of(context).textTheme.headline,
                  maxLines: 1,
                ))),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: _heightScreen * 0.3),
            child: Container(
              child: StreamBuilder<List<CoinBalance>>(
                stream: coinsBloc.outCoins,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ItemCoin(
                              index: index, listCoinBalances: snapshot.data);
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ItemCoin extends StatelessWidget {
  const ItemCoin(
      {Key key, @required this.listCoinBalances, @required this.index})
      : super(key: key);

  final List<CoinBalance> listCoinBalances;
  final int index;

  @override
  Widget build(BuildContext context) {
    double _heightScreen = MediaQuery.of(context).size.height;
    double _heightCard = _heightScreen * 0.15;
    Coin coin = listCoinBalances[index].coin;
    Balance balance = listCoinBalances[index].balance;

    return Card(
      elevation: 8,
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CoinDetail(listCoinBalances[index])),
          );
        },
        child: Container(
          height: _heightScreen * 0.15,
          child: Row(
            children: <Widget>[
              SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: _heightCard * 0.25,
                    backgroundImage: NetworkImage(
                        "https://raw.githubusercontent.com/jl777/coins/master/icons/${balance.coin.toLowerCase()}.png"),
                  ),
                  SizedBox(height: 6),
                  Text(
                    coin.name.toUpperCase(),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "${balance.balance.toString()} ${coin.abbr}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        "\$${(balance.balance * 1.3).toStringAsFixed(2)} USD",
                        style: Theme.of(context).textTheme.body2,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
