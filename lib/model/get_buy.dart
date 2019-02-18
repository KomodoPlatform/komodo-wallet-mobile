// To parse this JSON data, do
//
//     final getBuy = getBuyFromJson(jsonString);

import 'dart:convert';

GetBuy getBuyFromJson(String str) {
    final jsonData = json.decode(str);
    return GetBuy.fromJson(jsonData);
}

String getBuyToJson(GetBuy data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class GetBuy {
    String userpass;
    String method;
    String base;
    String rel;
    int relvolume;
    double price;

    GetBuy({
        this.userpass,
        this.method,
        this.base,
        this.rel,
        this.relvolume,
        this.price,
    });

    factory GetBuy.fromJson(Map<String, dynamic> json) => new GetBuy(
        userpass: json["userpass"],
        method: json["method"],
        base: json["base"],
        rel: json["rel"],
        relvolume: json["relvolume"],
        price: json["price"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "base": base,
        "rel": rel,
        "relvolume": relvolume,
        "price": price,
    };
}
