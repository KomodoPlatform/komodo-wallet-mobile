import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:decimal/decimal.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    ordersBloc.updateOrdersSwaps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
        initialData: ordersBloc.orderSwaps,
        stream: ordersBloc.outOrderSwaps,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.data != null && snapshot.data.isNotEmpty) {
            List<dynamic> orderSwaps = snapshot.data;
            orderSwaps = snapshot.data.reversed.toList();
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: orderSwaps.length,
              itemBuilder: (BuildContext context, int index) {
                if (orderSwaps[index] is Swap) {
                  return BuildItemSwap(
                      context: context, swap: orderSwaps[index]);
                } else if (orderSwaps[index] is Order) {
                  return _buildItemOrder(orderSwaps[index]);
                } else {
                  return Container();
                }
              },
            );
          } else {
            return Container(
              child:
                  const Center(child: Text('No orders, please go to trade.')),
            );
          }
        });
  }

  Widget _buildItemOrder(Order order) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildIcon(order.base),
                Icon(
                  Icons.sync,
                  size: 25,
                  color: Colors.white,
                ),
                _buildIcon(order.rel)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildTextAmount(order.base, order.baseAmount),
                Expanded(
                  child: Container(),
                ),
                Icon(
                  Icons.code,
                  size: 20,
                  color: Colors.white,
                ),
                Expanded(
                  child: Container(),
                ),
                _buildTextAmount(order.rel, order.relAmount),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            AutoSizeText(
              'UUID: ' + order.uuid,
              maxLines: 2,
              style: Theme.of(context).textTheme.body2,
            ),
            const SizedBox(
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
            order.cancelable
                ? Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        child: Container(
                          height: 30,
                          child: OutlineButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            borderSide: BorderSide(color: Colors.white),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                                color: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      AppLocalizations.of(context)
                                          .cancel
                                          .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            color: Colors.white,
                                          ))
                                ],
                              ),
                            ),
                            onPressed: () {
                              ordersBloc.cancelOrder(order.uuid);
                            },
                          ),
                        ),
                      )
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildTextAmount(String coin, String amount) {
    if (coin != null && amount != null && amount.isNotEmpty) {
      return Text(
        '~ ${(Decimal.parse(amount) % Decimal.parse('1') == Decimal.parse('0') ? Decimal.parse(amount) : Decimal.parse(amount).toStringAsFixed(6))} $coin ',
        style: Theme.of(context).textTheme.body1,
      );
    } else {
      return const Text('');
    }
  }

  Widget _buildIcon(String coin) {
    return Container(
      height: 30,
      width: 30,
      child: Image.asset(
        'assets/${coin.toLowerCase()}.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
