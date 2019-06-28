// To parse this JSON data, do
//
//     final getSetPrice = getSetPriceFromJson(jsonString);

import 'dart:convert';

GetSetPrice getSetPriceFromJson(String str) =>
    GetSetPrice.fromJson(json.decode(str));

String getSetPriceToJson(GetSetPrice data) => json.encode(data.toJson());

class GetSetPrice {
  String userpass;
  String method;
  String base;
  String rel;
  bool max;
  bool cancelPrevious;
  String price;
  String volume;

  GetSetPrice({
    this.userpass,
    this.method,
    this.base,
    this.rel,
    this.max,
    this.cancelPrevious,
    this.price,
    this.volume,
  });

  factory GetSetPrice.fromJson(Map<String, dynamic> json) => new GetSetPrice(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        base: json["base"] == null ? null : json["base"],
        rel: json["rel"] == null ? null : json["rel"],
        max: json["max"] == null ? null : json["max"],
        cancelPrevious:
            json["cancel_previous"] == null ? null : json["cancel_previous"],
        price: json["price"] == null ? null : json["price"],
        volume: json["volume"] == null ? null : json["volume"],
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "base": base == null ? null : base,
        "rel": rel == null ? null : rel,
        "max": max == null ? null : max,
        "cancel_previous": cancelPrevious,
        "price": price == null ? null : price,
        "volume": volume == null ? null : price,
      };
}
