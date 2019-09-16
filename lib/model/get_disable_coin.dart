// To parse this JSON data, do
//
//     final getDisableCoin = getDisableCoinFromJson(jsonString);

import 'dart:convert';

GetDisableCoin getDisableCoinFromJson(String str) =>
    GetDisableCoin.fromJson(json.decode(str));

String getDisableCoinToJson(GetDisableCoin data) => json.encode(data.toJson());

class GetDisableCoin {
  GetDisableCoin({
    this.userpass,
    this.method = 'disable_coin',
    this.coin,
  });

  factory GetDisableCoin.fromJson(Map<String, dynamic> json) => GetDisableCoin(
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
