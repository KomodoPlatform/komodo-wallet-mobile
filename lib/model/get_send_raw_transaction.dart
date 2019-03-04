// To parse this JSON data, do
//
//     final getSendRawTransaction = getSendRawTransactionFromJson(jsonString);

import 'dart:convert';

GetSendRawTransaction getSendRawTransactionFromJson(String str) {
  final jsonData = json.decode(str);
  return GetSendRawTransaction.fromJson(jsonData);
}

String getSendRawTransactionToJson(GetSendRawTransaction data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class GetSendRawTransaction {
  String method;
  String coin;
  String txHex;
  String userpass;

  GetSendRawTransaction({
    this.method,
    this.coin,
    this.txHex,
    this.userpass,
  });

  factory GetSendRawTransaction.fromJson(Map<String, dynamic> json) =>
      new GetSendRawTransaction(
        method: json["method"],
        coin: json["coin"],
        txHex: json["tx_hex"],
        userpass: json["userpass"],
      );

  Map<String, dynamic> toJson() => {
        "method": method,
        "coin": coin,
        "tx_hex": txHex,
        "userpass": userpass,
      };
}
