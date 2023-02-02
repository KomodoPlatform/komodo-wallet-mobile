import 'package:flutter/material.dart';
import '../../../../../generic_blocs/coins_bloc.dart';
import '../../../../../localizations.dart';
import '../../../../../model/best_order.dart';
import '../../../../../model/cex_provider.dart';
import '../../../../../model/coin.dart';
import '../../../../../model/coin_balance.dart';
import '../../../../../model/error_string.dart';
import '../../../../../model/market.dart';
import '../../../../../model/swap_constructor_provider.dart';
import '../../../../dex/trade/simple/create/coins_list_best_item.dart';
import '../../../../dex/trade/simple/create/empty_list_message.dart';
import '../../../../../utils/utils.dart';
import 'package:provider/provider.dart';

class CoinsListBest extends StatefulWidget {
  const CoinsListBest({this.type, this.searchTerm});

  final Market type;
  final String searchTerm;

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
    _showAll = widget.type == Market.BUY;
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

          return _buildList(bestOrders);
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
      constraints: BoxConstraints(minHeight: 150),
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

  Widget _buildList(BestOrders bestOrders) {
    return FutureBuilder<List<Widget>>(
      future: _buildItems(bestOrders),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        return ListView(
          shrinkWrap: true,
          children: snapshot.data,
        );
      },
    );
  }

  Future<List<Widget>> _buildItems(BestOrders bestOrders) async {
    final Iterable tickers = bestOrders?.result?.keys;
    if (tickers == null) return [EmptyListMessage()];

    final List<BestOrder> topOrdersList = [];
    for (String ticker in tickers) {
      final BestOrder topOrder = _constrProvider.getTickerTopOrder(
        bestOrders.result[ticker],
        widget.type,
      );
      if (topOrder != null) topOrdersList.add(topOrder);
    }

    topOrdersList.sort((a, b) {
      final String aCoin = a.action == Market.SELL ? a.coin : a.otherCoin;
      final String bCoin = b.action == Market.SELL ? b.coin : b.otherCoin;
      final aCexPrice = _cexProvider.getUsdPrice(aCoin);
      final bCexPrice = _cexProvider.getUsdPrice(bCoin);

      if (aCexPrice == 0 && bCexPrice != 0) return 1;
      if (aCexPrice != 0 && bCexPrice == 0) return -1;

      if (b.price.toDouble() * bCexPrice > a.price.toDouble() * aCexPrice) {
        return a.action == Market.SELL ? 1 : -1;
      }
      if (b.price.toDouble() * bCexPrice < a.price.toDouble() * aCexPrice) {
        return a.action == Market.SELL ? -1 : 1;
      }

      return aCoin.compareTo(bCoin);
    });

    final known = await coins;
    final List<Widget> items = [];
    bool switcherDisabled = true;
    for (BestOrder topOrder in topOrdersList) {
      final String abbr =
          topOrder.action == Market.BUY ? topOrder.otherCoin : topOrder.coin;

      final Coin coin = known[abbr];
      final String term = widget.searchTerm.toLowerCase().trim();
      if (term.isNotEmpty) {
        bool matched = false;
        if (coin.abbr.toLowerCase().contains(term)) matched = true;
        if (coin.name.toLowerCase().contains(term)) matched = true;

        if (!matched) continue;
      }

      final CoinBalance coinBalance = coinsBloc.getBalanceByAbbr(abbr);
      final bool isActive = coinBalance != null;
      final bool hasBalance =
          (coinBalance?.balance?.balance ?? deci(0)).toDouble() > 0;
      final bool isInShortList =
          widget.type == Market.SELL ? isActive && hasBalance : isActive;
      if (!isInShortList) switcherDisabled = false;

      if (_showAll || isInShortList) {
        final String key =
            '${widget.type == Market.SELL ? 'buy' : 'sell'}-$abbr-top-order';
        items.add(CoinsListBestItem(topOrder, key: Key(key)));
      }
    }

    if (items.isEmpty) items.add(EmptyListMessage());
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
            child: Text(
                _showAll
                    ? AppLocalizations.of(context).simpleTradeShowLess
                    : AppLocalizations.of(context).simpleTradeShowMore,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      ),
    );
  }
}
