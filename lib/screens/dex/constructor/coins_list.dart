import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
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
  ConstructorProvider _constrProvider;

  @override
  void dispose() {
    _listeners.map((listener) => listener.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _obProvider ??= Provider.of<OrderBookProvider>(context);
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
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
              ? _constrProvider.sellCoin = coin.abbr
              : _constrProvider.buyCoin = coin.abbr;
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
                _buildNumber(coin),
              ],
            )),
      ),
    );
  }

  Widget _buildNumber(Coin coin) {
    if (widget.type == CoinType.base && _constrProvider.buyCoin != null) {
      return _buildAsksNumber(coin);
    }

    if (widget.type == CoinType.rel && _constrProvider.sellCoin != null) {
      return _buildBidsNumber(coin);
    }

    return Text(
      _getMatchingCoinsNumber(coin).toString(),
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildAsksNumber(Coin coin) {
    final OrderbookDepth obDepth = _obProvider.getDepth(
      CoinsPair(
          sell: coin, buy: coinsBloc.getCoinByAbbr(_constrProvider.buyCoin)),
    );
    return Text(
      obDepth.depth.bids.toString(),
      style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red),
    );
  }

  Widget _buildBidsNumber(Coin coin) {
    final OrderbookDepth obDepth = _obProvider.getDepth(
      CoinsPair(
          sell: coinsBloc.getCoinByAbbr(_constrProvider.sellCoin), buy: coin),
    );
    return Text(
      obDepth.depth.bids.toString(),
      style: Theme.of(context).textTheme.caption.copyWith(color: Colors.green),
    );
  }

  int _getMatchingCoinsNumber(Coin coin) {
    int counter = 0;
    final List<OrderbookDepth> obDepths = _obProvider.depthsForCoin(coin);
    for (OrderbookDepth obDepth in obDepths) {
      if (widget.type == CoinType.rel &&
          _constrProvider.sellCoin != null &&
          obDepth.pair.rel != _constrProvider.sellCoin) {
        continue;
      }

      if (widget.type == CoinType.base &&
          _constrProvider.buyCoin != null &&
          obDepth.pair.rel != _constrProvider.buyCoin) {
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
