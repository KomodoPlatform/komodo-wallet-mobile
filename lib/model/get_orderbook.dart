// To parse this JSON data, do
//
//     final getOrderbook = getOrderbookFromJson(jsonString);

import 'dart:convert';

GetOrderbook getOrderbookFromJson(String str) {
  final jsonData = json.decode(str);
  return GetOrderbook.fromJson(jsonData);
}

String getOrderbookToJson(GetOrderbook data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class GetOrderbook {
  String userpass;
  String method;
  String base;
  String rel;

  GetOrderbook({
    this.userpass,
    this.method,
    this.base,
    this.rel,
  });

  factory GetOrderbook.fromJson(Map<String, dynamic> json) => new GetOrderbook(
        userpass: json["userpass"],
        method: json["method"],
        base: json["base"],
        rel: json["rel"],
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "base": base,
        "rel": rel,
      };
}
