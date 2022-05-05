import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';

class CoinsListDepths extends StatefulWidget {
  const CoinsListDepths({this.type});

  final CoinType type;

  @override
  _CoinsListDepthsState createState() => _CoinsListDepthsState();
}

class _CoinsListDepthsState extends State<CoinsListDepths> {
  ConstructorProvider _constrProvider;
  OrderBookProvider _obProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _obProvider ??= Provider.of<OrderBookProvider>(context);

    return Container(
      padding: EdgeInsets.only(left: 12),
      child: FutureBuilder<List<DepthListCoin>>(
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
      ),
    );
  }

  Widget _buildCoinItem(DepthListCoin item) {
    return Opacity(
      opacity: item.coin.isActive ? 1 : 0.3,
      child: Card(
        margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
        child: InkWell(
          onTap: () => widget.type == CoinType.base
              ? _constrProvider.sellCoin = item.coin.abbr
              : _constrProvider.buyCoin = item.coin.abbr,
          child: Container(
              padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 8,
                    backgroundImage:
                        AssetImage(getCoinIconPath(item.coin.abbr)),
                  ),
                  SizedBox(width: 4),
                  Text(
                    item.coin.abbr,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Expanded(child: SizedBox()),
                  _buildNumber(item),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildNumber(DepthListCoin item) {
    if (widget.type == CoinType.base) {
      return Text(
        item.matchingOrders.toString(),
        style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red),
      );
    } else {
      return Text(
        item.matchingOrders.toString(),
        style:
            Theme.of(context).textTheme.caption.copyWith(color: Colors.green),
      );
    }
  }

  Future<List<DepthListCoin>> _getCoins() async {
    final LinkedHashMap<String, Coin> known = await coins;
    final List<DepthListCoin> available = [];

    known.forEach((String abbr, Coin coin) {
      OrderbookDepth depth;

      if (widget.type == CoinType.base) {
        if (!coin.isActive) return;

        depth = _obProvider.getDepth(
            CoinsPair(sell: coin, buy: known[_constrProvider.buyCoin]));
      } else {
        depth = _obProvider.getDepth(
            CoinsPair(buy: coin, sell: known[_constrProvider.sellCoin]));
      }

      final int matchingOrders = depth?.depth?.bids ?? 0;
      if (matchingOrders == 0) return;

      available.add(DepthListCoin(
        coin: coin,
        matchingOrders: matchingOrders,
      ));
    });

    available.sort((a, b) {
      if (a.matchingOrders > b.matchingOrders) return -1;
      if (a.matchingOrders < b.matchingOrders) return 1;

      return a.coin.abbr.compareTo(b.coin.abbr);
    });

    return available;
  }
}

class DepthListCoin {
  DepthListCoin({this.coin, this.matchingOrders});

  Coin coin;
  int matchingOrders;
}
