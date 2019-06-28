// To parse this JSON data, do
//
//     final getSwap = getSwapFromJson(jsonString);

import 'dart:convert';

GetSwap getSwapFromJson(String str) => GetSwap.fromJson(json.decode(str));

String getSwapToJson(GetSwap data) => json.encode(data.toJson());

class GetSwap {
    String method;
    Params params;
    String userpass;

    GetSwap({
        this.method,
        this.params,
        this.userpass,
    });

    factory GetSwap.fromJson(Map<String, dynamic> json) => new GetSwap(
        method: json["method"] == null ? null : json["method"],
        params: json["params"] == null ? null : Params.fromJson(json["params"]),
        userpass: json["userpass"] == null ? null : json["userpass"],
    );

    Map<String, dynamic> toJson() => {
        "method": method == null ? null : method,
        "params": params == null ? null : params.toJson(),
        "userpass": userpass == null ? null : userpass,
    };
}

class Params {
    String uuid;

    Params({
        this.uuid,
    });

    factory Params.fromJson(Map<String, dynamic> json) => new Params(
        uuid: json["uuid"] == null ? null : json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "uuid": uuid == null ? null : uuid,
    };
}
