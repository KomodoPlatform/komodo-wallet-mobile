// To parse this JSON data, do
//
//     final getTxHistory = getTxHistoryFromJson(jsonString);

import 'dart:convert';

GetTxHistory getTxHistoryFromJson(String str) => GetTxHistory.fromJson(json.decode(str));

String getTxHistoryToJson(GetTxHistory data) => json.encode(data.toJson());

class GetTxHistory {
    String userpass;
    String method;
    String coin;
    int limit;
    String fromTxHash;

    GetTxHistory({
        this.userpass,
        this.method,
        this.coin,
        this.limit,
        this.fromTxHash,
    });

    factory GetTxHistory.fromJson(Map<String, dynamic> json) => new GetTxHistory(
        userpass: json["userpass"],
        method: json["method"],
        coin: json["coin"],
        limit: json["limit"],
        fromTxHash: json["from_tx_hash"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "coin": coin,
        "limit": limit,
        "from_tx_hash": fromTxHash,
    };
}
