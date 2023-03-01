import 'dart:convert';

import '../generic_blocs/camo_bloc.dart';
import '../utils/utils.dart';
import 'package:decimal/decimal.dart';

String balanceToJson(Balance data) => json.encode(data.toJson());

class Balance {
  Balance({
    this.address,
    this.balance,
    this.unspendableBalance,
    this.lockedBySwaps,
    this.coin,
  });

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
        address: json['address'] ?? '',
        balance: deci(json['balance']),
        unspendableBalance: deci(json['unspendable_balance']),
        lockedBySwaps: deci(json['locked_by_swaps']),
        coin: json['coin'] ?? '',
      );

  String address;
  Decimal balance;
  Decimal unspendableBalance;
  Decimal lockedBySwaps;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address ?? '',
        'balance': balance.toString() ?? double.parse('0').toStringAsFixed(8),
        'unspendable_balance':
            unspendableBalance == null ? '0' : unspendableBalance.toString(),
        'locked_by_swaps':
            lockedBySwaps.toString() ?? double.parse('0').toStringAsFixed(8),
        'coin': coin ?? '',
      };

  String getBalance() => deci2s(balance);
  String getUnspendableBalance() =>
      unspendableBalance == null ? null : deci2s(unspendableBalance);
  String getRealBalance() => deci2s(balance - lockedBySwaps);

  void camouflageIfNeeded() {
    if (!camoBloc.isCamoActive) return;
    camoBloc.camouflageBalance(this);
  }
}
