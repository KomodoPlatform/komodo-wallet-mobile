import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/screens/markets/markets_page.dart';
import 'package:komodo_dex/screens/markets/order_book_chart.dart';
import 'package:komodo_dex/screens/markets/order_book_table.dart';
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
            FutureBuilder(
              future: _getOrderBook(),
              builder: (
                BuildContext context,
                AsyncSnapshot<Orderbook> snapshot,
              ) {
                if (widget.buyCoin == null || widget.sellCoin == null) {
                  return const Center(
                    heightFactor: 10,
                    child: Text(
                        'Please select coins'), // TODO(yurii): localization
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    heightFactor: 10,
                    child: CircularProgressIndicator(),
                  );
                }

                return Stack(
                  children: <Widget>[
                    OrderBookChart(
                      asks: snapshot.data.asks,
                      bids: snapshot.data.bids,
                    ),
                    OrderBookTable(
                      buyCoin: widget.buyCoin,
                      sellCoin: widget.sellCoin,
                      asks: snapshot.data.asks,
                      bids: snapshot.data.bids,
                    ),
                  ],
                );
              },
            ),
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
                  disabledOption: widget.sellCoin,
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
                disabledOption: widget.buyCoin,
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

  Future<Orderbook> _getOrderBook() async {
    return await MM.getOrderbook(MMService().client,
        GetOrderbook(base: widget.buyCoin.abbr, rel: widget.sellCoin.abbr));
  }
}
