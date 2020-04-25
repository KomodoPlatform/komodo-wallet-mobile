import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        : (widget.order.maxvolume.toDouble() / double.parse(widget.order.price));

    return Card(
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
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
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
                      OrderBookProvider.formatPrice('${widget.order.price}'),
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
                          fontSize: 13, color: Theme.of(context).disabledColor),
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
                      Text('address', style: Theme.of(context).textTheme.body2),
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
                            contentPadding: EdgeInsets.only(left: 6, right: 6),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            _addressController.text = widget.order.address;
                          },
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: 40,
                      child: FlatButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.order.address));
                          Scaffold.of(context).showSnackBar(SnackBar(
                              action: SnackBarAction(
                                  label: 'Close',
                                  onPressed: () {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                  }),
                              backgroundColor: Theme.of(context).highlightColor,
                              content: Text(
                                'Copied to clipboard',
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ))); // TODO(yurii): localization
                        },
                        child: const Icon(Icons.content_copy, size: 16),
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
                      tag: 'assets/${_activePair.buy.abbr.toLowerCase()}.png',
                    ),
                    const SizedBox(width: 4),
                    Text(_activePair.buy.abbr),
                    const SizedBox(width: 12),
                    Text(
                      OrderBookProvider.formatPrice('$_volume'),
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
                  child: Text(_isAsk ? 'for' : 'with',
                      style: Theme.of(context).textTheme.body2),
                ),
                Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: 7,
                      tag: 'assets/${_activePair.sell.abbr.toLowerCase()}.png',
                    ),
                    const SizedBox(width: 4),
                    Text(_activePair.sell.abbr),
                    const SizedBox(width: 12),
                    Text(
                      OrderBookProvider.formatPrice(
                          '${_volume * double.parse(widget.order.price)}'),
                      style: Theme.of(context).textTheme.subtitle.copyWith(
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
    );
  }
}
