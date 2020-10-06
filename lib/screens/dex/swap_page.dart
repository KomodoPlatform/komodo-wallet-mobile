import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';
import 'package:komodo_dex/screens/dex/trade/multi_order_create.dart';
import 'package:komodo_dex/screens/dex/trade/trade_page.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';

class SwapPage extends StatefulWidget {
  const SwapPage({this.activeTabIndex = 0});

  final int activeTabIndex;

  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    ordersBloc.updateOrdersSwaps();

    swapBloc.outIndexTab.listen((int onData) {
      setState(() {
        tabController.index = onData;
      });
    });
    setState(() {
      tabController.index = widget.activeTabIndex;
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
              Tab(
                text: AppLocalizations.of(context).create.toUpperCase(),
              ),
              Tab(text: AppLocalizations.of(context).orders.toUpperCase()),
              const Tab(
                // TODO(yurii): localization
                text: 'MULTI',
              ),
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
              ),
              automaticallyImplyLeading: false,
            );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: _buildAppBar(),
          backgroundColor: Theme.of(context).backgroundColor,
          body: Builder(builder: (BuildContext context) {
            return TabBarView(
              controller: tabController,
              children: <Widget>[
                TradePage(
                  mContext: context,
                ),
                OrdersPage(),
                MultiOrderCreate(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
