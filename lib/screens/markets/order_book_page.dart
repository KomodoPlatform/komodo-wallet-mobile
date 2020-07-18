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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CoinSelect(
                  key: const Key('coin-select-left'),
                  value: _orderBookProvider.activePair?.buy,
                  type: CoinType.base,
                  pairedCoin: _orderBookProvider.activePair?.sell,
                  autoOpen: _orderBookProvider.activePair?.buy == null &&
                      _orderBookProvider.activePair?.sell != null,
                  compact: MediaQuery.of(context).size.width < 360,
                  hideInactiveCoins: false,
                  onChange: (Coin value) {
                    _orderBookProvider.activePair = CoinsPair(
                      buy: value,
                      sell: _orderBookProvider.activePair?.sell,
                    );
                  }),
              const SizedBox(width: 12),
              ButtonTheme(
                minWidth: 40,
                child: FlatButton(
                    key: const Key('coin-select-swap'),
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      _orderBookProvider.activePair = CoinsPair(
                        buy: _orderBookProvider.activePair?.sell,
                        sell: _orderBookProvider.activePair?.buy,
                      );
                    },
                    child: Icon(Icons.swap_horiz)),
              ),
              const SizedBox(width: 12),
              CoinSelect(
                key: const Key('coin-select-right'),
                value: _orderBookProvider.activePair?.sell,
                type: CoinType.rel,
                pairedCoin: _orderBookProvider.activePair?.buy,
                autoOpen: _orderBookProvider.activePair?.sell == null &&
                    _orderBookProvider.activePair?.buy != null,
                compact: MediaQuery.of(context).size.width < 360,
                hideInactiveCoins: false,
                onChange: (Coin value) {
                  _orderBookProvider.activePair = CoinsPair(
                    sell: value,
                    buy: _orderBookProvider.activePair?.buy,
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
    if (_orderBookProvider.activePair?.buy == null ||
        _orderBookProvider.activePair?.sell == null) {
      return const Center(
        heightFactor: 10,
        child: Text('Please select coins'), // TODO(yurii): localization
      );
    }

    Orderbook _pairOrderBook;

    try {
      _pairOrderBook = _orderBookProvider.getOrderBook();
    } catch (_) {
    }

    if (_pairOrderBook == null) {
      return const Center(heightFactor: 10, child: CircularProgressIndicator());
    }

    final List<Ask> _sortedAsks =
        OrderBookProvider.sortByPrice(_pairOrderBook.asks);
    final List<Ask> _sortedBids =
        OrderBookProvider.sortByPrice(_pairOrderBook.bids, quotePrice: true);

    return Stack(
      children: <Widget>[
        OrderBookChart(
          sortedAsks: _sortedAsks,
          sortedBids: _sortedBids,
        ),
        OrderBookTable(
          sortedAsks: _sortedAsks,
          sortedBids: _sortedBids,
        ),
      ],
    );
  }
}
