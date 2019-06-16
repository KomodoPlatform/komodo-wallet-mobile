// To parse this JSON data, do
//
//     final getCancelOrder = getCancelOrderFromJson(jsonString);

import 'dart:convert';

GetCancelOrder getCancelOrderFromJson(String str) => GetCancelOrder.fromJson(json.decode(str));

String getCancelOrderToJson(GetCancelOrder data) => json.encode(data.toJson());

class GetCancelOrder {
    String userpass;
    String method;
    String uuid;

    GetCancelOrder({
        this.userpass,
        this.method,
        this.uuid,
    });

    factory GetCancelOrder.fromJson(Map<String, dynamic> json) => new GetCancelOrder(
        userpass: json["userpass"],
        method: json["method"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "uuid": uuid,
    };
}
