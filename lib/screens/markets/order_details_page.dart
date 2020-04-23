import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({
    this.order,
    this.coinsPair,
  });

  final CoinsPair coinsPair;
  final Ask order;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text('Order Details'), // TODO(yurii): localization
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(widget.order.address),
            Text(widget.order.coin),
          ],
        ),
      ),
    );
  }
}
