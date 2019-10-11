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
    this.lockedBySwaps,
    this.result,
  });

  factory ActiveCoin.fromJson(Map<String, dynamic> json) => ActiveCoin(
      coin: json['coin'] ?? '',
      address: json['address'] ?? '',
      balance: json['balance'] ?? '',
      lockedBySwaps: json['locked_by_swaps'] ?? '',
      result: json['result'] ?? '');

  String coin;
  String address;
  String balance;
  String lockedBySwaps;
  String result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin ?? '',
        'address': address ?? '',
        'balance': balance ?? '',
        'locked_by_swaps': lockedBySwaps ?? '',
        'result': result ?? ''
      };
}
