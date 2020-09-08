import 'package:flutter/material.dart';
import 'package:komodo_dex/model/addressbook_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/addressbook/addressbook_page.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuildOrderDetails extends StatefulWidget {
  const BuildOrderDetails(this.order);

  final Ask order;

  @override
  _BuildOrderDetailsState createState() => _BuildOrderDetailsState();
}

class _BuildOrderDetailsState extends State<BuildOrderDetails> {
  OrderBookProvider _orderBookProvider;
  AddressBookProvider _addressBookProvider;

  @override
  Widget build(BuildContext context) {
    _orderBookProvider ??= Provider.of<OrderBookProvider>(context);
    _addressBookProvider ??= Provider.of<AddressBookProvider>(context);
    final Contact contact =
        _addressBookProvider.contactByAddress(widget.order.address);

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
            if (contact != null)
              TableRow(
                children: [
                  Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(right: 6),
                    child: Text('Address', // TODO(yurii): localization
                        style: Theme.of(context).textTheme.body2),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => AddressBookPage(
                              contact: contact,
                            ),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 6),
                      height: 40,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.account_circle,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact.name,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            TableRow(
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(right: 6),
                  child: Text('Selling', // TODO(yurii): localization
                      style: Theme.of(context).textTheme.body2),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 7,
                        backgroundImage: _isAsk
                            ? AssetImage('assets/'
                                '${_activePair.buy.abbr.toLowerCase()}.png')
                            : AssetImage('assets/'
                                '${_activePair.sell.abbr.toLowerCase()}.png'),
                      ),
                      const SizedBox(width: 4),
                      Text(_isAsk
                          ? _activePair.buy.abbr
                          : _activePair.sell.abbr),
                      const SizedBox(width: 12),
                      Text(
                        formatPrice(widget.order.maxvolume.toString()),
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(right: 6),
                  child: Text('for', // TODO(yurii): localization
                      style: Theme.of(context).textTheme.body2),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 7,
                        backgroundImage: _isAsk
                            ? AssetImage(
                                'assets/${_activePair.sell.abbr.toLowerCase()}.png')
                            : AssetImage(
                                'assets/${_activePair.buy.abbr.toLowerCase()}.png'),
                      ),
                      const SizedBox(width: 4),
                      Text(_isAsk
                          ? _activePair.sell.abbr
                          : _activePair.buy.abbr),
                      const SizedBox(width: 12),
                      Text(
                        formatPrice(
                            '${widget.order.maxvolume.toDouble() * double.parse(widget.order.price)}'),
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
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
                  padding: const EdgeInsets.only(right: 6),
                  child:
                      Text('Price', style: Theme.of(context).textTheme.body2),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: <Widget>[
                      Text(
                        formatPrice(
                            '${_isAsk ? widget.order.price : (1 / double.parse(widget.order.price)).toString()}'),
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                            color: _isAsk ? Colors.red : Colors.green),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_activePair.sell.abbr} / 1${_activePair.buy.abbr}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Container(),
                Container(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: <Widget>[
                      Text(
                        formatPrice(
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
                            fontSize: 13,
                            color: Theme.of(context).disabledColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
