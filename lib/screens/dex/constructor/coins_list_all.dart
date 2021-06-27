import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:provider/provider.dart';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';

class CoinsListAll extends StatefulWidget {
  const CoinsListAll({this.type});

  final CoinType type;

  @override
  _CoinsListAllState createState() => _CoinsListAllState();
}

class _CoinsListAllState extends State<CoinsListAll> {
  ConstructorProvider _constrProvider;
  OrderBookProvider _obProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _obProvider ??= Provider.of<OrderBookProvider>(context);

    return FutureBuilder<List<ListAllItem>>(
      future: _getCoins(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 150),
              child: Center(child: CircularProgressIndicator()));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.length,
          itemBuilder: (context, i) {
            return _buildCoinItem(snapshot.data[i]);
          },
        );
      },
    );
  }

  Widget _buildCoinItem(ListAllItem item) {
    return Opacity(
      opacity: item.coin.isActive ? 1 : 0.3,
      child: Card(
        margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
        child: InkWell(
          onTap: () {
            widget.type == CoinType.base
                ? _constrProvider.sellCoin = item.coin.abbr
                : _constrProvider.buyCoin = item.coin.abbr;
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundImage: AssetImage(
                        'assets/${item.coin.abbr.toLowerCase()}.png'),
                  ),
                  SizedBox(width: 4),
                  Text(
                    item.coin.abbr,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    item.matchingCoins.toString(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )),
        ),
      ),
    );
  }

  int _getMatchingCoinsNumber(Coin coin) {
    int counter = 0;
    final List<OrderbookDepth> obDepths =
        _obProvider.depthsForCoin(coin, widget.type);

    for (OrderbookDepth obDepth in obDepths) {
      final String coinBalanceRequired =
          widget.type == CoinType.base ? coin.abbr : obDepth.pair.base;
      final Decimal balance =
          coinsBloc.getBalanceByAbbr(coinBalanceRequired)?.balance?.balance;

      if (balance == null || balance.toDouble() == 0.0) continue;
      if (obDepth.depth.bids > 0) counter++;
    }

    return counter;
  }

  Future<List<ListAllItem>> _getCoins() async {
    final LinkedHashMap<String, Coin> known = await coins;
    final List<ListAllItem> available = [];

    known.forEach((String abbr, Coin coin) {
      if (!coin.isActive) return;

      final int matchingCoins = _getMatchingCoinsNumber(coin);
      if (matchingCoins == 0) return;

      available.add(ListAllItem(
        coin: coin,
        matchingCoins: matchingCoins,
      ));
    });

    available.sort((a, b) {
      if (a.matchingCoins > b.matchingCoins) return -1;
      if (a.matchingCoins < b.matchingCoins) return 1;

      return a.coin.abbr.compareTo(b.coin.abbr);
    });

    return available;
  }
}

class ListAllItem {
  ListAllItem({this.coin, this.matchingCoins});

  Coin coin;
  int matchingCoins;
}
