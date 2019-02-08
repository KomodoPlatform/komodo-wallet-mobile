// To parse this JSON data, do
//
//     final getBalanceModel = getBalanceModelFromJson(jsonString);

import 'dart:convert';

GetBalance getBalanceModelFromJson(String str) {
  final jsonData = json.decode(str);
  return GetBalance.fromJson(jsonData);
}

String getBalanceModelToJson(GetBalance data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class GetBalance {
  String userpass;
  String method;
  String coin;

  GetBalance({
    this.userpass,
    this.method,
    this.coin,
  });

  factory GetBalance.fromJson(Map<String, dynamic> json) => new GetBalance(
    userpass: json["userpass"],
    method: json["method"],
    coin: json["coin"],
  );

  Map<String, dynamic> toJson() => {
    "userpass": userpass,
    "method": method,
    "coin": coin,
  };
}
