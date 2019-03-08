import 'dart:convert';
import 'dart:io';

///This class 
class GetPriceService {
  int calc = 100000000;
  String coin = "";
  bool coinAvailable = false;
  String coinUrl = 'https://api.bittrex.com/api/v1.1/public/getticker?market=BTC-';
  String fiatUrl = 'https://api.coinbase.com/v2/prices/spot?currency=';
  double price = 0.0; 

  Future<double> getPrice(String coin, String currency) async {

    fiatUrl += currency;
    coinUrl += coin;
    // create req obj with coinbase API endpoint 
    var usdRequest = await HttpClient().getUrl(Uri.parse(fiatUrl));
    var btcRequest = await HttpClient().getUrl(Uri.parse(coinUrl));

    var usdResponse = await usdRequest.close();
    var btcResponse = await btcRequest.close();
    double price = 0.0; 

    // transforms and prints the response
    await for (var contents in usdResponse.transform(Utf8Decoder())) {
      Map decoded = jsonDecode(contents);
      price=double.parse(decoded['data']['amount']);
    }
    await for (var contents in btcResponse.transform(Utf8Decoder())) {
      Map decoded = jsonDecode(contents);
      price*=decoded['result']['Last'];
    }
    return price;
  }
}
