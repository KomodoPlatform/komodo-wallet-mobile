import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

GetPriceService getPriceObj = GetPriceService();

///This class
class GetPriceService {
  int calc = 100000000;
  String coin = '';
  bool coinAvailable = false;
  double price = 0.0;

  Future<double> getPrice(String coin, String currency) async {
    String coinUrl =
        'https://api.coingecko.com/api/v3/simple/price?ids=';
    final String coinUrlEnd = '&vs_currencies=' + currency;
    String fiatUrl = 'https://api.coinbase.com/v2/prices/spot?currency='+currency;
    String fiatUrl2 = 'https://api.coingecko.com/api/v3/simple/price?ids=BTC&vs_currencies='+currency.toLowerCase();
    double price = 0.0;

      //fetch btc usd value
      try {
        final Response response = await http.get(fiatUrl);
        final Map<dynamic, dynamic> decoded = jsonDecode(response.body);
        price = double.parse(decoded['data']['amount']);
        if (coin == 'BTC') {
          return price;
        }
        else if (coin == 'RICK') {
        return 0;
        } else if (coin == 'MORTY') {
        return 0;
        }
      } catch (e) {
        print(e.toString());
        price = 0;
      }
      String base;
      if(coin == "VRSC") base = 'verus-coin';
      else if(coin =="KMD") base = 'komodo';
      else if(coin =="ZILLA") base = 'chainzilla';
      else if(coin =="RFOX") base = 'redfox-labs';
      else if(coin =="USDC") base = 'usd-coin';
      else if(coin =="LTC") base = 'litecoin';
      else if(coin =="DGB") base = 'digibyte';
      else if(coin =="QTUM") base = 'qtum';
      else if(coin =="BAT") base = 'basic-attention-token';
      else if(coin =="ETH") base = 'ethereum';
      else if(coin =="DOGE") base = 'dogecoin';
      else if(coin =="DASH") base = 'dash';
      else if(coin =="BCH") base = 'bitcoin-cash';
      
      coinUrl += base + coinUrlEnd;

      try {
        final Response response2 = await http.get(coinUrl);
        final Map<dynamic, dynamic> decoded2 = jsonDecode(response2.body);
        price = double.parse(decoded2[base][currency.toLowerCase()].toString());
      } catch (e) {
        print(e.toString());
        price = 0;
      }

    return price;
  }
}
