// To parse this JSON data, do
//
//     final activeCoin = activeCoinFromJson(jsonString);

import 'dart:convert';

ActiveCoin activeCoinFromJson(String str) =>
    ActiveCoin.fromJson(json.decode(str));

String activeCoinToJson(ActiveCoin data) => json.encode(data.toJson());

class ActiveCoin {
  ActiveCoin({
    this.coin,
    this.address,
    this.balance,
    this.result,
  });

  factory ActiveCoin.fromJson(Map<String, dynamic> json) => ActiveCoin(
      coin: json['coin'] ?? '',
      address: json['address'] ?? '',
      balance: json['balance'] ?? '',
      result: json['result'] ?? '');

  String coin;
  String address;
  String balance;
  String result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin ?? '',
        'address': address ?? '',
        'balance': balance ?? '',
        'result': result ?? ''
      };
}
