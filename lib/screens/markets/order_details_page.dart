import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/build_order_details.dart';

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
        title: Text(AppLocalizations.of(context).marketsOrderDetails),
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
                Card(elevation: 8, child: BuildOrderDetails(order)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
