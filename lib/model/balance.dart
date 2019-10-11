// To parse this JSON data, do
//
//     final balance = balanceFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/utils/utils.dart';
import 'package:decimal/decimal.dart';

Balance balanceFromJson(String str) => Balance.fromJson(json.decode(str));

String balanceToJson(Balance data) => json.encode(data.toJson());

class Balance {
  Balance({
    this.address,
    this.balance,
    this.lockedBySwaps,
    this.coin,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
        address: json['address'] ?? '',
        balance: double.parse(json['balance']).toStringAsFixed(8) ??
            double.parse('0').toStringAsFixed(8),
        lockedBySwaps:
            double.parse(json['locked_by_swaps']).toStringAsFixed(8) ??
                double.parse('0').toStringAsFixed(8),
        coin: json['coin'] ?? '',
      );

  String address;
  String balance;
  String lockedBySwaps;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address ?? '',
        'balance': balance ?? double.parse('0').toStringAsFixed(8),
        'locked_by_swaps':
            lockedBySwaps ?? double.parse('0').toStringAsFixed(8),
        'coin': coin ?? '',
      };

  String getBalance() {
    return replaceAllTrainlingZero(balance);
  }

  String getRealBalance() {
    return replaceAllTrainlingZero(
        (Decimal.parse(balance) - Decimal.parse(lockedBySwaps)).toString());
  }
}
