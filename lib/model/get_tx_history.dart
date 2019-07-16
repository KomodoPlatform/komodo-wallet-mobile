// To parse this JSON data, do
//
//     final getTxHistory = getTxHistoryFromJson(jsonString);

import 'dart:convert';

GetTxHistory getTxHistoryFromJson(String str) =>
    GetTxHistory.fromJson(json.decode(str));

String getTxHistoryToJson(GetTxHistory data) => json.encode(data.toJson());

class GetTxHistory {
  GetTxHistory({
    this.userpass,
    this.method,
    this.coin,
    this.limit,
    this.fromId,
  });

  factory GetTxHistory.fromJson(Map<String, dynamic> json) => GetTxHistory(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        coin: json['coin'] ?? '',
        limit: json['limit'] ?? 0,
        fromId: json['from_id'],
      );

  String userpass;
  String method;
  String coin;
  int limit;
  String fromId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
        'limit': limit ?? 0,
        'from_id': fromId,
      };
}
