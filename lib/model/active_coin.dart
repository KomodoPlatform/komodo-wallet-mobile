// To parse this JSON data, do
//
//     final activeCoin = activeCoinFromJson(jsonString);

import 'dart:convert';

ActiveCoin activeCoinFromJson(String str) => ActiveCoin.fromJson(json.decode(str));

String activeCoinToJson(ActiveCoin data) => json.encode(data.toJson());

class ActiveCoin {
    String coin;
    String address;
    String balance;
    String result;

    ActiveCoin({
        this.coin,
        this.address,
        this.balance,
        this.result,
    });

    factory ActiveCoin.fromJson(Map<String, dynamic> json) => new ActiveCoin(
        coin: json["coin"] == null ? null : json["coin"],
        address: json["address"] == null ? null : json["address"],
        balance: json["balance"] == null ? null : json["balance"],
        result: json["result"] == null ? null : json["result"],
    );

    Map<String, dynamic> toJson() => {
        "coin": coin == null ? null : coin,
        "address": address == null ? null : address,
        "balance": balance == null ? null : balance,
        "result": result == null ? null : result,
    };
}
