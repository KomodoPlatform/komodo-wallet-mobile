import 'package:flutter/material.dart';
import 'package:rational/rational.dart';
import 'package:provider/provider.dart';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/dex/trade/create/auto_scroll_text.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/utils/utils.dart';

class CoinsListBest extends StatefulWidget {
  const CoinsListBest({this.type});

  final CoinType type;

  @override
  _CoinsListBestState createState() => _CoinsListBestState();
}

class _CoinsListBestState extends State<CoinsListBest> {
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _cexProvider ??= Provider.of<CexProvider>(context);

    return FutureBuilder<BestOrders>(
      future: _constrProvider.getBestOrders(widget.type),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 150),
              child: Center(child: CircularProgressIndicator()));

        final List<Widget> items = _buildItems(snapshot.data);
        return ListView(
          shrinkWrap: true,
          children: items,
        );
      },
    );
  }

  List<Widget> _buildItems(BestOrders bestOrders) {
    if (bestOrders == null) return [SizedBox()];

    final List<BestOrder> topOrdersList = [];
    for (String ticker in bestOrders.result.keys) {
      topOrdersList.add(_getTickerTopOrder(bestOrders.result[ticker]));
    }

    topOrdersList.sort((a, b) {
      final aCexPrice = _cexProvider.getUsdPrice(a.coin);
      final bCexPrice = _cexProvider.getUsdPrice(b.coin);

      if (aCexPrice == 0 && bCexPrice != 0) return 1;
      if (aCexPrice != 0 && bCexPrice == 0) return -1;

      if (b.price.toDouble() * bCexPrice > a.price.toDouble() * aCexPrice) {
        return 1;
      }
      if (b.price.toDouble() * bCexPrice < a.price.toDouble() * aCexPrice) {
        return -1;
      }

      return a.coin.compareTo(b.coin);
    });

    final List<Widget> items = [];
    for (BestOrder topOrder in topOrdersList) {
      items.add(_buildItem(topOrder));
    }

    return items;
  }

  BestOrder _getTickerTopOrder(List<BestOrder> tickerOrdersList) {
    final List<BestOrder> sorted = List.from(tickerOrdersList);
    sorted.sort((a, b) => a.price.toDouble().compareTo(b.price.toDouble()));
    return sorted[0];
  }

  Widget _buildItem(BestOrder order) {
    final bool isCoinActive = coinsBloc.getBalanceByAbbr(order.coin) != null;

    return Opacity(
      opacity: isCoinActive ? 1 : 0.4,
      child: Card(
        margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50),
          child: Container(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: AssetImage(
                            'assets/${order.coin.toLowerCase()}.png'),
                      ),
                      SizedBox(width: 4),
                      Text(order.coin),
                    ],
                  ),
                  SizedBox(height: 4),
                  _buildItemDetails(order),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildItemDetails(BestOrder order) {
    final String counterCoin = widget.type == CoinType.base
        ? _constrProvider.buyCoin
        : _constrProvider.sellCoin;
    final Rational counterAmount = widget.type == CoinType.base
        ? _constrProvider.buyAmount
        : _constrProvider.sellAmount;
    final double cexPrice = _cexProvider.getUsdPrice(order.coin);
    final double counterCexPrice = _cexProvider.getUsdPrice(counterCoin);

    String receiveStr;
    Widget fiatProfitStr;

    if (cexPrice != 0) {
      final double receiveAmtUsd =
          cexPrice * order.price.toDouble() * counterAmount.toDouble();
      receiveStr = _cexProvider.convert(receiveAmtUsd);

      if (counterCexPrice != 0) {
        final double counterAmtUsd = counterAmount.toDouble() * counterCexPrice;
        final double fiatProfitPct =
            (receiveAmtUsd - counterAmtUsd) * 100 / counterAmtUsd;
        Color color = Theme.of(context).textTheme.caption.color;
        if (fiatProfitPct < 0) {
          color =
              widget.type == CoinType.base ? Colors.green : Colors.orangeAccent;
        } else if (fiatProfitPct > 0) {
          color =
              widget.type == CoinType.base ? Colors.orangeAccent : Colors.green;
        }
        fiatProfitStr = Text(
          ' (' +
              (fiatProfitPct > 0 ? '+' : '') +
              cutTrailingZeros(formatPrice(fiatProfitPct, 3)) +
              '%)',
          style: Theme.of(context).textTheme.caption.copyWith(color: color),
        );
      }
    } else {
      final double receiveAmt =
          order.price.toDouble() * counterAmount.toDouble();
      receiveStr = cutTrailingZeros(formatPrice(receiveAmt)) + ' ' + order.coin;
    }

    return Row(
      children: [
        Text(
          'Receive:',
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(color: Theme.of(context).textTheme.bodyText1.color),
        ),
        SizedBox(width: 4),
        Flexible(
          child: AutoScrollText(
            text: receiveStr,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        fiatProfitStr ?? SizedBox(),
      ],
    );
  }
}
