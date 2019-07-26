// To parse this JSON data, do
//
//     final getBuy = getBuyFromJson(jsonString);

import 'dart:convert';

GetBuy getBuyFromJson(String str) => GetBuy.fromJson(json.decode(str));

String getBuyToJson(GetBuy data) => json.encode(data.toJson());

class GetBuy {
  GetBuy({
    this.userpass,
    this.method,
    this.base,
    this.rel,
    this.volume,
    this.price,
  });

  factory GetBuy.fromJson(Map<String, dynamic> json) => GetBuy(
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
