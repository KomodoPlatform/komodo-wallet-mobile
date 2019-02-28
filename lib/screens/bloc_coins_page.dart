import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/coin_detail.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';

class BlocCoinsPage extends StatefulWidget {
  @override
  _BlocCoinsPageState createState() => _BlocCoinsPageState();
}

class _BlocCoinsPageState extends State<BlocCoinsPage> {
  ScrollController _scrollController;
  double _heightFactor = 7;

  _scrollListener() {
    setState(() {
      _heightFactor = (exp(-_scrollController.offset / 60) * 6) + 1;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    coinsBloc.updateBalanceForEachCoin(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _heightScreen = MediaQuery.of(context).size.height;
    double _widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                actions: <Widget>[
                  GestureDetector(
                    onTap: () {
                      coinsBloc.updateBalanceForEachCoin(true);
                    },
                    child: Icon(
                        Icons.refresh
                    ),
                  )
                ],
                backgroundColor: Theme.of(context).backgroundColor,
                expandedHeight: _heightScreen * 0.35,
                pinned: true,
                flexibleSpace: Builder(
                  builder: (context) {
                    return FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        centerTitle: true,
                        title: Container(
                          width: _widthScreen * 0.5,
                          child: Center(
                            heightFactor: _heightFactor,
                            child: AutoSizeText(
                              "\$156,125,123.91 USD",
                              style: Theme.of(context).textTheme.title,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        background: Container(
                          child: Padding(
                            padding: EdgeInsets.only(top: _heightScreen * 0.23),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                LoadAsset(),
                                SizedBox(
                                  height: 14,
                                ),
                                BarGraph()
                              ],
                            ),
                          ),
                          height: _heightScreen * 0.35,
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
                        ));
                  },
                ),
              ),
            ];
          },
          body: Container(
              color: Theme.of(context).backgroundColor, child: ListCoins())),
    );
  }
}

class BarGraph extends StatefulWidget {
  @override
  BarGraphState createState() {
    return new BarGraphState();
  }
}

class BarGraphState extends State<BarGraph> {

  @override
  Widget build(BuildContext context) {
    double _widthScreen = MediaQuery.of(context).size.width;
    double _widthBar = _widthScreen - 32;

    return StreamBuilder<List<CoinBalance>>(
      stream: coinsBloc.outCoins,
      builder: (context, snapshot) {
        bool _isVisible = true;

        if (snapshot.hasData) {
          _isVisible = true;
        } else {
          _isVisible = false;
        }

        List<Container> barItem = List<Container>();

        if (snapshot.hasData) {
          double sumOfAllBalances = 0;

          snapshot.data.forEach((coinBalance){
            sumOfAllBalances += coinBalance.balance.balance;
          });

          snapshot.data.forEach((coinBalance){
            if (coinBalance.balance.balance > 0) {
              barItem.add(Container(
                color: Color(int.parse(coinBalance.coin.colorCoin)),
                width: _widthBar * (((coinBalance.balance.balance * 100) / sumOfAllBalances) / 100),
              ));
            }
          });
        }

        return AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Container(
              width: _widthBar,
              height: 16,
              child: Row(
                children: barItem,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadAsset extends StatefulWidget {
  const LoadAsset({
    Key key,
  }) : super(key: key);

  @override
  LoadAssetState createState() {
    return new LoadAssetState();
  }
}

class LoadAssetState extends State<LoadAsset> {
  @override
  void initState() {
    coinsBloc.updateBalanceForEachCoin(false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      stream: coinsBloc.outCoins,
      builder: (context, snapshot) {
        List<Widget> listRet = List<Widget>();
        if (snapshot.hasData) {
          int assetNumber = 0;

          snapshot.data.forEach((coinBalance) {
            if (coinBalance.balance.balance > 0) {
              assetNumber++;
            }
          });

          listRet.add(Icon(
            Icons.show_chart,
            color: Colors.white.withOpacity(0.8),
          ));
          listRet.add(Text(
            "${assetNumber.toString()} Assets",
            style: Theme.of(context).textTheme.caption,
          ));
          listRet.add(Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.8),
          ));
        } else {
          listRet.add(Container(
              height: 10,
              width: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.0,
              )));
        }
        return Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: listRet,
          ),
        );
      },
    );
  }
}

class ListCoins extends StatefulWidget {
  const ListCoins({
    Key key,
  }) : super(key: key);

  @override
  ListCoinsState createState() {
    return new ListCoinsState();
  }
}

class ListCoinsState extends State<ListCoins> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      stream: coinsBloc.outCoins,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.length > 0) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ItemCoin(index: index, listCoinBalances: snapshot.data);
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ItemCoin extends StatelessWidget {
  const ItemCoin({Key key, @required this.listCoinBalances, @required this.index})
      : super(key: key);

  final List<CoinBalance> listCoinBalances;
  final int index;

  @override
  Widget build(BuildContext context) {
    double _heightScreen = MediaQuery.of(context).size.height;
    Coin coin = listCoinBalances[index].coin;
    Balance balance = listCoinBalances[index].balance;

    return Card(
      elevation: 8,
      color: Theme.of(context).primaryColor,
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
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
                  PhotoHero(
                    url:
                    "https://raw.githubusercontent.com/jl777/coins/master/icons/${balance.coin.toLowerCase()}.png",
                  ),
                  SizedBox(height: 6),
                  Text(
                    coin.name.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
                child: Container(
                  color: Color(int.parse(coin.colorCoin)),
                  width: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
