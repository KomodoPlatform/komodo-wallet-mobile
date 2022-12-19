import 'package:flutter/material.dart';
import '../../blocs/orders_bloc.dart';
import '../../blocs/swap_bloc.dart';
import '../../localizations.dart';
import '../dex/orders/orders_page.dart';
import '../dex/trade/trade_modes_page.dart';
import '../../utils/custom_tab_indicator.dart';
import '../../utils/utils.dart';

class DexPage extends StatefulWidget {
  @override
  _DexPageState createState() => _DexPageState();
}

class _DexPageState extends State<DexPage> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

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
                text: AppLocalizations.of(context).swap.toUpperCase(),
                key: const Key('swap-tab'),
              ),
              Tab(
                text: AppLocalizations.of(context).orders.toUpperCase(),
                key: const Key('orders-tab'),
              ),
            ],
          ),
        ),
      );

      return AppBar(
        elevation: 4,
        title: _tabsPanel,
        automaticallyImplyLeading: false,
      );
    }

    return GestureDetector(
      onTap: () {
        unfocusEverything();
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(),
          body: Builder(builder: (BuildContext context) {
            return TabBarView(
              controller: tabController,
              children: <Widget>[
                TradeModesPage(),
                OrdersPage(),
              ],
            );
          }),
        ),
      ),
    );
  }
}
