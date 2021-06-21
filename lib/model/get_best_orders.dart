import 'dart:convert';
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
  MarketAction action;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method,
        'userpass': userpass,
      };
}

enum MarketAction {
  SELL,
  BUY,
}
