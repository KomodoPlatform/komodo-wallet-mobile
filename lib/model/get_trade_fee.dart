// To parse this JSON data, do
//
//     final getTradeFee = getTradeFeeFromJson(jsonString);

import 'dart:convert';

GetTradeFee getTradeFeeFromJson(String str) =>
    GetTradeFee.fromJson(json.decode(str));

String getTradeFeeToJson(GetTradeFee data) => json.encode(data.toJson());

class GetTradeFee {
  GetTradeFee({
    this.userpass,
    this.method,
    this.coin,
  });

  factory GetTradeFee.fromJson(Map<String, dynamic> json) => GetTradeFee(
        userpass: json['userpass'],
        method: json['method'],
        coin: json['coin'],
      );

  String userpass;
  String method;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass,
        'method': method,
        'coin': coin,
      };
}
