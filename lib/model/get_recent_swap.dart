// To parse this JSON data, do
//
//     final getRecentSwap = getRecentSwapFromJson(jsonString);

import 'dart:convert';

GetRecentSwap getRecentSwapFromJson(String str) =>
    GetRecentSwap.fromJson(json.decode(str));

String getRecentSwapToJson(GetRecentSwap data) => json.encode(data.toJson());

class GetRecentSwap {
  String userpass;
  String method;
  int limit;
  String fromUuid;

  GetRecentSwap({
    this.userpass,
    this.method,
    this.limit,
    this.fromUuid,
  });

  factory GetRecentSwap.fromJson(Map<String, dynamic> json) => new GetRecentSwap(
        userpass: json["userpass"],
        method: json["method"],
        limit: json["limit"],
        fromUuid: json["from_uuid"],
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "limit": limit,
        "from_uuid": fromUuid,
      };
}
