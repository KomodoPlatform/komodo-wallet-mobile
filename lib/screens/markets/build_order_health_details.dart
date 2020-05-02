import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:provider/provider.dart';

import 'health_indicator.dart';

class BuildOrderHealthDetails extends StatelessWidget {
  const BuildOrderHealthDetails(this.order);

  final Ask order;

  @override
  Widget build(BuildContext context) {
    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);

    final OrderHealth _orderHealth = _orderBookProvider.getOrderHealth(order);

    return Card(
      elevation: 8,
      color: Theme.of(context).primaryColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                HealthIndicator(
                  _orderHealth.rating,
                  size: 35,
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Order Health Score:',
                        style: Theme.of(context).textTheme.body2.copyWith(
                              fontWeight: FontWeight.normal,
                            )),
                    Text(
                      '${_orderHealth.rating.toString()}%',
                      style: Theme.of(context).textTheme.subtitle,
                    )
                  ],
                )
              ],
            ),
            const Divider(
              height: 30,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 55,
              ),
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(1.0),
                },
                children: [
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('80%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('All time swaps: 100, successfull: 80',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('60%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Last 24 hours swaps: 10, successfull: 6',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('90%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                          'Total swaps amount: over 10000${order.coin}',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('70%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Online status score',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('85%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Order age: less than 1h',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('95%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Average order lifetime: less than 1h',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                  TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 12, bottom: 12),
                        child:
                            const Text('95%', style: TextStyle(fontSize: 14))),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Average swap duration: less than 10m',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
