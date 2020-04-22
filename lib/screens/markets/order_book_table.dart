import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/health_indicator.dart';
import 'package:provider/provider.dart';

class OrderBookTable extends StatelessWidget {
  const OrderBookTable({
    @required this.sortedAsks,
    @required this.sortedBids,
  });

  final List<Ask> sortedAsks;
  final List<Ask> sortedBids;

  @override
  Widget build(BuildContext context) {
    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);

    final TableRow _tableHeader = TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4),
          child: Text(
            'Price (${_orderBookProvider.activePair.sell.abbr})',
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ), // TODO(yurii): localization
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Amt. (${_orderBookProvider.activePair.buy.abbr})',
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ), // TODO(yurii): localization
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Total (${_orderBookProvider.activePair.buy.abbr})',
              maxLines: 1,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 15, left: 8, right: 4),
          child: HealthIndicator(50, color: Colors.white),
        ), // TODO(yurii): localization
      ],
    );

    final List<Ask> _sortedAsks = sortedAsks;
    List<TableRow> _asksList = [];
    double _askTotal = 0;

    for (int i = 0; i < _sortedAsks.length; i++) {
      final Ask ask = _sortedAsks[i];
      _askTotal += ask.maxvolume.toDouble();

      _asksList.add(TableRow(
        children: <Widget>[
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
              child: Text(
                _formatted(ask.price),
                maxLines: 1,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                _formatted(ask.maxvolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                _formatted(_askTotal.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 4),
              child: HealthIndicator(
                  _orderBookProvider.getOrderHealth(ask).rating),
            ),
          ),
        ],
      ));
    }
    _asksList = List.from(_asksList.reversed);
    if (_asksList.isEmpty) {
      _asksList.add(TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'No asks found', // TODO(yurii): localization
              maxLines: 1,
              style: TextStyle(color: Colors.red),
            ),
          ),
          Container(),
          Container(),
          Container(),
        ],
      ));
    }

    final List<Ask> _sortedBids = List.from(sortedBids.reversed);
    final List<TableRow> _bidsList = [];
    double _bidTotal = 0;

    for (int i = 0; i < _sortedBids.length; i++) {
      final Ask bid = _sortedBids[i];
      final double _bidVolume =
          bid.maxvolume.toDouble() / double.parse(bid.price);
      _bidTotal += _bidVolume;

      _bidsList.add(TableRow(
        children: <Widget>[
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Padding(
              padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
              child: Text(
                _formatted(bid.price),
                maxLines: 1,
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              alignment: Alignment.centerRight,
              child: Text(
                _formatted(_bidVolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              alignment: Alignment.centerRight,
              child: Text(
                _formatted(_bidTotal.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 4),
              child: HealthIndicator(
                  _orderBookProvider.getOrderHealth(bid).rating),
            ),
          ),
        ],
      ));
    }
    if (_bidsList.isEmpty) {
      _bidsList.add(TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              'No bids found', // TODO(yurii): localization
              maxLines: 1,
              style: TextStyle(color: Colors.green),
            ),
          ),
          Container(),
          Container(),
          Container(),
        ],
      ));
    }

    const TableRow _spacer = TableRow(
      children: [
        SizedBox(height: 12),
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
        columnWidths: const {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
          3: IntrinsicColumnWidth(),
        },
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

  void _showOrderDetails(Ask order) {}
}
