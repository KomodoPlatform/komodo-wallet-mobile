import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_reset_button_simple.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_button_simple.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_details.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/buy_form.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/coins_list.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/sell_form.dart';
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
      padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: _anyLists() ? 1 : 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSell(known)),
                Expanded(child: _buildBuy(known)),
              ],
            ),
          ),
          BuildTradeDetails(),
          BuildTradeButtonSimple(),
          BuildResetButtonSimple(),
        ],
      ),
    );
  }

  Widget _buildSell(LinkedHashMap<String, Coin> known) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Text(
                'Sell:',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              _buildSearchField(Market.SELL),
            ],
          ),
        ),
        SizedBox(height: 6),
        Flexible(
          flex: _anyLists() ? 1 : 0,
          child: Stack(
            overflow: Overflow.visible,
            children: [
              _constrProvider.sellCoin == null
                  ? CoinsList(
                      type: Market.SELL,
                      known: known,
                      searchTerm: _sellSearchTerm,
                    )
                  : SellForm(),
              Positioned(
                child: Container(
                  color: Theme.of(context).primaryColor,
                ),
                right: -1,
                width: 2,
                top: 0,
                bottom: 0,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBuy(LinkedHashMap<String, Coin> known) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Text(
                'Buy:',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              _buildSearchField(Market.BUY),
            ],
          ),
        ),
        SizedBox(height: 6),
        Flexible(
            flex: _anyLists() ? 1 : 0,
            child: Stack(
              overflow: Overflow.visible,
              children: [
                _constrProvider.buyCoin == null
                    ? CoinsList(
                        type: Market.BUY,
                        known: known,
                        searchTerm: _buySearchTerm,
                      )
                    : BuyForm(),
                Positioned(
                  child: Container(
                    color: Theme.of(context).primaryColor,
                  ),
                  left: -1,
                  width: 2,
                  top: 0,
                  bottom: 0,
                )
              ],
            ))
      ],
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
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Stack(
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: Theme.of(context).accentColor),
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(0, 0, 30, 0),
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
            Positioned(
                right: 6,
                top: 1,
                child: currentTerm == null || currentTerm.isEmpty
                    ? GestureDetector(
                        onTap: () => focusNode.requestFocus(),
                        child: Icon(
                          Icons.search,
                          size: 16,
                          color: Theme.of(context).hintColor.withAlpha(150),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          controller.text = '';
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() {
                            if (type == Market.SELL) {
                              _sellSearchTerm = '';
                            } else {
                              _buySearchTerm = '';
                            }
                          });
                        },
                        child: Icon(
                          Icons.clear,
                          size: 16,
                        ),
                      ))
          ],
        ),
      ),
    );
  }
}
