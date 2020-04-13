import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/orderbook.dart';

class OrderBookChart extends StatelessWidget {

const OrderBookChart({
    @required this.asks,
    @required this.bids,
  });

  final List<Ask> asks;
  final List<Ask> bids;

  @override
  Widget build(BuildContext context) {
    final List<double> _askTotals = [];
    final List<double> _bidTotals = [];
    double _maxAmount;

    final List<Ask> _sortedAsks = _sortByPrice(asks);
    final List<Ask> _sortedBids =
        List.from(_sortByPrice(bids).reversed);

    for (int i = 0; i < _sortedAsks.length; i++) {
      final double prevTotal = i > 0 ? _askTotals[_askTotals.length - 1] : 0;
      _askTotals.add(prevTotal + _sortedAsks[i].maxvolume.toDouble());
    }

    for (int i = 0; i < _sortedBids.length; i++) {
      final double prevTotal = i > 0 ? _bidTotals[_bidTotals.length - 1] : 0;
      final Ask bid = _sortedBids[i];
      _bidTotals.add(
          prevTotal + (bid.maxvolume.toDouble() / double.parse(bid.price)));
    }

    _maxAmount = max(
      _askTotals.isNotEmpty ? _askTotals[_askTotals.length - 1] : 0,
      _bidTotals.isNotEmpty ? _bidTotals[_bidTotals.length - 1] : 0,
    );

    if (_maxAmount == 0) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 69, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...List.from(_askTotals
              .map((double total) {
                return FractionallySizedBox(
                  widthFactor: total / _maxAmount,
                  child: Container(
                    height: 20,
                    color: const Color.fromARGB(60, 255, 0, 0),
                  ),
                );
              })
              .toList()
              .reversed),
          const SizedBox(height: 12),
          ..._bidTotals.map((double total) {
            return FractionallySizedBox(
              widthFactor: total / _maxAmount,
              child: Container(
                height: 20,
                color: const Color.fromARGB(60, 0, 255, 0),
              ),
            );
          }).toList(),
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
}