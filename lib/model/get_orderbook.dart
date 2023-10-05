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
    this.mmrpc = '2.0',
    this.base,
    this.rel,
  });

  factory GetOrderbook.fromJson(Map<String, dynamic> json) => GetOrderbook(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        mmrpc: json['mmrpc'] ?? '',
        base: json['params']['base'] ?? '',
        rel: json['params']['rel'] ?? '',
      );

  String userpass;
  String method;
  String mmrpc;
  String base;
  String rel;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'mmrpc': mmrpc,
        'params': {
          'base': base ?? '',
          'rel': rel ?? '',
        }
      };
}
