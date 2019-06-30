// To parse this JSON data, do
//
//     final balance = balanceFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/utils/utils.dart';

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

  String getBalance() {
    return replaceAllTrainlingZero(balance);
  }
}
