import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    ordersBloc.updateOrders();
    ordersBloc.updateOrdersSwaps(50, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
        initialData: ordersBloc.orders,
        stream: ordersBloc.outOrders,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length > 0) {
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return _buildItemOrder(snapshot.data[index]);
              },
            );
          } else {
            return Container(
              child: Center(child: Text("No orders, please go to trade.")),
            );
          }
        });
  }

  _buildItemOrder(Order order) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
        bottom: 4,
      ),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _buildTextAmount(order.base, order.baseAmount),
                  Expanded(
                    child: Container(),
                  ),
                  _buildIcon(order.base),
                  Icon(
                    Icons.sync,
                    size: 20,
                    color: Colors.white,
                  ),
                  _buildIcon(order.rel),
                  Expanded(
                    child: Container(),
                  ),
                  _buildTextAmount(order.rel, order.relAmount),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              AutoSizeText(
                "UUID: " + order.uuid,
                maxLines: 2,
                style: Theme.of(context).textTheme.body2,
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormat('dd MMM yyyy HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            order.createdAt * 1000)),
                    style: Theme.of(context).textTheme.body2,
                  ),
                ],
              ),
              order.cancelable ? Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SecondaryButton(

                      text: AppLocalizations.of(context).cancel,
                      onPressed: () {
                        ordersBloc.cancelOrder(order.uuid);
                      },
                    ),
                  )
                ],
              ) : Container()
            ],
          ),
        ),
      ),
    );
  }

  _buildTextAmount(String coin, String amount) {
    if (amount != null && amount.isNotEmpty) {
      return Text(
        '${(double.parse(amount) % 1) == 0 ? double.parse(amount) : double.parse(amount).toStringAsFixed(4)} $coin',
        style: Theme.of(context).textTheme.body1,
      );
    } else {
      return Text("");
    }
  }

  _buildIcon(String coin) {
    return Container(
      height: 25,
      width: 25,
      child: Image.asset(
        "assets/${coin.toLowerCase()}.png",
        fit: BoxFit.cover,
      ),
    );
  }
}
