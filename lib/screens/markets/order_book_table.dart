import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';

class OrderBookTable extends StatelessWidget {
  const OrderBookTable({
    @required this.buyCoin,
    @required this.sellCoin,
    @required this.asks,
    @required this.bids,
  });

  final Coin buyCoin;
  final Coin sellCoin;
  final List<Ask> asks;
  final List<Ask> bids;

  @override
  Widget build(BuildContext context) {
    final TableRow _tableHeader = TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0),
          child: Text(
            'Price (${sellCoin.abbr})',
            maxLines: 1,
          ),
        ), // TODO(yurii): localization
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Amount (${buyCoin.abbr})',
              maxLines: 1,
            ),
          ),
        ), // TODO(yurii): localization
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total (${buyCoin.abbr})',
              maxLines: 1,
            ),
          ),
        ), // TODO(yurii): localization
      ],
    );

    final List<Ask> _sortedAsks = _sortByPrice(asks);
    List<TableRow> _asksList = [];
    double _askTotal = 0;

    for (int i = 0; i < _sortedAsks.length; i++) {
      final Ask ask = _sortedAsks[i];
      _askTotal += ask.maxvolume.toDouble();

      _asksList.add(TableRow(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              _formatted(ask.price),
              maxLines: 1,
              style: TextStyle(color: Colors.red),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatted(ask.maxvolume.toString()),
              maxLines: 1,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatted(_askTotal.toString()),
              maxLines: 1,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
        ],
      ));
    }
    _asksList = List.from(_asksList.reversed);
    if (_asksList.isEmpty) {
      _asksList.add(TableRow(
        children: [
          Text(
            'No asks found', // TODO(yurii): localization
            maxLines: 1,
            style: TextStyle(color: Colors.red),
          ), Container(), Container(),
        ],
      ));
    }

    final List<Ask> _sortedBids = List.from(_sortByPrice(bids).reversed);
    final List<TableRow> _bidsList = [];
    double _bidTotal = 0;

    for (int i = 0; i < _sortedBids.length; i++) {
      final Ask bid = _sortedBids[i];
      final double _bidVolume =
          bid.maxvolume.toDouble() / double.parse(bid.price);
      _bidTotal += _bidVolume;

      _bidsList.add(TableRow(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              _formatted(bid.price),
              maxLines: 1,
              style: TextStyle(color: Colors.green),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatted(_bidVolume.toString()),
              maxLines: 1,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatted(_bidTotal.toString()),
              maxLines: 1,
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
        ],
      ));
    }
    if (_bidsList.isEmpty) {
      _bidsList.add(TableRow(
        children: [
          Text(
            'No bids found', // TODO(yurii): localization
            maxLines: 1,
            style: TextStyle(color: Colors.green),
          ), Container(), Container(),
        ],
      ));
    }

    const TableRow _spacer = TableRow(
      children: [
        SizedBox(height: 12),
        SizedBox(height: 12),
        SizedBox(height: 12),
      ],
    );

    return Container(
      padding: const EdgeInsets.only(
        top: 20,
        left: 8,
        right: 8,
      ),
      child: Table(
        children: [
          _tableHeader,
          _spacer,
          ..._asksList,
          _spacer,
          ..._bidsList,
        ],
      ),
    );
  }

  List<Ask> _sortByPrice(List<Ask> list) {
    final List<Ask> sorted = list;
    sorted
        .sort((a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
    return sorted;
  }

  String _formatted(String value) {
    const int digits = 6;
    const int fraction = 2;

    final String rounded = double.parse(value).toStringAsFixed(fraction);
    if (rounded.length >= digits + 1) {
      return rounded;
    } else {
      return double.parse(value).toStringAsPrecision(digits);
    }
  }
}
