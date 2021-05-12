import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/swap_constructor_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:provider/provider.dart';

class CoinsList extends StatefulWidget {
  const CoinsList({this.type});

  final CoinType type;

  @override
  _CoinsListState createState() => _CoinsListState();
}

class _CoinsListState extends State<CoinsList> {
  final List<StreamSubscription> _listeners = [];
  OrderBookProvider _obProvider;
  String _sellCoin;
  String _buyCoin;

  @override
  void initState() {
    super.initState();
    _listeners.add(constructorBloc.outSellCoin.listen((String data) {
      setState(() => _sellCoin = data);
    }));
    _listeners.add(constructorBloc.outBuyCoin.listen((String data) {
      setState(() => _buyCoin = data);
    }));
  }

  @override
  void dispose() {
    _listeners.map((listener) => listener.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _obProvider ??= Provider.of<OrderBookProvider>(context);
    final List<Coin> coins = _getCoins();

    return ListView.builder(
      itemCount: coins.length,
      itemBuilder: (context, i) {
        return _buildCoinItem(coins[i]);
      },
    );
  }

  Widget _buildCoinItem(Coin coin) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
      child: InkWell(
        onTap: () {
          widget.type == CoinType.base
              ? constructorBloc.sellCoin = coin.abbr
              : constructorBloc.buyCoin = coin.abbr;
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundImage:
                      AssetImage('assets/${coin.abbr.toLowerCase()}.png'),
                ),
                SizedBox(width: 4),
                Text(
                  coin.abbr,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Expanded(child: SizedBox()),
                Text(
                  _getMatchingCoinsNumber(coin).toString(),
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            )),
      ),
    );
  }

  int _getMatchingCoinsNumber(Coin coin) {
    int counter = 0;
    final List<OrderbookDepth> obDepths = _obProvider.depthsForCoin(coin);
    for (OrderbookDepth obDepth in obDepths) {
      if (widget.type == CoinType.rel &&
          _sellCoin != null &&
          obDepth.pair.rel != _sellCoin) {
        continue;
      }

      if (widget.type == CoinType.base &&
          _buyCoin != null &&
          obDepth.pair.rel != _buyCoin) {
        continue;
      }

      final String requiredBalanceCoin =
          widget.type == CoinType.base ? obDepth.pair.base : obDepth.pair.rel;
      final double requiredBalance = coinsBloc
              .getBalanceByAbbr(requiredBalanceCoin)
              ?.balance
              ?.balance
              ?.toDouble() ??
          0;
      if (requiredBalance == 0) continue;

      final int matchingOrders = widget.type == CoinType.base
          ? obDepth.depth.bids
          : obDepth.depth.asks;
      if (matchingOrders > 0) counter++;
    }
    return counter;
  }

  List<Coin> _getCoins() {
    final List<Coin> active =
        coinsBloc.coinBalance.map((bal) => bal.coin).toList();

    final List<Coin> available = [];
    for (Coin coin in active) {
      if (_getMatchingCoinsNumber(coin) == 0) continue;
      available.add(coin);
    }

    available.sort((a, b) {
      final int aNum = _getMatchingCoinsNumber(a);
      final int bNum = _getMatchingCoinsNumber(b);
      if (aNum > bNum) return -1;
      if (aNum < bNum) return 1;

      return a.abbr.compareTo(b.abbr);
    });

    return available;
  }
}
