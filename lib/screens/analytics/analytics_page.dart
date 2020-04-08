import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/analytics/coins_price_list.dart';
import 'package:komodo_dex/screens/analytics/order_book.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  TabController tabController;
  Coin _buyCoin;
  Coin _sellCoin;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          title: Center(
              child: Text(
            'ANALYTICS', // TODO(yurii): localization
            key: const Key('analytics-title'),
            style: Theme.of(context).textTheme.subtitle,
          )),
          bottom: PreferredSize(
            preferredSize: const Size(200.0, 70.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    border: Border.all(color: Colors.grey, width: 1)),
                child: TabBar(
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  indicator: CustomTabIndicator(context: context),
                  controller: tabController,
                  tabs: const <Widget>[
                    Tab(
                      text: 'PRICE', // TODO(yurii): localization
                    ),
                    Tab(
                      text: 'ORDER BOOK', // TODO(yurii): localization
                    )
                  ],
                ),
              ),
            ),
          )),
      body: Builder(builder: (BuildContext context) {
        return TabBarView(
          controller: tabController,
          children: <Widget>[
            CoinsPriceList(onItemTap: (Coin coin) {
              print(coin.abbr);
              setState(() {
                _buyCoin = coin;
                _sellCoin = null;
              });
              tabController.index = 1;
            }),
            OrderBook(
              buyCoin: _buyCoin,
              sellCoin: _sellCoin,
              onPairChange: (CoinsPair coinsPair) {
                setState(() {
                  _buyCoin = coinsPair.buy ?? _buyCoin;
                  _sellCoin = coinsPair.sell ?? _sellCoin;
                });
              },
            ),
          ],
        );
      }),
    );
  }
}

class CoinsPair {
  CoinsPair({
    this.buy,
    this.sell,
  });

  Coin buy;
  Coin sell;
}