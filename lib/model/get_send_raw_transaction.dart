// To parse this JSON data, do
//
//     final getSendRawTransaction = getSendRawTransactionFromJson(jsonString);

import 'dart:convert';

GetSendRawTransaction getSendRawTransactionFromJson(String str) =>
    GetSendRawTransaction.fromJson(json.decode(str));

String getSendRawTransactionToJson(GetSendRawTransaction data) =>
    json.encode(data.toJson());

class GetSendRawTransaction {
  GetSendRawTransaction({
    this.method = 'send_raw_transaction',
    this.coin,
    this.txHex,
    this.userpass,
  });

  factory GetSendRawTransaction.fromJson(Map<String, dynamic> json) =>
      GetSendRawTransaction(
        method: json['method'] ?? '',
        coin: json['coin'] ?? '',
        txHex: json['tx_hex'] ?? '',
        userpass: json['userpass'] ?? '',
      );

  String method;
  String? coin;
  String? txHex;
  String? userpass;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        'coin': coin ?? '',
        'tx_hex': txHex ?? '',
        'userpass': userpass ?? '',
      };
}
