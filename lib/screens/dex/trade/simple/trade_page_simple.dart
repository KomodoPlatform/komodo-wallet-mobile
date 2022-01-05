import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_button_simple.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_details.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/buy_form.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/coins_list.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/sell_form.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';

class TradePageSimple extends StatefulWidget {
  @override
  _TradePageSimpleState createState() => _TradePageSimpleState();
}

class _TradePageSimpleState extends State<TradePageSimple> {
  final _sellSearchCtrl = TextEditingController();
  final _buySearchCtrl = TextEditingController();
  final _sellFocusNode = FocusNode();
  final _buyFocusNode = FocusNode();
  String _sellSearchTerm = '';
  String _buySearchTerm = '';
  OrderBookProvider _obProvider;
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _obProvider ??= Provider.of<OrderBookProvider>(context);
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    return FutureBuilder<LinkedHashMap<String, Coin>>(
      future: _subscribeDepths(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildProgress();

        return _anyLists()
            ? _buildContent(snapshot.data)
            : SingleChildScrollView(
                child: _buildContent(snapshot.data),
              );
      },
    );
  }

  Widget _buildContent(LinkedHashMap<String, Coin> known) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(),
          Flexible(
            flex: _anyLists() ? 1 : 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSell(known)),
                VerticalDivider(),
                Expanded(child: _buildBuy(known)),
              ],
            ),
          ),
          BuildTradeDetails(),
          SizedBox(height: 16),
          BuildTradeButtonSimple(),
          // BuildResetButtonSimple(),
        ],
      ),
    );
  }

  Widget _buildSell(LinkedHashMap<String, Coin> known) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).simpleTradeSellTitle + ':',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(width: 8),
              _buildSearchField(Market.SELL),
            ],
          ),
          SizedBox(height: 6),
          Expanded(
            flex: _anyLists() ? 1 : 0,
            child: _constrProvider.sellCoin == null
                ? CoinsList(
                    type: Market.SELL,
                    known: known,
                    searchTerm: _sellSearchTerm,
                  )
                : SellForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildBuy(LinkedHashMap<String, Coin> known) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context).simpleTradeBuyTitle + ':',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(width: 8),
              _buildSearchField(Market.BUY),
            ],
          ),
          SizedBox(height: 6),
          Expanded(
            flex: _anyLists() ? 1 : 0,
            child: _constrProvider.buyCoin == null
                ? CoinsList(
                    type: Market.BUY,
                    known: known,
                    searchTerm: _buySearchTerm,
                  )
                : BuyForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<LinkedHashMap<String, Coin>> _subscribeDepths() async {
    final LinkedHashMap<String, Coin> known = await coins;

    final List<Map<String, CoinType>> coinsList = [];
    for (String abbr in known.keys) {
      coinsList.add({abbr: CoinType.base});
      coinsList.add({abbr: CoinType.rel});
    }

    await _obProvider.subscribeDepth(coinsList);
    return known;
  }

  bool _anyLists() {
    if (_constrProvider.buyCoin != null && _constrProvider.sellCoin != null) {
      return false;
    }

    if (_constrProvider.sellCoin != null &&
        (_constrProvider.sellAmount?.toDouble() ?? 0) == 0) {
      return false;
    }

    if (_constrProvider.buyCoin != null &&
        (_constrProvider.buyAmount?.toDouble() ?? 0) == 0) {
      return false;
    }

    return true;
  }

  Widget _buildSearchField(Market type) {
    TextEditingController controller;
    FocusNode focusNode;
    String currentTerm;
    if (type == Market.SELL) {
      if (_constrProvider.sellCoin != null) return SizedBox();

      controller = _sellSearchCtrl;
      focusNode = _sellFocusNode;
      currentTerm = _sellSearchTerm;
    } else {
      if (_constrProvider.buyCoin != null) return SizedBox();

      controller = _buySearchCtrl;
      focusNode = _buyFocusNode;
      currentTerm = _buySearchTerm;
    }

    return Expanded(
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          isCollapsed: true,
          isDense: true,
          border: UnderlineInputBorder(),
          suffixIcon: IconButton(
            padding: EdgeInsets.all(0),
            onPressed: currentTerm == null || currentTerm.isEmpty
                ? () => focusNode.requestFocus()
                : () {
                    controller.text = '';
                    unfocusTextField(context);
                    setState(() {
                      if (type == Market.SELL) {
                        _sellSearchTerm = '';
                      } else {
                        _buySearchTerm = '';
                      }
                    });
                  },
            icon: Icon(
              currentTerm == null || currentTerm.isEmpty
                  ? Icons.search
                  : Icons.clear,
            ),
          ),
        ),
        onChanged: (String text) {
          setState(() {
            if (type == Market.SELL) {
              _sellSearchTerm = text;
            } else {
              _buySearchTerm = text;
            }
          });
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      height: 1,
      child:
          _constrProvider.inProgress ? LinearProgressIndicator() : SizedBox(),
    );
  }
}
