// To parse this JSON data, do
//
//     final getOrderbook = getOrderbookFromJson(jsonString);

import 'dart:convert';

GetOrderbook getOrderbookFromJson(String str) => GetOrderbook.fromJson(json.decode(str));

String getOrderbookToJson(GetOrderbook data) => json.encode(data.toJson());

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
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        base: json["base"] == null ? null : json["base"],
        rel: json["rel"] == null ? null : json["rel"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "base": base == null ? null : base,
        "rel": rel == null ? null : rel,
    };
}
