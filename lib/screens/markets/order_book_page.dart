import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
import 'package:komodo_dex/screens/markets/order_book_chart.dart';
import 'package:komodo_dex/screens/markets/order_book_table.dart';
import 'package:provider/provider.dart';

class OrderBookPage extends StatefulWidget {
  const OrderBookPage();

  @override
  _OrderBookPageState createState() => _OrderBookPageState();
}

class _OrderBookPageState extends State<OrderBookPage> {
  OrderBookProvider _orderBookProvider;

  @override
  Widget build(BuildContext context) {
    _orderBookProvider = Provider.of<OrderBookProvider>(context);

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
                  value: _orderBookProvider.activeCoins?.buy,
                  type: CoinType.base,
                  pairedCoin: _orderBookProvider.activeCoins?.sell,
                  autoOpen: _orderBookProvider.activeCoins?.buy == null &&
                      _orderBookProvider.activeCoins?.sell != null,
                  onChange: (Coin value) {
                    _orderBookProvider.activeCoins = CoinsPair(
                      buy: value,
                      sell: _orderBookProvider.activeCoins?.sell,
                    );
                  }),
              const SizedBox(width: 12),
              ButtonTheme(
                minWidth: 30,
                child: FlatButton(
                    onPressed: () {
                      _orderBookProvider.activeCoins = CoinsPair(
                        buy: _orderBookProvider.activeCoins?.sell,
                        sell: _orderBookProvider.activeCoins?.buy,
                      );
                    },
                    child: Icon(Icons.swap_horiz)),
              ),
              const SizedBox(width: 12),
              CoinSelect(
                value: _orderBookProvider.activeCoins?.sell,
                type: CoinType.rel,
                pairedCoin: _orderBookProvider.activeCoins?.buy,
                autoOpen: _orderBookProvider.activeCoins?.sell == null &&
                      _orderBookProvider.activeCoins?.buy != null,
                onChange: (Coin value) {
                  _orderBookProvider.activeCoins = CoinsPair(
                    sell: value,
                    buy: _orderBookProvider.activeCoins?.buy,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBook() {
    if (_orderBookProvider.activeCoins?.buy == null ||
        _orderBookProvider.activeCoins?.sell == null) {
      return const Center(
        heightFactor: 10,
        child: Text('Please select coins'), // TODO(yurii): localization
      );
    }

    final Orderbook _orderBook = _orderBookProvider.getOrderBook();

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
          asks: _orderBook.asks,
          bids: _orderBook.bids,
        ),
      ],
    );
  }
}
