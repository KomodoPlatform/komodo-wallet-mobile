import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/empty_list_message.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/auto_scroll_text.dart';
import 'package:provider/provider.dart';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';

class CoinsListAll extends StatefulWidget {
  const CoinsListAll({this.type, this.searchTerm});

  final Market type;
  final String searchTerm;

  @override
  _CoinsListAllState createState() => _CoinsListAllState();
}

class _CoinsListAllState extends State<CoinsListAll> {
  ConstructorProvider _constrProvider;
  OrderBookProvider _obProvider;
  int _timer;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _obProvider ??= Provider.of<OrderBookProvider>(context);

    final List<ListAllItem> items = _getItems();

    if (items.isEmpty) {
      final int now = DateTime.now().millisecondsSinceEpoch;
      setState(() => _timer ??= now);
      if (now - _timer > 1000) {
        return EmptyListMessage();
      } else {
        return _buildProgress();
      }
    }

    setState(() => _timer = null);

    return Container(
      padding: EdgeInsets.only(left: 12),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, i) {
          return _buildCoinItem(items[i]);
        },
      ),
    );
  }

  Widget _buildProgress() {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 150),
        child: Center(child: CircularProgressIndicator()));
  }

  Widget _buildCoinItem(ListAllItem item) {
    return Opacity(
      opacity: item.coin.isActive ? 1 : 0.3,
      child: Card(
        margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
        child: InkWell(
          onTap: () {
            widget.type == Market.SELL
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
                  SizedBox(width: 6),
                  if (widget.type == Market.SELL)
                    Expanded(
                      child: Container(
                        alignment: Alignment(1, 0),
                        child: AutoScrollText(
                          text: item.balance,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
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
          widget.type == Market.SELL ? coin.abbr : obDepth.pair.base;
      final Decimal balance =
          coinsBloc.getBalanceByAbbr(coinBalanceRequired)?.balance?.balance;

      if (balance == null || balance.toDouble() == 0.0) continue;
      if (obDepth.depth.bids > 0) counter++;
    }

    return counter;
  }

  List<ListAllItem> _getItems({bool includeEmpty = false}) {
    final List<ListAllItem> available = [];
    final List<CoinBalance> active = coinsBloc.coinBalance;

    for (CoinBalance coinBalance in active) {
      final int matchingCoins = _getMatchingCoinsNumber(coinBalance.coin);
      if (!includeEmpty && matchingCoins == 0) continue;

      final String term = widget.searchTerm.trim().toLowerCase();
      if (term.isNotEmpty) {
        final Coin coin = coinBalance.coin;
        bool matched = false;
        if (coin.abbr.toLowerCase().contains(term)) matched = true;
        if (coin.name.toLowerCase().contains(term)) matched = true;

        if (!matched) continue;
      }

      available.add(ListAllItem(
        coin: coinBalance.coin,
        matchingCoins: matchingCoins,
      ));
    }

    available.sort((a, b) {
      if (a.matchingCoins > b.matchingCoins) return -1;
      if (a.matchingCoins < b.matchingCoins) return 1;

      return a.coin.abbr.compareTo(b.coin.abbr);
    });

    if (available.isNotEmpty) {
      return available;
    } else if (!includeEmpty) {
      return _getItems(includeEmpty: true);
    } else {
      return available;
    }
  }
}

class ListAllItem {
  ListAllItem({this.coin, this.matchingCoins});

  String get balance {
    final Decimal coinBalance =
        coinsBloc.getBalanceByAbbr(coin.abbr)?.balance?.balance ?? deci(0);
    return cutTrailingZeros(formatPrice(coinBalance));
  }

  Coin coin;
  int matchingCoins;
}
