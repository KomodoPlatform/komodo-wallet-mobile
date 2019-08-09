// To parse this JSON data, do
//
//     final getWithdraw = getWithdrawFromJson(jsonString);

import 'dart:convert';

GetWithdraw getWithdrawFromJson(String str) =>
    GetWithdraw.fromJson(json.decode(str));

String getWithdrawToJson(GetWithdraw data) {
  final Map<String, dynamic> tmpJson = data.toJson();
  if (data.amount == null) {
    tmpJson.remove('amount');
  }
  if (data.max == null || !data.max) {
    tmpJson.remove('max');
  }
  return json.encode(tmpJson);
}

class GetWithdraw {
  GetWithdraw({
    this.method,
    this.amount,
    this.to,
    this.coin,
    this.max,
    this.userpass,
  });

  factory GetWithdraw.fromJson(Map<String, dynamic> json) => GetWithdraw(
        method: json['method'] ?? '',
        amount: json['amount'].toDouble() ?? 0.0,
        coin: json['coin'] ?? '',
        to: json['to'] ?? '',
        max: json['max'] ?? false,
        userpass: json['userpass'] ?? '',
      );

  String method;
  double amount;
  String coin;
  String to;
  bool max;
  String userpass;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        'amount': amount ?? 0.0,
        'to': to ?? '',
        'max': max ?? false,
        'coin': coin ?? '',
        'userpass': userpass ?? '',
      };
}
