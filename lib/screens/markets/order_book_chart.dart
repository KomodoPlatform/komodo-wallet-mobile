import 'dart:math';

import 'package:flutter/material.dart';
import '../../model/orderbook.dart';

class OrderBookChart extends StatelessWidget {
  const OrderBookChart({
    @required this.sortedAsks,
    @required this.sortedBids,
  });

  final List<Ask> sortedAsks;
  final List<Ask> sortedBids;

  @override
  Widget build(BuildContext context) {
    final List<double> _askTotals = [];
    final List<double> _bidTotals = [];

    for (int i = 0; i < sortedAsks.length; i++) {
      final double prevTotal = i > 0 ? _askTotals[_askTotals.length - 1] : 0;
      _askTotals.add(prevTotal + sortedAsks[i].maxvolume.toDouble());
    }

    for (int i = 0; i < sortedBids.length; i++) {
      final double prevTotal = i > 0 ? _bidTotals[_bidTotals.length - 1] : 0;
      final Ask bid = sortedBids[i];
      _bidTotals.add(prevTotal + (bid.maxvolume.toDouble()));
    }

    double _maxAmount = max(
      _askTotals.isNotEmpty ? _askTotals[_askTotals.length - 1] : 0,
      _bidTotals.isNotEmpty ? _bidTotals[_bidTotals.length - 1] : 0,
    );

    if (_maxAmount == 0) return SizedBox();

    final List<Widget> _asksList = [];
    for (int i = 0; i < _askTotals.length; i++) {
      _asksList.add(
        Stack(
          children: <Widget>[
            Positioned(
                child: FractionallySizedBox(
              widthFactor: (_askTotals[i] / _maxAmount) -
                  (i > 0 ? (_askTotals[i - 1] / _maxAmount) : 0),
              child: Container(
                  height: 26,
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.red,
                    width: 1,
                  )))),
            )),
            FractionallySizedBox(
              widthFactor: _askTotals[i] / _maxAmount,
              child: Container(
                height: 26,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(40, 255, 0, 0),
                    border: Border(
                        left: BorderSide(
                      color: Colors.red,
                      width: 1,
                    ))),
              ),
            ),
          ],
        ),
      );
    }
    if (_asksList.isEmpty) {
      _asksList.add(Container(
        height: 26,
      ));
    }

    final List<Widget> _bidsList = [];
    for (int i = 0; i < _bidTotals.length; i++) {
      _bidsList.add(
        Stack(
          children: <Widget>[
            Positioned(
                child: FractionallySizedBox(
              widthFactor: (_bidTotals[i] / _maxAmount) -
                  (i > 0 ? (_bidTotals[i - 1] / _maxAmount) : 0),
              child: Container(
                  height: 26,
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                    color: Colors.green,
                    width: 1,
                  )))),
            )),
            FractionallySizedBox(
              widthFactor: _bidTotals[i] / _maxAmount,
              child: Container(
                height: 26,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(40, 0, 255, 0),
                    border: Border(
                        left: BorderSide(
                      color: Colors.green,
                      width: 1,
                    ))),
              ),
            ),
          ],
        ),
      );
    }
    if (_bidsList.isEmpty) {
      _bidsList.add(Container(
        height: 26,
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 46, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          ..._asksList.reversed.toList(),
          const SizedBox(height: 26),
          ..._bidsList,
        ],
      ),
    );
  }
}
