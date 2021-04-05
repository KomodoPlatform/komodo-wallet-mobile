// To parse this JSON data, do
//
//     final getBalance = getBalanceFromJson(jsonString);

import 'dart:convert';

GetBalance getBalanceFromJson(String str) =>
    GetBalance.fromJson(json.decode(str));

String getBalanceToJson(GetBalance data) => json.encode(data.toJson());

class GetBalance {
  GetBalance({
    this.userpass,
    this.method = 'my_balance',
    this.coin,
  });

  factory GetBalance.fromJson(Map<String, dynamic> json) => GetBalance(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        coin: json['coin'] ?? '',
      );

  String userpass;
  String method;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
      };
}
