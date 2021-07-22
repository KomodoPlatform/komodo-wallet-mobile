import 'dart:convert';
import 'package:komodo_dex/model/market.dart';
import 'package:rational/rational.dart';

String getBestOrdersToJson(GetBestOrders data) => json.encode(data.toJson());

class GetBestOrders {
  GetBestOrders({
    this.userpass,
    this.method = 'best_orders',
    this.coin,
    this.volume,
    this.action,
  });

  String userpass;
  String method;
  String coin;
  Rational volume;
  Market action;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method,
        'userpass': userpass,
        'coin': coin,
        'volume': {
          'numer': volume.numerator.toString(),
          'denom': volume.denominator.toString(),
        },
        'action': action == Market.BUY ? 'buy' : 'sell',
      };
}
