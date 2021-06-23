import 'package:flutter/material.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class CoinsListBest extends StatefulWidget {
  const CoinsListBest({this.type});

  final CoinType type;

  @override
  _CoinsListBestState createState() => _CoinsListBestState();
}

class _CoinsListBestState extends State<CoinsListBest> {
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);

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
    final List<BestOrder> topOrdersList = [];
    for (String ticker in bestOrders.result.keys) {
      topOrdersList.add(_getTickerTopOrder(bestOrders.result[ticker]));
    }

    final List<Widget> items = [];
    for (BestOrder topOrder in topOrdersList) {
      items.add(_buildItem(topOrder));
    }

    return items;
  }

  BestOrder _getTickerTopOrder(List<BestOrder> tickerOrdersList) {
    return tickerOrdersList[0];
  }

  Widget _buildItem(BestOrder order) {
    return Card(
      child: Container(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.coin),
              Text(cutTrailingZeros(formatPrice(order.price.toDouble())))
            ],
          )),
    );
  }
}
