// To parse this JSON data, do
//
//     final balance = balanceFromJson(jsonString);

import 'dart:convert';

Balance balanceFromJson(String str) => Balance.fromJson(json.decode(str));

String balanceToJson(Balance data) => json.encode(data.toJson());

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
        address: json["address"] == null ? null : json["address"],
        balance: double.parse(json["balance"]).toStringAsFixed(8) == null
            ? null
            : double.parse(json["balance"]).toStringAsFixed(8),
        coin: json["coin"] == null ? null : json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "address": address == null ? null : address,
        "balance": balance == null ? null : balance,
        "coin": coin == null ? null : coin,
      };

  String replaceAllTrainlingZero(String data) {
    for (var i = 0; i < 8; i++) {
      data = data.replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    }

    return data;
  }

  String getBalance() {
    return replaceAllTrainlingZero(balance);
  }
}
