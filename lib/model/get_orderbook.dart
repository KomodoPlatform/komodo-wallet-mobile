// To parse this JSON data, do
//
//     final getOrderbook = getOrderbookFromJson(jsonString);

import 'dart:convert';

GetOrderbook getOrderbookFromJson(String str) =>
    GetOrderbook.fromJson(json.decode(str));

String getOrderbookToJson(GetOrderbook data) => json.encode(data.toJson());

class GetOrderbook {
  GetOrderbook({
    this.userpass,
    this.method = 'orderbook',
    this.base,
    this.rel,
  });

  factory GetOrderbook.fromJson(Map<String, dynamic> json) => GetOrderbook(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        base: json['base'] ?? '',
        rel: json['rel'] ?? '',
      );

  String userpass;
  String method;
  String base;
  String rel;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'base': base ?? '',
        'rel': rel ?? '',
      };
}
