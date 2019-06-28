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
    String fromId;

    GetTxHistory({
        this.userpass,
        this.method,
        this.coin,
        this.limit,
        this.fromId,
    });

    factory GetTxHistory.fromJson(Map<String, dynamic> json) => new GetTxHistory(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        coin: json["coin"] == null ? null : json["coin"],
        limit: json["limit"] == null ? null : json["limit"],
        fromId: json["from_id"] == null ? null : json["from_id"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "coin": coin == null ? null : coin,
        "limit": limit == null ? null : limit,
        "from_id": fromId == null ? null : fromId,
    };
}
