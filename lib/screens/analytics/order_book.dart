import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/analytics/coin_select.dart';

class OrderBook extends StatefulWidget {
  @override
  _OrderBookState createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          _buildPairSelect(),
        ],
      ),
    );
  }

  Widget _buildPairSelect() {
    return Container(
      child: Card(
        elevation: 8,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CoinSelect(),
              const SizedBox(width: 12),
              Text(
                '/',
                style:
                    Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18),
              ),
              const SizedBox(width: 12),
              CoinSelect(),
            ],
          ),
        ),
      ),
    );
  }
}
