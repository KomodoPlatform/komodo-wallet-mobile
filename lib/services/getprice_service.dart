import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

GetPriceService getPriceObj = GetPriceService();

class GetPriceService {
  int calc = 100000000;
  String coin = '';
  bool coinAvailable = false;
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
    double price = 0.0;
    if (coingeckoId == 'test-token') {
      return 0;
    }
    try {
      final Response response = await http.get(fiatUrl);
      final Map<dynamic, dynamic> decoded = jsonDecode(response.body);
      price = double.parse(decoded['data']['amount']);
      if (coin == 'BTC') {
        return price;
      }
    } catch (e) {
      print(e.toString());
      price = 0;
    }
    try {
      final Response response2 = await http.get(coinUrl);
      final Map<dynamic, dynamic> decoded2 = jsonDecode(response2.body);
      price = double.parse(
          decoded2[coingeckoId][currency.toLowerCase()].toString());
    } catch (e) {
      print(e.toString());
      price = 0;
    }
    return price;
  }
}
