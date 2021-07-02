import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_best_orders.dart';
import 'package:komodo_dex/screens/dex/constructor/coins_list_best_item.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';

class CoinsListBest extends StatefulWidget {
  const CoinsListBest({this.type});

  final CoinType type;

  @override
  _CoinsListBestState createState() => _CoinsListBestState();
}

class _CoinsListBestState extends State<CoinsListBest> {
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;
  int _timer;
  bool _showAll = false;

  @override
  void initState() {
    _showAll = widget.type == CoinType.rel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _cexProvider ??= Provider.of<CexProvider>(context);

    return Container(
      padding: EdgeInsets.only(left: 12),
      child: FutureBuilder<BestOrders>(
        future: _constrProvider.getBestOrders(widget.type),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _buildProgressIndicator();

          final BestOrders bestOrders = snapshot.data;
          if (bestOrders.error != null) {
            return _buildErrorHandler(bestOrders.error);
          }
          _timer = null;

          final List<Widget> items = _buildItems(snapshot.data);
          return ListView(
            shrinkWrap: true,
            children: items,
          );
        },
      ),
    );
  }

  Widget _buildErrorHandler(ErrorString error) {
    // Showing spinner for 2sec before actual error message
    // in case mm2 is restarting after app wakeup
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_timer != null && now - _timer > 2000) {
      return _buildErrorMessage(error);
    } else {
      _timer ??= now;
      return _buildProgressIndicator();
    }
  }

  Widget _buildProgressIndicator() {
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 150),
        child: Center(child: CircularProgressIndicator()));
  }

  Widget _buildErrorMessage(ErrorString error) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 150),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Text(
            error.error,
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Theme.of(context).errorColor),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BestOrders bestOrders) {
    final Iterable tickers = bestOrders?.result?.keys;
    if (tickers == null) return [_buildProgressIndicator()];

    final List<BestOrder> topOrdersList = [];
    for (String ticker in tickers) {
      topOrdersList.add(_getTickerTopOrder(bestOrders.result[ticker]));
    }

    topOrdersList.sort((a, b) {
      final String aCoin = a.action == MarketAction.SELL ? a.coin : a.forCoin;
      final String bCoin = b.action == MarketAction.SELL ? b.coin : b.forCoin;
      final aCexPrice = _cexProvider.getUsdPrice(aCoin);
      final bCexPrice = _cexProvider.getUsdPrice(bCoin);

      if (aCexPrice == 0 && bCexPrice != 0) return 1;
      if (aCexPrice != 0 && bCexPrice == 0) return -1;

      if (b.price.toDouble() * bCexPrice > a.price.toDouble() * aCexPrice) {
        return a.action == MarketAction.SELL ? 1 : -1;
      }
      if (b.price.toDouble() * bCexPrice < a.price.toDouble() * aCexPrice) {
        return a.action == MarketAction.SELL ? -1 : 1;
      }

      return aCoin.compareTo(bCoin);
    });

    final List<Widget> items = [];
    bool switcherDisabled = true;
    for (BestOrder topOrder in topOrdersList) {
      final String coin = topOrder.action == MarketAction.BUY
          ? topOrder.forCoin
          : topOrder.coin;

      final CoinBalance coinBalance = coinsBloc.getBalanceByAbbr(coin);
      final bool isActive = coinBalance != null;
      final bool hasBalance =
          (coinBalance?.balance?.balance ?? deci(0)).toDouble() > 0;
      final bool isInShortList =
          widget.type == CoinType.base ? isActive && hasBalance : isActive;
      if (!isInShortList) switcherDisabled = false;

      if (_showAll || isInShortList) {
        final Key key = widget.type == CoinType.base
            ? Key('buy-best-orders-$coin')
            : Key('sell-best-orders-$coin');
        items.add(CoinsListBestItem(
          topOrder,
          key: key,
        ));
      }
    }

    items.add(_buildShowAllSwitcher(switcherDisabled));
    return items;
  }

  Widget _buildShowAllSwitcher(bool disabled) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: disabled ? null : () => setState(() => _showAll = !_showAll),
        child: Opacity(
          opacity: disabled ? 0.3 : 1,
          child: Container(
            padding: EdgeInsets.fromLTRB(12, 24, 12, 24),
            child: Text(_showAll ? 'Show less' : 'Show more',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      ),
    );
  }

  BestOrder _getTickerTopOrder(List<BestOrder> tickerOrdersList) {
    final List<BestOrder> sorted = List.from(tickerOrdersList);
    if (widget.type == CoinType.base) {
      sorted.sort((a, b) => a.price.toDouble().compareTo(b.price.toDouble()));
    } else {
      sorted.sort((a, b) => b.price.toDouble().compareTo(a.price.toDouble()));
    }
    return sorted[0];
  }
}
