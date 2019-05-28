// To parse this JSON data, do
//
//     final balance = balanceFromJson(jsonString);

import 'dart:convert';

Balance balanceFromJson(String str) {
  final jsonData = json.decode(str);
  return Balance.fromJson(jsonData);
}

String balanceToJson(Balance data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Balance {
  String address;
  String balance;
  String coin;

  Balance({
    this.address,
    this.balance,
    this.coin,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => new Balance(
        address: json["address"],
        balance: json["balance"],
        coin: json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "balance": balance,
        "coin": coin,
      };
}
