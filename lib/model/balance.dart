import 'dart:convert';

import 'package:komodo_dex/utils/utils.dart';
import 'package:decimal/decimal.dart';

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
        balance: deci(json['balance']),
        lockedBySwaps: deci(json['locked_by_swaps']),
        coin: json['coin'] ?? '',
      );

  String address;
  Decimal balance;
  Decimal lockedBySwaps;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address ?? '',
        'balance': balance ?? double.parse('0').toStringAsFixed(8),
        'locked_by_swaps':
            lockedBySwaps ?? double.parse('0').toStringAsFixed(8),
        'coin': coin ?? '',
      };

  String getBalance() => deci2s(balance);
  String getRealBalance() => deci2s(balance - lockedBySwaps);
}
