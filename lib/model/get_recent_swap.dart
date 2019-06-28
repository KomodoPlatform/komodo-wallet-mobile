// To parse this JSON data, do
//
//     final getRecentSwap = getRecentSwapFromJson(jsonString);

import 'dart:convert';

GetRecentSwap getRecentSwapFromJson(String str) => GetRecentSwap.fromJson(json.decode(str));

String getRecentSwapToJson(GetRecentSwap data) => json.encode(data.toJson());

class GetRecentSwap {
    String userpass;
    String method;
    String fromUuid;
    int limit;

    GetRecentSwap({
        this.userpass,
        this.method,
        this.fromUuid,
        this.limit,
    });

    factory GetRecentSwap.fromJson(Map<String, dynamic> json) => new GetRecentSwap(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        fromUuid: json["from_uuid"] == null ? null : json["from_uuid"],
        limit: json["limit"] == null ? null : json["limit"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "from_uuid": fromUuid == null ? null : fromUuid,
        "limit": limit == null ? null : limit,
    };
}
