// To parse this JSON data, do
//
//     final getBalance = getBalanceFromJson(jsonString);

import 'dart:convert';

GetBalance getBalanceFromJson(String str) => GetBalance.fromJson(json.decode(str));

String getBalanceToJson(GetBalance data) => json.encode(data.toJson());

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
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        coin: json["coin"] == null ? null : json["coin"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "coin": coin == null ? null : coin,
    };
}
