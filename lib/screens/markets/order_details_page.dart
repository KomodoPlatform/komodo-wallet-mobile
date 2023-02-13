import 'package:flutter/material.dart';
import '../../localizations.dart';
import '../../model/orderbook.dart';
import '../authentification/lock_screen.dart';
import '../markets/build_order_details.dart';
import '../../utils/utils.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    this.order,
  });

  final Ask? order;

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.marketsOrderDetails),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              unfocusEverything();
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
      ),
    );
  }
}
