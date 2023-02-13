// To parse this JSON data, do
//
//     final recoverFundsOfSwap = recoverFundsOfSwapFromJson(jsonString);

import 'dart:convert';

RecoverFundsOfSwap recoverFundsOfSwapFromJson(String str) =>
    RecoverFundsOfSwap.fromJson(json.decode(str));

String recoverFundsOfSwapToJson(RecoverFundsOfSwap data) =>
    json.encode(data.toJson());

class RecoverFundsOfSwap {
  RecoverFundsOfSwap({
    this.result,
  });

  factory RecoverFundsOfSwap.fromJson(Map<String, dynamic> json) =>
      RecoverFundsOfSwap(
        result: Result.fromJson(json['result']),
      );

  Result? result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result!.toJson(),
      };
}

class Result {
  Result({
    this.action,
    this.coin,
    this.txHash,
    this.txHex,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        action: json['action'],
        coin: json['coin'],
        txHash: json['tx_hash'],
        txHex: json['tx_hex'],
      );

  String? action;
  String? coin;
  String? txHash;
  String? txHex;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'action': action,
        'coin': coin,
        'tx_hash': txHash,
        'tx_hex': txHex,
      };
}
