import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

GetPriceService getPriceObj = GetPriceService();

class GetPriceService {
  final double nil = 0.0;
  double price = 0.0;

  Future<double> getPrice(
      String coin, String coingeckoId, String currency) async {
    final String coinUrl =
        'https://api.coingecko.com/api/v3/simple/price?ids=' +
            coingeckoId +
            '&vs_currencies=' +
            currency.toLowerCase();
    final String fiatUrl =
        'https://api.coinbase.com/v2/prices/spot?currency=' + currency;
    price = nil;
    if (coingeckoId == 'test-token') {
      return nil;
    }
    try {
      final Response response = await http.get(fiatUrl);
      final Map<dynamic, dynamic> decoded = jsonDecode(response.body);
      price = double.parse(decoded['data']['amount'].toString());
      if (coin == 'BTC') {
        return price;
      }
    } catch (e) {
      print(e.toString());
      price = nil;
    }
    try {
      final Response response2 = await http.get(coinUrl);
      final Map<dynamic, dynamic> decoded2 = jsonDecode(response2.body);
      price = double.parse(decoded2[coingeckoId][currency.toLowerCase()]);
    } catch (e) {
      print(e.toString());
      price = nil;
    }
    return price;
  }
}
