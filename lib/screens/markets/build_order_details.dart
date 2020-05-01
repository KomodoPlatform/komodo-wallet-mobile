import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:provider/provider.dart';

class BuildOrderDetails extends StatefulWidget {
  const BuildOrderDetails(this.order);

  final Ask order;

  @override
  _BuildOrderDetailsState createState() => _BuildOrderDetailsState();
}

class _BuildOrderDetailsState extends State<BuildOrderDetails> {
  @override
  Widget build(BuildContext context) {
    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    final CoinsPair _activePair = _orderBookProvider.activePair;
    final bool _isAsk = _activePair.buy.abbr == widget.order.coin;

    return Card(
      elevation: 8,
      color: Theme.of(context).primaryColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 16,
          right: 12,
          top: 12,
          bottom: 24,
        ),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(1.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('Selling', // TODO(yurii): localization
                      style: Theme.of(context).textTheme.body2),
                ),
                Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: 7,
                      tag: _isAsk
                          ? 'assets/${_activePair.buy.abbr.toLowerCase()}.png'
                          : 'assets/${_activePair.sell.abbr.toLowerCase()}.png',
                    ),
                    const SizedBox(width: 4),
                    Text(_isAsk ? _activePair.buy.abbr : _activePair.sell.abbr),
                    const SizedBox(width: 12),
                    Text(
                      OrderBookProvider.formatPrice(
                          widget.order.maxvolume.toString()),
                      style: Theme.of(context).textTheme.subtitle.copyWith(
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
                  child: Text('for', // TODO(yurii): localization
                      style: Theme.of(context).textTheme.body2),
                ),
                Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: 7,
                      tag: _isAsk
                          ? 'assets/${_activePair.sell.abbr.toLowerCase()}.png'
                          : 'assets/${_activePair.buy.abbr.toLowerCase()}.png',
                    ),
                    const SizedBox(width: 4),
                    Text(_isAsk ? _activePair.sell.abbr : _activePair.buy.abbr),
                    const SizedBox(width: 12),
                    Text(
                      OrderBookProvider.formatPrice(
                          '${widget.order.maxvolume.toDouble() * double.parse(widget.order.price)}'),
                      style: Theme.of(context).textTheme.subtitle.copyWith(
                            fontWeight: FontWeight.normal,
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
                  child:
                      Text('Price', style: Theme.of(context).textTheme.body2),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      OrderBookProvider.formatPrice(
                          '${_isAsk ? widget.order.price : (1 / double.parse(widget.order.price)).toString()}'),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle
                          .copyWith(color: _isAsk ? Colors.red : Colors.green),
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
                      OrderBookProvider.formatPrice(
                          '${!_isAsk ? widget.order.price : (1 / double.parse(widget.order.price)).toString()}'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_activePair.buy.abbr} / 1${_activePair.sell.abbr}',
                      style: TextStyle(
                          fontSize: 13, color: Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
