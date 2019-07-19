// To parse this JSON data, do
//
//     final getSwap = getSwapFromJson(jsonString);

import 'dart:convert';

GetSwap getSwapFromJson(String str) => GetSwap.fromJson(json.decode(str));

String getSwapToJson(GetSwap data) => json.encode(data.toJson());

class GetSwap {
  GetSwap({
    this.method,
    this.params,
    this.userpass,
  });

  factory GetSwap.fromJson(Map<String, dynamic> json) => GetSwap(
        method: json['method'] ?? '',
        params: Params.fromJson(json['params']) ?? Params(),
        userpass: json['userpass'] ?? '',
      );

  String method;
  Params params;
  String userpass;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        'params': params ?? '',
        'userpass': userpass ?? '',
      };
}

class Params {
  Params({
    this.uuid,
  });

  factory Params.fromJson(Map<String, dynamic> json) => Params(
        uuid: json['uuid'] ?? '',
      );

  String uuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uuid': uuid ?? '',
      };
}
