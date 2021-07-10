import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';
import 'package:komodo_dex/screens/dex/multi/multi_order_page.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_page.dart';
import 'package:komodo_dex/screens/dex/trade/simple/trade_page_simple.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';

class DexPage extends StatefulWidget {
  @override
  _DexPageState createState() => _DexPageState();
}

class _DexPageState extends State<DexPage> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    ordersBloc.updateOrdersSwaps();

    swapBloc.outIndexTab.listen((int onData) {
      if (mounted) setState(() => tabController.index = onData);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            tabs: <Widget>[
              Tab(text: 'SIMPLE'),
              Tab(text: 'PRO'),
              Tab(
                text: AppLocalizations.of(context).multiTab.toUpperCase(),
              ),
              Tab(text: AppLocalizations.of(context).orders.toUpperCase()),
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
                automaticallyImplyLeading: false,
              ),
            )
          : AppBar(
              title: Center(
                  child: Text(
                AppLocalizations.of(context).exchangeTitle,
                key: const Key('exchange-title'),
                style: Theme.of(context).textTheme.subtitle2,
              )),
              bottom: PreferredSize(
                preferredSize: const Size(200.0, 70.0),
                child: Column(
                  children: <Widget>[
                    _tabsPanel,
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              automaticallyImplyLeading: false,
            );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: _buildAppBar(),
          backgroundColor: Theme.of(context).backgroundColor,
          body: Builder(builder: (BuildContext context) {
            return TabBarView(
              controller: tabController,
              children: <Widget>[
                TradePageSimple(),
                TradePage(),
                MultiOrderPage(),
                OrdersPage(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
