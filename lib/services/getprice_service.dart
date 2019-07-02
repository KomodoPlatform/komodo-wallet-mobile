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

    if (coin != "RICK" &&
        coin != "MORTY" &&
        coin != "RFOX" &&
        coin != "USDC" &&
        coin != "LABS" &&
        coin != "VRSC") {
      try {
        final response = await http.get(fiatUrl);
        Map decoded = jsonDecode(response.body);
        price = double.parse(decoded['data']['amount']);
        if (coin == "BTC") return price;
      } catch (e) {
        print(e.toString());
        price = 0;
      }
      try {
        final response2 = await http.get(coinUrl);
        Map decoded2 = jsonDecode(response2.body);
        price *= decoded2['result']['Last'];
      } catch (e) {
        print(e.toString());
        price = 0;
      }
    } else {
      if (coin == "RICK") {
        price = 0;
      } else if (coin == "MORTY") {
        price = 0;
      } else if (coin == "RFOX") {
        price = 0.05;
      } else if (coin == "USDC") {
        // String geckoUrl = "https://api.coingecko.com/api/v3/simple/price?ids=usd-coin&vs_currencies=USD";
        // final response = await http.get(geckoUrl);
        // Map decoded = jsonDecode(response.body);
        // print(decoded.toString());
        // price = double.parse(decoded['usd-coin']['usd'].toString());
        price = 1;
      } else if (coin == "LABS") {
        price = 0.01;
      } else if (coin == "VRSC") {
        try {
          String geckoUrl =
              "https://api.coingecko.com/api/v3/simple/price?ids=verus-coin&vs_currencies=USD";
          final response = await http.get(geckoUrl);
          Map decoded = jsonDecode(response.body);
          print(decoded.toString());
          price = double.parse(decoded['verus-coin']['usd'].toString());
        } catch (e) {
          print(e.toString());
          price = 0;
        }
      }
    }
    return price;
  }
}
