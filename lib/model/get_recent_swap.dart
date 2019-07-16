// To parse this JSON data, do
//
//     final getRecentSwap = getRecentSwapFromJson(jsonString);

import 'dart:convert';

GetRecentSwap getRecentSwapFromJson(String str) => GetRecentSwap.fromJson(json.decode(str));

String getRecentSwapToJson(GetRecentSwap data) => json.encode(data.toJson());

class GetRecentSwap {
      GetRecentSwap({
        this.userpass,
        this.method,
        this.fromUuid,
        this.limit,
    });

    factory GetRecentSwap.fromJson(Map<String, dynamic> json) => GetRecentSwap(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        fromUuid: json['from_uuid'],
        limit: json['limit'] ?? 0,
    );

    String userpass;
    String method;
    String fromUuid;
    int limit;
    
    Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'from_uuid': fromUuid,
        'limit': limit ?? 0,
    };
}
