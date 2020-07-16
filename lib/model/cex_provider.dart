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

  bool _updatingChart = false;

  Future<void> _updateChart(String pair) async {
    if (_updatingChart) return;

    final List<ChainLink> chain = _findChain(pair);
    if (chain == null) throw 'No chart data available';

    Map<String, dynamic> json0;
    Map<String, dynamic> json1;

    _updatingChart = true;
    if (_charts[pair] != null) {
      _charts[pair].status = ChartStatus.fetching;
    }
    try {
      json0 = await _fetchChartData(chain[0]);
      if (chain.length > 1) {
        json1 = await _fetchChartData(chain[1]);
      }
    } catch (_) {
      _updatingChart = false;
      if (_charts[pair] != null) {
        _charts[pair]
          ..status = ChartStatus.error
          ..updated = DateTime.now().millisecondsSinceEpoch;
      }
      rethrow;
    }

    _updatingChart = false;

    if (json0 == null) return;
    if (chain.length > 1 && json1 == null) return;

    final Map<String, List<CandleData>> data = {};
    json0.forEach((String duration, dynamic list) {
      final List<CandleData> _durationData = [];

      for (var candle in list) {
        double open = chain[0].reverse
            ? 1 / candle['open'].toDouble()
            : candle['open'].toDouble();
        double high = chain[0].reverse
            ? 1 / candle['high'].toDouble()
            : candle['high'].toDouble();
        double low = chain[0].reverse
            ? 1 / candle['low'].toDouble()
            : candle['low'].toDouble();
        double close = chain[0].reverse
            ? 1 / candle['close'].toDouble()
            : candle['close'].toDouble();
        double volume = chain[0].reverse
            ? candle['quote_volume'].toDouble()
            : candle['volume'].toDouble();
        double quoteVolume = chain[0].reverse
            ? candle['volume'].toDouble()
            : candle['quote_volume'].toDouble();
        final int timestamp = candle['timestamp'];

        if (chain.length > 1) {
          dynamic secondCandle;
          try {
            secondCandle =
                json1[duration].toList().firstWhere((dynamic candle) {
              return candle['timestamp'] == timestamp;
            });
          } catch (_) {}

          if (secondCandle == null) continue;

          final double secondOpen = chain[1].reverse
              ? 1 / secondCandle['open'].toDouble()
              : secondCandle['open'].toDouble();
          final double secondHigh = chain[1].reverse
              ? 1 / secondCandle['high'].toDouble()
              : secondCandle['high'].toDouble();
          final double secondLow = chain[1].reverse
              ? 1 / secondCandle['low'].toDouble()
              : secondCandle['low'].toDouble();
          final double secondClose = chain[1].reverse
              ? 1 / secondCandle['close'].toDouble()
              : secondCandle['close'].toDouble();

          final bool reversed =
              chain[0].base == pair.split('-')[1].toLowerCase() ||
                  chain[0].rel == pair.split('-')[1].toLowerCase();

          open = reversed ? 1 / (open * secondOpen) : open * secondOpen;
          close = reversed ? 1 / (close * secondClose) : close * secondClose;
          high = reversed ? 1 / (high * secondHigh) : high * secondHigh;
          low = reversed ? 1 / (low * secondLow) : low * secondLow;
          volume = null;
          quoteVolume = null;
        }

        final CandleData _candleData = CandleData(
          closeTime: timestamp,
          openPrice: open,
          highPrice: high,
          lowPrice: low,
          closePrice: close,
          volume: volume,
          quoteVolume: quoteVolume,
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
    final String pair = '${link.rel}-${link.base}';
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
      if (!(availableAbbr.contains(rel) && availableAbbr.contains(base))) {
        continue;
      }

      chain = [
        ChainLink(
          rel: availableAbbr[0],
          base: availableAbbr[1],
          reverse: availableAbbr[0] != rel,
        )
      ];
    }

    if (chain != null) return chain;

    _chartsAvailable.sort((String a, String b) {
      if (a.toLowerCase().contains('btc') && !b.toLowerCase().contains('btc'))
        return -1;
      if (b.toLowerCase().contains('btc') && !a.toLowerCase().contains('btc'))
        return 1;
      return 0;
    });

    OUTER:
    for (String firstLinkStr in _chartsAvailable) {
      final List<String> firstLinkCoins = firstLinkStr.split('-');
      if (!firstLinkCoins.contains(rel) && !firstLinkCoins.contains(base)) {
        continue;
      }
      final ChainLink firstLink = ChainLink(
        rel: firstLinkCoins[0],
        base: firstLinkCoins[1],
        reverse: firstLinkCoins[1] == rel || firstLinkCoins[1] == base,
      );
      final String secondRel =
          firstLink.reverse ? firstLink.rel : firstLink.base;
      final String secondBase = firstLinkCoins.contains(rel) ? base : rel;

      for (String secondLink in _chartsAvailable) {
        final List<String> secondLinkCoins = secondLink.split('-');
        if (!(secondLinkCoins.contains(secondRel) &&
            secondLinkCoins.contains(secondBase))) {
          continue;
        }

        chain = [
          firstLink,
          ChainLink(
            rel: secondLinkCoins[0],
            base: secondLinkCoins[1],
            reverse: secondLinkCoins[0] == secondBase ||
                secondLinkCoins[1] == secondRel,
          ),
        ];
        break OUTER;
      }
    }

    if (chain != null) return chain;

    return null;
  }
}

class ChainLink {
  ChainLink({
    this.rel,
    this.base,
    this.reverse,
  });
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
