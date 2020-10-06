import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:komodo_dex/utils/utils.dart';

class ActiveOrders extends StatefulWidget {
  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          order.base,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 2),
                        _buildIcon(order.base),
                      ],
                    ),
                    Text(
                      '~${formatPrice(order.baseAmount, 8)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Icon(Icons.swap_horiz),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _buildIcon(order.rel),
                        const SizedBox(width: 2),
                        Text(
                          order.rel,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      '~${formatPrice(order.relAmount, 8)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 12,
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
                            borderSide: const BorderSide(color: Colors.white),
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

  Widget _buildIcon(String coin) {
    return CircleAvatar(
      maxRadius: 10,
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(
        'assets/${coin.toLowerCase()}.png',
      ),
    );
  }
}
