import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';
import 'package:komodo_dex/screens/dex/trade/trade_modes_page.dart';
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
              Tab(text: 'Swap'.toUpperCase()),
              Tab(text: AppLocalizations.of(context).orders.toUpperCase()),
            ],
          ),
        ),
      );

      return PreferredSize(
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
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _buildAppBar(),
          backgroundColor: Theme.of(context).backgroundColor,
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
