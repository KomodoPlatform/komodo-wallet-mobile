import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/screens/markets/coins_price_list.dart';
import 'package:komodo_dex/screens/markets/order_book_page.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';
import 'package:provider/provider.dart';

class MarketsPage extends StatefulWidget {
  @override
  _MarketsPageState createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage>
    with TickerProviderStateMixin {
  TabController tabController;
  bool init = false;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    final CoinsPair _activePair = _orderBookProvider.activePair;

    if (!init && (_activePair?.buy != null || _activePair?.sell != null)) {
      tabController.index = 1;
    }
    init = true;

    Widget _buildAppBar() {
      final bool _isSmallScreen = MediaQuery.of(context).size.height < 680;

      final Widget _tabsPanel = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
      );

      return _isSmallScreen
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AppBar(
                flexibleSpace: SafeArea(
                    child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    _tabsPanel,
                  ],
                )),
              ),
            )
          : AppBar(
              title: Center(
                  child: Text(
                'MARKETS', // TODO(yurii): localization
                key: const Key('markets-title'),
                style: Theme.of(context).textTheme.subtitle,
              )),
              bottom: PreferredSize(
                preferredSize: const Size(200.0, 70.0),
                child: Column(
                  children: <Widget>[
                    _tabsPanel,
                    const SizedBox(height: 15),
                  ],
                ),
              ));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _buildAppBar(),
      body: Builder(builder: (BuildContext context) {
        return TabBarView(
          controller: tabController,
          children: <Widget>[
            CoinsPriceList(onItemTap: (Coin coin) {
              _orderBookProvider.activePair = CoinsPair(buy: coin, sell: null);
              tabController.index = 1;
            }),
            const OrderBookPage(),
          ],
        );
      }),
    );
  }
}
