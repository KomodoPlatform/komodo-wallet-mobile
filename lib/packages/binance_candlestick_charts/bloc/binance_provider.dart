import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_dex/utils/log.dart';

import '../models/binance_exchange_info.dart';
import '../models/binance_klines.dart';

class BinanceProvider {
  BinanceProvider({this.apiUrl});

  final String apiUrl;

  Future<BinanceKlinesResponse> fetchKlines(
    String symbol,
    String interval, {
    int startTime,
    int endTime,
    int limit,
  }) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      if (startTime != null) 'startTime': startTime.toString(),
      if (endTime != null) 'endTime': endTime.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final Uri uri =
        Uri.parse('$apiUrl/klines').replace(queryParameters: queryParameters);

    final http.Response response = await http.get(uri);
    if (response.statusCode == 200) {
      return BinanceKlinesResponse.fromJson(
        jsonDecode(response.body) as List<dynamic>,
      );
    } else {
      throw Exception(
        'Failed to load klines: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<BinanceExchangeInfoResponse> fetchExchangeInfo() async {
    final http.Response response = await http.get(
      Uri.parse('$apiUrl/exchangeInfo'),
    );

    if (response.statusCode == 200) {
      return BinanceExchangeInfoResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('Failed to load symbols');
    }
  }
}
