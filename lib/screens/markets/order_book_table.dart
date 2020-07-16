import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/order_details_page.dart';
import 'package:komodo_dex/utils/utils.dart';
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

    void _showOrderDetails(Ask order) {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => OrderDetailsPage(
                    order: order,
                  )));
    }

    final TableRow _tableHeader = TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Container(
          height: 34,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Price (${_orderBookProvider.activePair.sell.abbr})',
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ), // TODO(yurii): localization
        Container(
          height: 34,
          alignment: Alignment.centerRight,
          child: Text(
            'Amt. (${_orderBookProvider.activePair.buy.abbr})',
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ),
        ), // TODO(yurii): localization
        Container(
          padding: const EdgeInsets.only(right: 4),
          height: 34,
          alignment: Alignment.centerRight,
          child: Text(
            'Total (${_orderBookProvider.activePair.buy.abbr})',
            maxLines: 1,
            style: const TextStyle(fontSize: 14),
          ), // TODO(yurii): localization
        ),
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
            child: Container(
              height: 26,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                formatPrice(ask.price),
                maxLines: 1,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(ask.maxvolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(ask),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                formatPrice(_askTotal.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
        ],
      ));
    }
    _asksList = List.from(_asksList.reversed);
    if (_asksList.isEmpty) {
      _asksList.add(TableRow(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 26,
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'No asks found', // TODO(yurii): localization
              maxLines: 1,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
          Container(),
          Container(),
        ],
      ));
    }

    final List<Ask> _sortedBids = List.from(sortedBids);
    final List<TableRow> _bidsList = [];
    double _bidTotal = 0;

    for (int i = 0; i < _sortedBids.length; i++) {
      final Ask bid = _sortedBids[i];
      final double _bidVolume =
          bid.maxvolume.toDouble() * double.parse(bid.price);
      _bidTotal += _bidVolume;

      _bidsList.add(TableRow(
        children: <Widget>[
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              height: 26,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                formatPrice((1 / double.parse(bid.price)).toString()),
                maxLines: 1,
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              child: Text(
                formatPrice(_bidVolume.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
          TableRowInkWell(
            onTap: () => _showOrderDetails(bid),
            child: Container(
              height: 26,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                formatPrice(_bidTotal.toString()),
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).disabledColor, fontSize: 14),
              ),
            ),
          ),
        ],
      ));
    }
    if (_bidsList.isEmpty) {
      _bidsList.add(TableRow(
        children: [
          Container(
            height: 26,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              'No bids found', // TODO(yurii): localization
              maxLines: 1,
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
          ),
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
      ],
    );

    return Container(
      padding: const EdgeInsets.only(
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
}
