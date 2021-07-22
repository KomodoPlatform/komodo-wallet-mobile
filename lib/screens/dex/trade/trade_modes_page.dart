import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/multi/multi_order_page.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_page.dart';
import 'package:komodo_dex/screens/dex/trade/simple/trade_page_simple.dart';
import 'package:komodo_dex/screens/dex/trade/trade_mode_indicator.dart';

class TradeModesPage extends StatefulWidget {
  @override
  _TradeModesPageState createState() => _TradeModesPageState();
}

class _TradeModesPageState extends State<TradeModesPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: mainBloc.tradeMode,
    );
    _tabController.addListener(() {
      mainBloc.tradeMode = _tabController.index;
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        _buildModeSwitcher(),
        SizedBox(height: 8),
        _buildView(),
      ],
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          SizedBox(width: 16),
          Expanded(
              child: Text(
            'Trading Mode:',
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
          )),
          Flexible(
            flex: 2,
            child: TabBar(
              controller: _tabController,
              indicator: TradeModeIndicator(context: context),
              labelStyle: Theme.of(context).textTheme.caption,
              labelPadding: EdgeInsets.symmetric(horizontal: 0),
              indicatorPadding: EdgeInsets.symmetric(horizontal: 0),
              tabs: [
                Tab(text: 'Simple'),
                Tab(text: 'Advanced'),
                Tab(
                  text: AppLocalizations.of(context).multiTab,
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildView() {
    final List<Widget> views = [
      TradePageSimple(),
      TradePage(),
      MultiOrderPage(),
    ];
    return StreamBuilder<int>(
      initialData: mainBloc.tradeMode,
      stream: mainBloc.outTradeMode,
      builder: (context, snapshot) {
        return Flexible(child: views[snapshot.data]);
      },
    );
  }
}
