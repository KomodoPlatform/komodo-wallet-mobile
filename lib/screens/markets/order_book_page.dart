import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage({this.buyCoin, this.sellCoin, this.onPairChange});

  final Coin buyCoin;
  final Coin sellCoin;
  final Function(CoinsPair) onPairChange;

  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  Timer ticker;

  @override
  void initState() {
    super.initState();

    ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (ticker != null) ticker.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildPairSelect(),
            _buildTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPairSelect() {
    return Container(
      child: Card(
        elevation: 8,
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CoinSelect(
                  value: widget.buyCoin,
                  onChange: (Coin value) {
                    widget.onPairChange(CoinsPair(buy: value));
                  }),
              const SizedBox(width: 12),
              Text(
                '/',
                style:
                    Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18),
              ),
              const SizedBox(width: 12),
              CoinSelect(
                value: widget.sellCoin,
                onChange: (Coin value) {
                  widget.onPairChange(CoinsPair(sell: value));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Orderbook> _getOrderBooks() async {
    return await MM.getOrderbook(MMService().client,
        GetOrderbook(base: widget.buyCoin.abbr, rel: widget.sellCoin.abbr));
  }

  Widget _buildTable(BuildContext context) {
    if (widget.buyCoin == null || widget.sellCoin == null) {
      return const Center(
        heightFactor: 10,
        child: Text('Please select coins'), // TODO(yurii): localization
      );
    }

    return FutureBuilder<Orderbook>(
        future: _getOrderBooks(),
        builder: (BuildContext context, AsyncSnapshot<Orderbook> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              heightFactor: 10,
              child: CircularProgressIndicator(),
            );
          }

          final TableRow _tableHeader = TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Price (${widget.sellCoin.abbr})'),
              ), // TODO(yurii): localization
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Amount (${widget.buyCoin.abbr})'),
                ),
              ), // TODO(yurii): localization
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Total (${widget.buyCoin.abbr})'),
                ),
              ), // TODO(yurii): localization
            ],
          );

          final List<Ask> sortedAsks = _sortByPrice(snapshot.data.asks);
          List<TableRow> asksList = [];
          double askTotal = 0;

          for (int i = 0; i < sortedAsks.length; i++) {
            final Ask ask = sortedAsks[i];
            askTotal += ask.maxvolume.toDouble();
            asksList.add(TableRow(
              children: <Widget>[
                Text(
                  _formatted(ask.price),
                  style: TextStyle(color: Colors.pink),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatted(ask.maxvolume.toString()),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatted(askTotal.toString()),
                  ),
                ),
              ],
            ));
          }
          asksList = List.from(asksList.reversed);

          final List<Ask> sortedBids =
              List.from(_sortByPrice(snapshot.data.bids).reversed);
          final List<TableRow> bidsList = [];
          double bidTotal = 0;

          for (int i = 0; i < sortedBids.length; i++) {
            final Ask bid = sortedBids[i];
            final double _bidVolume =
                bid.maxvolume.toDouble() / double.parse(bid.price);
            bidTotal += _bidVolume;
            bidsList.add(TableRow(
              children: <Widget>[
                Text(
                  _formatted(bid.price),
                  style: TextStyle(color: Colors.green),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatted(_bidVolume.toString()),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatted(bidTotal.toString()),
                  ),
                ),
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
                ...asksList,
                _spacer,
                ...bidsList,
              ],
            ),
          );
        });
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
