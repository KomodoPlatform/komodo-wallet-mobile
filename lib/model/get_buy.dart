// To parse this JSON data, do
//
//     final getBuy = getBuyFromJson(jsonString);

import 'dart:convert';

GetBuy getBuyFromJson(String str) => GetBuy.fromJson(json.decode(str));

String getBuyToJson(GetBuy data) => json.encode(data.toJson());

class GetBuy {
    String userpass;
    String method;
    String base;
    String rel;
    String volume;
    String price;

    GetBuy({
        this.userpass,
        this.method,
        this.base,
        this.rel,
        this.volume,
        this.price,
    });

    factory GetBuy.fromJson(Map<String, dynamic> json) => new GetBuy(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        base: json["base"] == null ? null : json["base"],
        rel: json["rel"] == null ? null : json["rel"],
        volume: json["volume"] == null ? null : json["volume"],
        price: json["price"] == null ? null : json["price"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "base": base == null ? null : base,
        "rel": rel == null ? null : rel,
        "volume": volume == null ? null : volume,
        "price": price == null ? null : price,
    };
}
