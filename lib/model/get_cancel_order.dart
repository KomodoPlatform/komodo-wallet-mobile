// To parse this JSON data, do
//
//     final getCancelOrder = getCancelOrderFromJson(jsonString);

import 'dart:convert';

GetCancelOrder getCancelOrderFromJson(String str) =>
    GetCancelOrder.fromJson(json.decode(str));

String getCancelOrderToJson(GetCancelOrder data) => json.encode(data.toJson());

class GetCancelOrder {
  GetCancelOrder({
    this.userpass,
    this.method = 'cancel_order',
    this.uuid,
  });

  factory GetCancelOrder.fromJson(Map<String, dynamic> json) => GetCancelOrder(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        uuid: json['uuid'] ?? '',
      );

  String? userpass;
  String method;
  String? uuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'uuid': uuid ?? '',
      };
}
