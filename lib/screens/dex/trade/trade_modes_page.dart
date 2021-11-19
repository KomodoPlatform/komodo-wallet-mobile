import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/screens/dex/trade/multi/multi_order_page.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_page.dart';
import 'package:komodo_dex/screens/dex/trade/simple/trade_page_simple.dart';

class TradeModesPage extends StatefulWidget {
  @override
  _TradeModesPageState createState() => _TradeModesPageState();
}

class _TradeModesPageState extends State<TradeModesPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        SizedBox(height: 8),
        _buildView(),
      ],
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
