import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_button_simple.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_trade_details.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/buy_form.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/coins_list.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/sell_form.dart';
import 'package:provider/provider.dart';

class TradePageSimple extends StatefulWidget {
  const TradePageSimple({Key key}) : super(key: key);

  @override
  State<TradePageSimple> createState() => _TradePageSimpleState();
}

class _TradePageSimpleState extends State<TradePageSimple> {
  final _key = GlobalKey();
  OrderBookProvider _obProvider;
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _obProvider ??= Provider.of<OrderBookProvider>(context);
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    final content = TradePageSimpleContent(key: _key);
    return _constrProvider.anyLists()
        ? content
        : SingleChildScrollView(child: content);
  }
}

class TradePageSimpleContent extends StatefulWidget {
  const TradePageSimpleContent({Key key}) : super(key: key);

  @override
  _TradePageSimpleContentState createState() => _TradePageSimpleContentState();
}

class _TradePageSimpleContentState extends State<TradePageSimpleContent> {
  final _sellSearchCtrl = TextEditingController();
  final _buySearchCtrl = TextEditingController();
  final _sellFocusNode = FocusNode();
  final _buyFocusNode = FocusNode();
  String _sellSearchTerm = '';
  String _buySearchTerm = '';
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(),
          SizedBox(height: 12),
          Flexible(
            flex: _constrProvider.anyLists() ? 1 : 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSell()),
                Expanded(child: _buildBuy()),
              ],
            ),
          ),
          BuildTradeDetails(),
          SizedBox(height: 12),
          BuildTradeButtonSimple(),
          // BuildResetButtonSimple(),
        ],
      ),
    );
  }

  Widget _buildSell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).simpleTradeSellTitle + ':',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              _buildSearchField(Market.SELL),
            ],
          ),
        ),
        SizedBox(height: 6),
        Flexible(
          flex: _constrProvider.anyLists() ? 1 : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _constrProvider.sellCoin == null
                  ? CoinsList(
                      type: Market.SELL,
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

  Widget _buildBuy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).simpleTradeBuyTitle + ':',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              _buildSearchField(Market.BUY),
            ],
          ),
        ),
        SizedBox(height: 6),
        Flexible(
          flex: _constrProvider.anyLists() ? 1 : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _constrProvider.buyCoin == null
                  ? CoinsList(
                      type: Market.BUY,
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
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(Market type) {
    TextEditingController controller;
    FocusNode focusNode;
    String currentTerm;
    if (type == Market.SELL) {
      if (_constrProvider.sellCoin != null) return SizedBox(height: 18);

      controller = _sellSearchCtrl;
      focusNode = _sellFocusNode;
      currentTerm = _sellSearchTerm;
    } else {
      if (_constrProvider.buyCoin != null) return SizedBox(height: 18);

      controller = _buySearchCtrl;
      focusNode = _buyFocusNode;
      currentTerm = _buySearchTerm;
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                right: 0,
                top: 1,
                child: currentTerm == null || currentTerm.isEmpty
                    ? InkWell(
                        onTap: () => focusNode.requestFocus(),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 6, 6),
                          child: Icon(
                            Icons.search,
                            size: 16,
                            color: Theme.of(context).hintColor.withAlpha(150),
                          ),
                        ),
                      )
                    : InkWell(
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
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 6, 6),
                          child: Icon(
                            Icons.clear,
                            size: 16,
                          ),
                        ),
                      ))
          ],
        ),
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
