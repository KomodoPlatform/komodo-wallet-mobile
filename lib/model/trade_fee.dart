// To parse this JSON data, do
//
//     final tradeFee = tradeFeeFromJson(jsonString);

import 'dart:convert';

TradeFee tradeFeeFromJson(String str) => TradeFee.fromJson(json.decode(str));

String tradeFeeToJson(TradeFee data) => json.encode(data.toJson());

class TradeFee {
  TradeFee({
    this.result,
  });

  factory TradeFee.fromJson(Map<String, dynamic> json) => TradeFee(
        result: Result.fromJson(json['result']),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson(),
      };
}

class Result {
  Result({
    this.amount,
    this.coin,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        amount: json['amount'],
        coin: json['coin'],
      );

  String amount;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount': amount,
        'coin': coin,
      };
}
