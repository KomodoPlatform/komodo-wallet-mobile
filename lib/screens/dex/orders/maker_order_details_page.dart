import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/screens/dex/orders/maker_order_amount_price.dart';

class MakerOrderDetailsPage extends StatefulWidget {
  const MakerOrderDetailsPage(this.order);

  final Order order;

  @override
  _MakerOrderDetailsPageState createState() => _MakerOrderDetailsPageState();
}

class _MakerOrderDetailsPageState extends State<MakerOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).makerDetailsTitle),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 12,
                  top: 12,
                  bottom: 24,
                ),
                child: MakerOrderAmtAndPrice(widget.order),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
