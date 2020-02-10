import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/services/mm_service.dart';

GetPriceService getPriceObj = GetPriceService();

class GetPriceService {
  final double nil = 0.0;
  double price;

  Future<double> getPrice(
      String coin, String coingeckoId, String currency) async {
    final String coinUrl =
        'https://api.coingecko.com/api/v3/simple/price?ids=' +
            coingeckoId +
            '&vs_currencies=' +
            currency.toLowerCase();
    price = nil;
    if (coingeckoId == 'test-token') {
      return nil;
    }
    try {
      final Response response2 = await MMService().client.get(coinUrl);
      final Map<dynamic, dynamic> decoded2 = jsonDecode(response2.body);
      price = double.parse(
          decoded2[coingeckoId][currency.toLowerCase()].toString());
    } catch (e) {
      Log.println('getprice_service:31', e.toString());
      price = nil;
    }
    return price;
  }
}
