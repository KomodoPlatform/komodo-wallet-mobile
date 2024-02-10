// Using relative imports in this "package" to make it easier to track external
// dependencies when moving or copying this "package" to another project.
import 'dart:collection';

import './binance_provider.dart';
import '../models/binance_exchange_info.dart';
import '../models/binance_klines.dart';

// Declaring constants here to make this easier to copy & move around
String get binanceApiEndpoint => 'https://api.binance.com/api/v3';
const Map<String, String> defaultBinanceCandleIntervalsMap = <String, String>{
  '60': '1m',
  '180': '3m',
  '300': '5m',
  '900': '15m',
  '1800': '30m',
  '3600': '1h',
  '7200': '2h',
  '14400': '4h',
  '21600': '6h',
  '43200': '12h',
  '86400': '1d',
  '259200': '3d',
  '604800': '1w',
};

class BinanceRepository {
  BinanceRepository({BinanceProvider binanceProvider})
      : _binanceProvider =
            binanceProvider ?? BinanceProvider(apiUrl: binanceApiEndpoint);

  final BinanceProvider _binanceProvider;

  List<String> _symbols = <String>[];

  Future<List<String>> getLegacyTickers() async {
    if (_symbols.isNotEmpty) {
      return _symbols;
    }

    final BinanceExchangeInfoResponse exchangeInfo =
        await _binanceProvider.fetchExchangeInfo();
    if (exchangeInfo != null) {
      // The legacy candlestick implementation uses hyphenated lowercase
      // symbols, so we convert the symbols to that format here.
      _symbols = exchangeInfo.symbols
          .map(
            (Symbol symbol) =>
                '${symbol.baseAsset}-${symbol.quoteAsset}'.toLowerCase(),
          )
          .toList();
    }

    return _symbols;
  }

  Future<Map<String, dynamic>> getLegacyOhlcCandleData(
    String symbol, {
    List<String> ohlcDurations,
  }) async {
    final Map<String, dynamic> ohlcData = <String, dynamic>{
      ...defaultBinanceCandleIntervalsMap
    };

    // The Binance API requires the symbol to be in uppercase and without any
    // special characters, so we remove them here.
    symbol = normaliseSymbol(symbol);
    ohlcDurations ??= defaultBinanceCandleIntervalsMap.keys.toList();

    await Future.wait<void>(
      ohlcDurations.map(
        (String duration) async {
          // final int startTime = DateTime.now()
          //     .toUtc()
          //     .subtract(
          //       Duration(seconds: int.parse(duration)),
          //     )
          //     .millisecondsSinceEpoch;
          final BinanceKlinesResponse klinesResponse =
              await _binanceProvider.fetchKlines(
            symbol,
            defaultBinanceCandleIntervalsMap[duration],
            limit: 500,
            // startTime: startTime,
          );

          if (klinesResponse != null) {
            ohlcData[duration] = klinesResponse.klines
                .map((BinanceKline kline) => kline.toMap())
                .toList();
          } else {
            ohlcData[duration] = <Map<String, dynamic>>[];
          }
        },
      ),
    );

    ohlcData['604800_Monday'] = ohlcData['604800'];

    return ohlcData;
  }

  String normaliseSymbol(String symbol) {
    // The Binance API requires the symbol to be in uppercase and without any
    // special characters, so we remove them here.
    symbol = symbol.replaceAll('-', '').replaceAll('/', '').toUpperCase();
    return symbol;
  }
}
