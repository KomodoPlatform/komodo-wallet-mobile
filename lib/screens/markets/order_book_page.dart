import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/screens/markets/order_book_chart.dart';
import 'package:komodo_dex/screens/markets/order_book_table.dart';
import 'package:provider/provider.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage({this.buyCoin, this.sellCoin, this.onPairChange});

  final Coin buyCoin;
  final Coin sellCoin;
  final Function(CoinsPair) onPairChange;

  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  Timer _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_ticker != null) _ticker.cancel();

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
            _buildOrderBook(),
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
                  type: CoinType.base,
                  pairedCoin: widget.sellCoin,
                  onChange: (Coin value) {
                    widget.onPairChange(CoinsPair(buy: value));
                  }),
              const SizedBox(width: 12),
              ButtonTheme(
                minWidth: 30,
                child: FlatButton(
                    onPressed: () {
                      widget.onPairChange(CoinsPair(
                        buy: widget.sellCoin,
                        sell: widget.buyCoin,
                      ));
                    },
                    child: Icon(Icons.swap_horiz)),
              ),
              const SizedBox(width: 12),
              CoinSelect(
                value: widget.sellCoin,
                type: CoinType.rel,
                pairedCoin: widget.buyCoin,
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

  Widget _buildOrderBook() {
    if (widget.buyCoin == null || widget.sellCoin == null) {
      return const Center(
        heightFactor: 10,
        child: Text('Please select coins'), // TODO(yurii): localization
      );
    }

    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    final Orderbook _orderBook = _orderBookProvider.getOrderBook(
      CoinsPair(
        buy: widget.buyCoin,
        sell: widget.sellCoin,
      ),
    );

    if (_orderBook == null) {
      return const Center(
        heightFactor: 10,
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: <Widget>[
        OrderBookChart(
          asks: _orderBook.asks,
          bids: _orderBook.bids,
        ),
        OrderBookTable(
          buyCoin: widget.buyCoin,
          sellCoin: widget.sellCoin,
          asks: _orderBook.asks,
          bids: _orderBook.bids,
        ),
      ],
    );
  }
}
