// To parse this JSON data, do
//
//     final activeCoin = activeCoinFromJson(jsonString);

import 'dart:convert';

ActiveCoin activeCoinFromJson(String str) {
  final jsonData = json.decode(str);
  return ActiveCoin.fromJson(jsonData);
}

String activeCoinToJson(ActiveCoin data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class ActiveCoin {
  String address;
  double balance;
  String result;

  ActiveCoin({
    this.address,
    this.balance,
    this.result,
  });

  factory ActiveCoin.fromJson(Map<String, dynamic> json) => new ActiveCoin(
        address: json["address"],
        balance: json["balance"].toDouble(),
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "balance": balance,
        "result": result,
      };
}
