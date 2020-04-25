import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/health_indicator.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({
    this.order,
  });

  final Ask order;

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _addressController.text = widget.order.address;
  }

  @override
  Widget build(BuildContext context) {
    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    final CoinsPair _activePair = _orderBookProvider.activePair;
    final bool _isAsk = _activePair.buy.abbr == widget.order.coin;
    final double _volume = _isAsk
        ? widget.order.maxvolume.toDouble()
        : (widget.order.maxvolume.toDouble() /
            double.parse(widget.order.price));
    final OrderHealth _orderHealth =
        _orderBookProvider.getOrderHealth(widget.order);

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
                Card(
                  elevation: 8,
                  color: Theme.of(context).primaryColor,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(1.0),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(right: 12),
                              child: Text('Price',
                                  style: Theme.of(context).textTheme.body2),
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  OrderBookProvider.formatPrice(
                                      '${widget.order.price}'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle
                                      .copyWith(
                                          color: _isAsk
                                              ? Colors.red
                                              : Colors.green),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_activePair.sell.abbr} / 1${_activePair.buy.abbr}',
                                ),
                              ],
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Container(),
                            Row(
                              children: <Widget>[
                                Text(
                                  '${OrderBookProvider.formatPrice((1 / double.parse(widget.order.price)).toString())}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_activePair.buy.abbr} / 1${_activePair.sell.abbr}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).disabledColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const TableRow(children: [
                          SizedBox(height: 15),
                          SizedBox(height: 15),
                        ]),
                        TableRow(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.order.coin,
                                      style: Theme.of(context).textTheme.body2),
                                  Text('address',
                                      style: Theme.of(context).textTheme.body2),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    height: 35,
                                    child: TextField(
                                      controller: _addressController,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(left: 6, right: 6),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (_) {
                                        _addressController.text =
                                            widget.order.address;
                                      },
                                    ),
                                  ),
                                ),
                                ButtonTheme(
                                  minWidth: 40,
                                  child: FlatButton(
                                    padding: const EdgeInsets.all(0),
                                    onPressed: () {},
                                    child: Icon(Icons.content_copy, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const TableRow(children: [
                          SizedBox(height: 15),
                          SizedBox(height: 15),
                        ]),
                        TableRow(
                          children: [
                            Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(_isAsk ? 'Selling' : 'Buying',
                                  style: Theme.of(context).textTheme.body2),
                            ),
                            Row(
                              children: <Widget>[
                                PhotoHero(
                                  radius: 7,
                                  tag:
                                      'assets/${_activePair.buy.abbr.toLowerCase()}.png',
                                ),
                                const SizedBox(width: 4),
                                Text(_activePair.buy.abbr),
                                const SizedBox(width: 12),
                                Text(
                                  OrderBookProvider.formatPrice('$_volume'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle
                                      .copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(_isAsk ? 'for' : 'with',
                                  style: Theme.of(context).textTheme.body2),
                            ),
                            Row(
                              children: <Widget>[
                                PhotoHero(
                                  radius: 7,
                                  tag:
                                      'assets/${_activePair.sell.abbr.toLowerCase()}.png',
                                ),
                                const SizedBox(width: 4),
                                Text(_activePair.sell.abbr),
                                const SizedBox(width: 12),
                                Text(
                                  OrderBookProvider.formatPrice(
                                      '${_volume * double.parse(widget.order.price)}'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle
                                      .copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(
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
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('80%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                      'All time swaps: 100, successfull: 80',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                          )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('60%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                      'Last 24 hours swaps: 10, successfull: 6',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                          )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('90%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                      'Total swaps amount: over 10000${widget.order.coin}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                          )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('70%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text('Online status score',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                          )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('85%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text('Order age: less than 1h',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                          )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('95%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                      'Average order lifetime: less than 1h',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.normal,
                                          )),
                                )
                              ]),
                              TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    child: const Text('95%',
                                        style: TextStyle(fontSize: 14))),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                      'Average swap duration: less than 10m',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
