import 'package:flutter/material.dart';
import 'package:komodo_dex/generic_blocs/main_bloc.dart';
import 'package:komodo_dex/generic_blocs/orders_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/multi/multi_order_page.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_page.dart';
import 'package:komodo_dex/screens/dex/trade/simple/trade_page_simple.dart';
import 'package:komodo_dex/screens/dex/trade/trade_modes_page.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

Map<TradeMode, int> _tradeModeTabs = {
  TradeMode.Simple: 0,
  TradeMode.Advanced: 1,
  TradeMode.Multi: 2,
};

class DexPage extends StatefulWidget {
  @override
  State<DexPage> createState() => _DexPageState();
}

class _DexPageState extends State<DexPage> {
  @override
  void initState() {
    super.initState();

    ordersBloc.updateOrdersSwaps();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      TradeMode.values.length == _tradeModeTabs.length,
      'Ensure there is a tab for each trade mode',
    );

    return Scaffold(
      key: ValueKey('dex_page_scaffold'),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        key: ValueKey('dex_page_appbar'),
        elevation: 4,
        title: Text(AppLocalizations.of(context)!.swap.toSentenceCase()),
        automaticallyImplyLeading: true,
        // actions: [TradeModeSelector()],
      ),
      body: true
          ? IndexedStack(
              sizing: StackFit.passthrough,
              index: _tradeModeTabs[mainBloc.tradeModeEnum],
              children: [
                TradePageSimple(),
                TradePage(),
                MultiOrderPage(),
              ],
            )
          : Column(
              children: [
                TradeModeSelector(),
                IndexedStack(
                  sizing: StackFit.passthrough,
                  index: _tradeModeTabs[mainBloc.tradeModeEnum],
                  children: [
                    TradePageSimple(),
                    TradePage(),
                    MultiOrderPage(),
                  ],
                ),
              ],
            ),
    );
  }
}

class TradeModeSelector extends StatelessWidget {
  const TradeModeSelector({super.key});

  void _setSelectedIndex(int index) {
    mainBloc.setTradeMode(TradeMode.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    final tradeModeEnum = context.select<MainBloc, TradeMode>(
      (mainBloc) => mainBloc.tradeModeEnum,
    );

    final activeIndex = _tradeModeTabs[tradeModeEnum] ?? 0;

    final selectedStates = List<bool>.generate(
      _tradeModeTabs.length,
      (index) => index == activeIndex,
    );

    return Card(
      // color: Theme.of(context).colorScheme.secondaryContainer,
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(16),
        isSelected: selectedStates,
        onPressed: _setSelectedIndex,
        children: [
          Text('Simple'),
          Text('Advanced'),
          Text(AppLocalizations.of(context)!.multiTab),
        ],
      ),
    );
  }

  // List
}
