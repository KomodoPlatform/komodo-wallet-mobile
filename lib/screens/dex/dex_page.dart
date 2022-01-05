import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/orders/orders_page.dart';
import 'package:komodo_dex/screens/dex/trade/trade_mode_indicator.dart';
import 'package:komodo_dex/screens/dex/trade/trade_modes_page.dart';
import 'package:komodo_dex/utils/custom_tab_indicator.dart';
import 'package:komodo_dex/utils/utils.dart';

class DexPage extends StatefulWidget {
  @override
  _DexPageState createState() => _DexPageState();
}

class _DexPageState extends State<DexPage> with TickerProviderStateMixin {
  TabController tabController;
  TabController _tradeTabController;
  bool _showTradeMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _showTradeMode = tabController.index == 0;
      });
    });

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        _showTradeMode = tabController.index == 0;
      });
    });

    ordersBloc.updateOrdersSwaps();

    swapBloc.outIndexTab.listen((int onData) {
      if (mounted) setState(() => tabController.index = onData);
    });

    _tradeTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: mainBloc.tradeMode,
    );
    _tradeTabController.addListener(() {
      mainBloc.tradeMode = _tradeTabController.index;
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

      return AppBar(
        title: _tabsPanel,
        bottom: _showTradeMode ? _buildModeSwitcher() : null,
        automaticallyImplyLeading: false,
      );
    }

    return GestureDetector(
      onTap: () {
        unfocusTextField(context);
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

  // TODO(MRC): Cosnider moving this to its own widget
  // I had to move it here so to try to properly integrate it with the app bar
  // by using its "bottom" porperty, otherwise I wouldn't be able to make it
  // have the same color as the app bar

  Widget _buildModeSwitcher() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
                child: Text(
              'Trading Mode:',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            )),
            Flexible(
              flex: 2,
              child: TabBar(
                controller: _tradeTabController,
                indicator: TradeModeIndicator(context: context),
                labelPadding: EdgeInsets.symmetric(horizontal: 0),
                indicatorPadding: EdgeInsets.symmetric(horizontal: 0),
                tabs: [
                  Tab(text: 'Simple'),
                  Tab(text: 'Advanced'),
                  Tab(text: AppLocalizations.of(context).multiTab),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
