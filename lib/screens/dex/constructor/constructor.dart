import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:provider/provider.dart';

class SwapConstructor extends StatefulWidget {
  @override
  _SwapConstructorState createState() => _SwapConstructorState();
}

class _SwapConstructorState extends State<SwapConstructor> {
  OrderBookProvider _obProvider;

  @override
  Widget build(BuildContext context) {
    _obProvider ??= Provider.of<OrderBookProvider>(context);

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSell()),
                VerticalDivider(
                  color: Theme.of(context).highlightColor,
                  width: 2,
                ),
                SizedBox(width: 12),
                Expanded(child: _buildBuy()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSell() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sell:',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        SizedBox(height: 6),
        Expanded(child: _buildCoinsList(CoinType.base)),
      ],
    );
  }

  Widget _buildBuy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buy:',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        SizedBox(height: 6),
        Expanded(child: _buildCoinsList(CoinType.rel)),
      ],
    );
  }

  Future<List<Coin>> _getCoins(CoinType type) async {
    final List<Coin> active =
        coinsBloc.coinBalance.map((bal) => bal.coin).toList();

    final List<Coin> available = [];
    for (Coin coin in active) {
      await _obProvider.subscribeDepth(coin, type);
      if (_getMatchingCoinsNumber(coin, type) == 0) continue;

      available.add(coin);
    }

    available.sort((a, b) {
      return _getMatchingCoinsNumber(b, type)
          .compareTo(_getMatchingCoinsNumber(a, type));
    });

    return available;
  }

  Widget _buildProgress() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCoinsList(CoinType type) {
    return FutureBuilder(
      future: _getCoins(type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildProgress();
        final List<Coin> coins = snapshot.data;

        return ListView.builder(
          itemCount: coins.length,
          itemBuilder: (context, i) {
            return _buildCoinItem(coins[i], type);
          },
        );
      },
    );
  }

  Widget _buildCoinItem(Coin coin, CoinType type) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
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
                _getMatchingCoinsNumber(coin, type).toString(),
                style: Theme.of(context).textTheme.caption,
              )
            ],
          )),
    );
  }

  int _getMatchingCoinsNumber(Coin coin, CoinType type) {
    int counter = 0;
    final List<OrderbookDepth> obDepths = _obProvider.depthsForCoin(coin);
    for (OrderbookDepth obDepth in obDepths) {
      final String requiredBalanceCoin =
          type == CoinType.base ? obDepth.pair.base : obDepth.pair.rel;
      final double requiredBalance = coinsBloc
              .getBalanceByAbbr(requiredBalanceCoin)
              ?.balance
              ?.balance
              ?.toDouble() ??
          0;
      if (requiredBalance == 0) continue;

      final int matchingOrders =
          type == CoinType.base ? obDepth.depth.bids : obDepth.depth.asks;
      if (matchingOrders > 0) counter++;
    }
    return counter;
  }
}
