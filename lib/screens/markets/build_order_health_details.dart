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
    if (order == null) return Container();

    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);

    final OrderHealth _orderHealth = _orderBookProvider.getOrderHealth(order);
    if (_orderHealth == null) return Container();

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
                children: _orderHealth.markers.map((_marker) {
                  return TableRow(children: [
                    Container(
                        padding: const EdgeInsets.only(right: 6, bottom: 12, top: 3),
                        child: _marker.sign == '+'
                            ? const Icon(Icons.thumb_up, size: 14)
                            : const Icon(Icons.thumb_down, size: 14)),
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('${_marker.defaultDesc}',
                          style: Theme.of(context).textTheme.body2.copyWith(
                                fontWeight: FontWeight.normal,
                              )),
                    )
                  ]);
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
