import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/markets/candlestick_chart.dart';
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

    Orderbook _asksOrderBook;
    Orderbook _bidsOrderBook;

    try {
      _asksOrderBook = _orderBookProvider.getOrderBook() ?? Orderbook(bids: []);
      _bidsOrderBook = _orderBookProvider.getOrderBook(CoinsPair(
            buy: _orderBookProvider.activePair.sell,
            sell: _orderBookProvider.activePair.buy,
          )) ??
          Orderbook(bids: []);
    } catch (_) {
      return const Center(heightFactor: 10, child: CircularProgressIndicator());
    }

    final List<Ask> _sortedAsks =
        OrderBookProvider.sortByPrice(_asksOrderBook.bids);
    final List<Ask> _sortedBids =
        OrderBookProvider.sortByPrice(_bidsOrderBook.bids);

    return Column(
      children: <Widget>[
        FutureBuilder<List<CandleData>>(
            future: _getOHLCData(),
            builder: (
              BuildContext context,
              AsyncSnapshot<List<CandleData>> snapshot,
            ) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null) {
                return const Center(child: Text('Something went wrong...'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 12),
                  Container(
                      height: 300,
                      child: CandleChart(
                        snapshot.data,
                        candleWidth: 8,
                        strokeWidth: 1,
                        textColor: const Color.fromARGB(200, 255, 255, 255),
                        gridColor: const Color.fromARGB(50, 255, 255, 255),
                        upColor: Colors.green,
                        downColor: Colors.red,
                        filled: true,
                        allowDynamicRescale: true,
                      )),
                ],
              );
            }),
        const SizedBox(height: 12),
        Stack(
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
        ),
      ],
    );
  }

  Future<List<CandleData>> _getOHLCData() async {
    // Placeholder data api: https://docs.cryptowat.ch/rest-api/markets/ohlc
    // TODO(yurii): implement actual coins history data fetching
    http.Response _res;
    String _body;
    try {
      _res = await http
          .get('https://api.cryptowat.ch/markets/coinbase-pro/btcusd/ohlc');
      _body = _res.body;
    } catch (e) {
      print('Failed to fetch data: $e');
      rethrow;
    }

    dynamic json;
    try {
      json = jsonDecode(_body);
    } catch (e) {
      print('Failed to parse json: $e');
      rethrow;
    }

    if (json == null) return null;

    final List<CandleData> _data = [];

    for (var candle in json['result']['60']) {
      final CandleData _candleData = CandleData(
        closeTime: candle[0],
        openPrice: candle[1].toDouble(),
        highPrice: candle[2].toDouble(),
        lowPrice: candle[3].toDouble(),
        closePrice: candle[4].toDouble(),
        volume: candle[5].toDouble(),
        quoteVolume: candle[6].toDouble(),
      );
      _data.add(_candleData);
    }

    return _data;
  }
}
