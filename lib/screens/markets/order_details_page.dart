import 'package:flutter/material.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/build_order_details.dart';
import 'package:komodo_dex/screens/markets/build_order_health_details.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    this.order,
  });

  final Ask order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text('Order Details'), // TODO(yurii): localization
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                BuildOrderDetails(order),
                const SizedBox(height: 10),
                BuildOrderHealthDetails(order),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
