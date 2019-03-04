// To parse this JSON data, do
//
//     final getWithdraw = getWithdrawFromJson(jsonString);

import 'dart:convert';

GetWithdraw getWithdrawFromJson(String str) {
  final jsonData = json.decode(str);
  return GetWithdraw.fromJson(jsonData);
}

String getWithdrawToJson(GetWithdraw data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class GetWithdraw {
  String method;
  String coin;
  String to;
  double amount;
  String userpass;

  GetWithdraw({
    this.method,
    this.coin,
    this.to,
    this.amount,
    this.userpass,
  });

  factory GetWithdraw.fromJson(Map<String, dynamic> json) => new GetWithdraw(
        method: json["method"],
        coin: json["coin"],
        to: json["to"],
        amount: json["amount"].toDouble(),
        userpass: json["userpass"],
      );

  Map<String, dynamic> toJson() => {
        "method": method,
        "coin": coin,
        "to": to,
        "amount": amount,
        "userpass": userpass,
      };
}
