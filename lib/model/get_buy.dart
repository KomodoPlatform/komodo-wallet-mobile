// To parse this JSON data, do
//
//     final getBuy = getBuyFromJson(jsonString);

import 'dart:convert';

GetBuySell getBuyFromJson(String str) => GetBuySell.fromJson(json.decode(str));

String getBuyToJson(GetBuySell data) => json.encode(data.toJson());

class GetBuySell {
  GetBuySell({
    this.userpass,
    this.method = 'buy',
    this.base,
    this.rel,
    this.volume,
    this.price,
  });

  factory GetBuySell.fromJson(Map<String, dynamic> json) => GetBuySell(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        base: json['base'] ?? '',
        rel: json['rel'] ?? '',
        volume: json['volume'] ?? '',
        price: json['price'] ?? '',
      );

  String userpass;
  String method;
  String base;
  String rel;
  String volume;
  String price;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'base': base ?? '',
        'rel': rel ?? '',
        'volume': volume ?? '',
        'price': price ?? '',
      };
}
