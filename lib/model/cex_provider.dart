import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CexProvider extends ChangeNotifier {
  final String _baseUrl = 'http://komodo.live:3333/api/v1/ohlc';
  final Map<String, ChartData> _charts = {}; // {'BTC-USD': ChartData(),}

  Future<ChartData> getCandles(String pair) async {
    if (_charts[pair] == null) {
      await _updateChart(pair);
    }

    return _charts[pair];
  }

  Future<void> _updateChart(String pair) async {
    Map<String, dynamic> json;

    if (_charts[pair] != null) {
      _charts[pair].status = ChartStatus.fetching;
    }
    try {
      json = await _fetchChartData(pair);
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
          openPrice: candle['open'].toDouble(),
          highPrice: candle['high'].toDouble(),
          lowPrice: candle['low'].toDouble(),
          closePrice: candle['close'].toDouble(),
          volume: candle['volume'].toDouble(),
          quoteVolume: candle['quote_volume'].toDouble(),
        );
        _durationData.add(_candleData);
      }

      data[duration] = _durationData;
    });

    _charts[pair] = ChartData(
      data: data,
      pair: pair,
      status: ChartStatus.success,
      updated: DateTime.now().millisecondsSinceEpoch,
    );

    notifyListeners();
  }

  Future<Map<String, dynamic>> _fetchChartData(String pair) async {
    http.Response _res;
    String _body;
    print('Fetching $pair candles data...');
    try {
      _res = await http.get('$_baseUrl/kmd-btc').timeout(
        // TODO(yurii): change to actual pair
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
}

class ChartData {
  ChartData({
    @required this.data,
    this.pair,
    this.updated,
    this.status,
  });

  Map<String, List<CandleData>> data;
  String pair;
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
