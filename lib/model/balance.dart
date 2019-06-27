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
        balance: double.parse(json["balance"])
            .toStringAsFixed(8),
        coin: json["coin"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "balance": balance,
        "coin": coin,
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
