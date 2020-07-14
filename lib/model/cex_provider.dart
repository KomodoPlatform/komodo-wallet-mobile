import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CexProvider extends ChangeNotifier {
  final String _baseUrl = 'http://komodo.live:3333/api/v1/ohlc';
  final Map<String, ChartData> _charts = {}; // {'BTC-USD': ChartData(),}

  bool isChartsAvailable(String pair) {
    return _findChain(pair) != null;
  }

  Future<ChartData> getCandles(String pair) async {
    if (_charts[pair] == null) {
      await _updateChart(pair);
    }

    return _charts[pair];
  }

  Future<void> _updateChart(String pair) async {
    final List<ChainLink> chain = _findChain(pair);
    if (chain == null) throw 'No chart data available';

    if (chain.length > 1) throw 'Chain is too complex';
    final ChainLink link = chain[0];

    Map<String, dynamic> json;

    if (_charts[pair] != null) {
      _charts[pair].status = ChartStatus.fetching;
    }
    try {
      json = await _fetchChartData(link);
    } catch (_) {
      if (_charts[pair] != null) {
        _charts[pair]
          ..status = ChartStatus.error
          ..updated = DateTime.now().millisecondsSinceEpoch;
      }
      rethrow;
    }

    if (json == null) return;

    final Map<String, List<CandleData>> data = {};
    json.forEach((String duration, dynamic list) {
      final List<CandleData> _durationData = [];

      for (var candle in list) {
        final CandleData _candleData = CandleData(
          closeTime: candle['timestamp'],
          openPrice: link.reverse
              ? 1 / candle['open'].toDouble()
              : candle['open'].toDouble(),
          highPrice: link.reverse
              ? 1 / candle['high'].toDouble()
              : candle['high'].toDouble(),
          lowPrice: link.reverse
              ? 1 / candle['low'].toDouble()
              : candle['low'].toDouble(),
          closePrice: link.reverse
              ? 1 / candle['close'].toDouble()
              : candle['close'].toDouble(),
          volume: link.reverse
              ? candle['quote_volume'].toDouble()
              : candle['volume'].toDouble(),
          quoteVolume: link.reverse
              ? candle['volume'].toDouble()
              : candle['quote_volume'].toDouble(),
        );
        _durationData.add(_candleData);
      }

      data[duration] = _durationData;
    });

    _charts[pair] = ChartData(
      data: data,
      pair: pair,
      chain: chain,
      status: ChartStatus.success,
      updated: DateTime.now().millisecondsSinceEpoch,
    );

    notifyListeners();
  }

  Future<Map<String, dynamic>> _fetchChartData(ChainLink link) async {
    final String pair =
        link.reverse ? '${link.base}-${link.rel}' : '${link.rel}-${link.base}';
    http.Response _res;
    String _body;
    print('Fetching $pair candles data...');
    try {
      _res = await http.get('$_baseUrl/${pair.toLowerCase()}').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Fetching $pair timed out');
          throw 'Fetching $pair timed out';
        },
      );
      _body = _res.body;
    } catch (e) {
      print('Failed to fetch data: $e');
      rethrow;
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(_body);
    } catch (e) {
      print('Failed to parse json: $e');
      rethrow;
    }

    return json;
  }

  List<ChainLink> _findChain(String pair) {
    final List<String> abbr = pair.split('-');
    final String base = abbr[1].toLowerCase();
    final String rel = abbr[0].toLowerCase();

    List<ChainLink> chain;

    // try to find simple chain, direct or reverse
    for (String available in _chartsAvailable) {
      final List<String> availableAbbr = available.split('-');
      if (rel == availableAbbr[0] && base == availableAbbr[1]) {
        chain = [ChainLink(availableAbbr[0], availableAbbr[1], false)];
        break;
      }

      if (rel == availableAbbr[1] && base == availableAbbr[0]) {
        chain = [ChainLink(availableAbbr[1], availableAbbr[0], true)];
        break;
      }
    }

    if (chain != null) return chain;
    return null;
  }
}

class ChainLink {
  ChainLink(
    this.rel,
    this.base,
    this.reverse,
  );
  String rel;
  String base;
  bool reverse;
}

class ChartData {
  ChartData({
    @required this.data,
    this.pair,
    this.chain,
    this.updated,
    this.status,
  });

  Map<String, List<CandleData>> data;
  String pair;
  List<ChainLink> chain;
  int updated; // timestamp, milliseconds
  ChartStatus status;
}

enum ChartStatus {
  success,
  error,
  fetching,
}

class CandleData {
  CandleData({
    @required this.closeTime,
    @required this.openPrice,
    @required this.highPrice,
    @required this.lowPrice,
    @required this.closePrice,
    this.volume,
    this.quoteVolume,
  });

  int closeTime;
  double openPrice;
  double highPrice;
  double lowPrice;
  double closePrice;
  double volume;
  double quoteVolume;
}

List<String> _chartsAvailable = [
  'eth-btc',
  'eth-usdc',
  'btc-usdc',
  'btc-busd',
  'btc-tusd',
  'bat-btc',
  'bat-eth',
  'bat-usdc',
  'bat-tusd',
  'bat-busd',
  'bch-btc',
  'bch-eth',
  'bch-usdc',
  'bch-tusd',
  'bch-busd',
  'dash-btc',
  'dash-eth',
  'dgb-btc',
  'doge-btc',
  'kmd-btc',
  'kmd-eth',
  'ltc-btc',
  'ltc-eth',
  'ltc-usdc',
  'ltc-tusd',
  'ltc-busd',
  'nav-btc',
  'nav-eth',
  'pax-btc',
  'pax-eth',
  'qtum-btc',
  'qtum-eth',
  'rvn-btc',
  'xzc-btc',
  'xzc-eth',
  'zec-btc',
  'zec-eth',
  'zec-usdc',
  'zec-tusd',
  'zec-busd',
];
