import 'package:flutter/material.dart';
import 'package:komodo_dex/model/best_order.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BestOrders>(
      future: _constrProvider.getBestOrders(widget.type),
      builder: (context, snapshot) {
        return SizedBox();
      },
    );
  }
}
