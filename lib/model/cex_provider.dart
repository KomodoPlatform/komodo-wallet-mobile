import 'package:flutter/material.dart';
import 'package:komodo_dex/model/order_book_provider.dart';

class CexProvider extends ChangeNotifier {
  Future<ChartData> getCandles(CoinsPair pair, int durationSeconds) async {}
}

class ChartData {
  ChartData({
    @required this.data,
    @required this.duration,
    this.pair,
    this.updated,
  });

  List<CandleData> data;
  int duration; // seconds
  CoinsPair pair;
  int updated; // timestamp, milliseconds
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
