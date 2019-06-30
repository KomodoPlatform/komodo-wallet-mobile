import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

final getPriceObj = GetPriceService();

///This class
class GetPriceService {
  int calc = 100000000;
  String coin = "";
  bool coinAvailable = false;
  double price = 0.0;

  Future<double> getPrice(String coin, String currency) async {
    String coinUrl =
        'https://api.bittrex.com/api/v1.1/public/getticker?market=BTC-';
    String fiatUrl = 'https://api.coinbase.com/v2/prices/spot?currency=';
    fiatUrl += currency;
    coinUrl += coin;
    double price = 0.0;

    if (coin != "RICK" && coin != "MORTY" && coin != "RFOX" && coin != "USDC" && coin != "LABS") {
      final response = await http.get(fiatUrl);
      Map decoded = jsonDecode(response.body);
      price = double.parse(decoded['data']['amount']);
      if (coin == "BTC") return price;
      final response2 = await http.get(coinUrl);
      try {
        Map decoded2 = jsonDecode(response2.body);
        price *= decoded2['result']['Last'];
      } catch (e) {
        print(e);
      }
    } else {
      if (coin == "USDT") {
        price = 1;
      } else if (coin == "RICK") {
        price = 0;
      } else if (coin == "MORTY") {
        price = 0;
      } else if (coin == "RFOX") {
        price = 0.05;
      } else if (coin == "USDC") {
        price = 1;
      } else if (coin == "LABS") {
        price = 0.01;
      }
      
    }
    return price;
  }
}
