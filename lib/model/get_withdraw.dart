// To parse this JSON data, do
//
//     final getWithdraw = getWithdrawFromJson(jsonString);

import 'dart:convert';

GetWithdraw getWithdrawFromJson(String str) => GetWithdraw.fromJson(json.decode(str));

String getWithdrawToJson(GetWithdraw data) {
  var tmpJson = data.toJson();
  if (data.amount == null) {
    tmpJson.remove("amount");
  }
  if (data.max == null || !data.max) {
    tmpJson.remove("max");
  }
  return json.encode(tmpJson);
}
class GetWithdraw {
    String method;
    double amount;
      String coin;

    String to;
    bool max;
    String userpass;

    GetWithdraw({
        this.method,
        this.amount,
        this.to,
        this.coin,
        this.max,
        this.userpass,
    });

    factory GetWithdraw.fromJson(Map<String, dynamic> json) => new GetWithdraw(
        method: json["method"] == null ? null : json["method"],
       amount:
          json["amount"].toDouble() == null ? null : json["amount"].toDouble(),
        coin: json["coin"] == null ? null : json["coin"],
        to: json["to"] == null ? null : json["to"],
        max: json["max"] == null ? null : json["max"],
        userpass: json["userpass"] == null ? null : json["userpass"],
    );

    Map<String, dynamic> toJson() => {
        "method": method == null ? null : method,
        "amount": amount == null ? null : amount,
        "to": to == null ? null : to,
        "max": max == null ? null : max,
        "coin": coin == null ? null : max,
        "userpass": userpass == null ? null : userpass,
    };
}
