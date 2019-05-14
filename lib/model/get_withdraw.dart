// To parse this JSON data, do
//
//     final getWithdraw = getWithdrawFromJson(jsonString);

import 'dart:convert';

GetWithdraw getWithdrawFromJson(String str) {
  final jsonData = json.decode(str);
  return GetWithdraw.fromJson(jsonData);
}

String getWithdrawToJson(GetWithdraw data) {
  var tmpJson = data.toJson();
  if (data.amount == null) {
    tmpJson.remove("amount");
  }
  if (data.max == null || !data.max) {
    tmpJson.remove("max");
  }

  print(tmpJson.toString());
  return json.encode(tmpJson);
}

class GetWithdraw {
  String method;
  String coin;
  String to;
  double amount;
  String userpass;
  bool max;

  GetWithdraw(
      {this.method, this.coin, this.to, this.amount, this.userpass, this.max});

  factory GetWithdraw.fromJson(Map<String, dynamic> json) => new GetWithdraw(
      method: json["method"],
      coin: json["coin"],
      to: json["to"],
      amount:
          json["amount"].toDouble() == null ? null : json["amount"].toDouble(),
      userpass: json["userpass"],
      max: json["max"]);

  Map<String, dynamic> toJson() => {
        "method": method,
        "coin": coin,
        "to": to,
        "amount": amount == null ? null : amount,
        "userpass": userpass,
        "max": max
      };
}
