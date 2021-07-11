import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/screens/dex/trade/simple/coins_list_all.dart';
import 'package:komodo_dex/screens/dex/trade/simple/coins_list_best.dart';
import 'package:provider/provider.dart';
import 'package:rational/rational.dart';

import 'package:komodo_dex/model/swap_constructor_provider.dart';

class CoinsList extends StatefulWidget {
  const CoinsList({this.type, this.known, this.searchTerm});

  final Market type;
  final LinkedHashMap<String, Coin> known;
  final String searchTerm;

  @override
  _CoinsListState createState() => _CoinsListState();
}

class _CoinsListState extends State<CoinsList> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

    final String _counterCoin = widget.type == Market.SELL
        ? _constrProvider.buyCoin
        : _constrProvider.sellCoin;

    final Rational _counterAmount = widget.type == Market.SELL
        ? _constrProvider.buyAmount
        : _constrProvider.sellAmount;

    if (_counterCoin == null) {
      return CoinsListAll(type: widget.type, searchTerm: widget.searchTerm);
    } else if (_counterAmount == null || _counterAmount.toDouble() == 0) {
      return _buildAmtMessage();
    } else {
      return CoinsListBest(
        type: widget.type,
        searchTerm: widget.searchTerm,
        known: widget.known,
      );
    }
  }

  Widget _buildAmtMessage() {
    final String coin = widget.type == Market.SELL
        ? _constrProvider.buyCoin
        : _constrProvider.sellCoin;
    final String message = widget.type == Market.SELL
        ? 'Plsease enter $coin amount to buy'
        : 'Plsease enter $coin amount to sell';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.type == Market.BUY) ...{
          Container(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.arrow_left,
                color: Theme.of(context).textTheme.bodyText1.color,
              )),
        },
        Expanded(
          child: Container(
              height: 106,
              padding: EdgeInsets.fromLTRB(0, 10, 0, 4),
              alignment: Alignment(0, 1),
              child: Text(
                message,
                textAlign: widget.type == Market.BUY
                    ? TextAlign.left
                    : TextAlign.right,
                style: Theme.of(context).textTheme.bodyText1,
              )),
        ),
        if (widget.type == Market.SELL) ...{
          Container(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.arrow_right,
                color: Theme.of(context).textTheme.bodyText1.color,
              )),
          SizedBox(width: 6),
        }
      ],
    );
  }
}
