// To parse this JSON data, do
//
//     final getWithdraw = getWithdrawFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/blocs/camo_bloc.dart';

GetWithdraw getWithdrawFromJson(String str) =>
    GetWithdraw.fromJson(json.decode(str));

String getWithdrawToJson(GetWithdraw data) {
  final Map<String, dynamic> tmpJson = data.toJson();
  if (data.amount == null) {
    tmpJson.remove('amount');
  }
  if (data.max == null || !data.max || camoBloc.isCamoActive) {
    tmpJson.remove('max');
  }
  if (data.fee == null || data.fee.type == null) {
    tmpJson.remove('fee');
  }
  return json.encode(tmpJson);
}

class GetWithdraw {
  GetWithdraw({
    this.method = 'withdraw',
    this.amount,
    this.to,
    this.coin,
    this.max,
    this.userpass,
    this.fee,
  });

  factory GetWithdraw.fromJson(Map<String, dynamic> json) => GetWithdraw(
        method: json['method'] ?? '',
        amount: json['amount'] ?? '',
        coin: json['coin'] ?? '',
        to: json['to'] ?? '',
        max: json['max'] ?? false,
        userpass: json['userpass'] ?? '',
        fee: Fee.fromJson(json['fee']) ?? Fee(),
      );

  String method;
  String amount;
  String coin;
  String to;
  bool max;
  String userpass;
  Fee fee;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        'amount': amount ?? '',
        'to': to ?? '',
        'max': max ?? false,
        'coin': coin ?? '',
        'userpass': userpass ?? '',
        'fee': fee != null ? fee.toJson() : '',
      };
}

class Fee {
  Fee({
    this.type,
    this.amount,
    this.gasPrice,
    this.gas,
  });
  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        type: json['type'],
        amount: json['amount'],
        gasPrice: json['gas_price'],
        gas: json['gas'],
      );
  String
      type; // type of transaction fee, possible values: UtxoFixed, UtxoPerKbyte, EthGas
  String
      amount; // fee amount in coin units, used only when type is UtxoFixed (fixed amount not depending on tx size) or UtxoPerKbyte (amount per Kbyte).
  String
      gasPrice; // used only when fee type is EthGas. Sets the gas price in `gwei` units
  int gas; // used only when fee type is EthGas. Sets the gas limit for transaction

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'amount': amount,
        'gas_price': gasPrice,
        'gas': gas,
      };
}
