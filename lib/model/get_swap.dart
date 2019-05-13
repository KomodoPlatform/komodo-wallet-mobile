// To parse this JSON data, do
//
//     final getSwap = getSwapFromJson(jsonString);

import 'dart:convert';

GetSwap getSwapFromJson(String str) {
  final jsonData = json.decode(str);
  return GetSwap.fromJson(jsonData);
}

String getSwapToJson(GetSwap data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class GetSwap {
  String userpass;
  String method;
  Params params;

  GetSwap({
    this.userpass,
    this.method,
    this.params,
  });

  factory GetSwap.fromJson(Map<String, dynamic> json) => new GetSwap(
        userpass: json["userpass"],
        method: json["method"],
        params: Params.fromJson(json["params"]),
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "params": params.toJson(),
      };
}

class Params {
  String uuid;

  Params({
    this.uuid,
  });

  factory Params.fromJson(Map<String, dynamic> json) => new Params(
        uuid: json["uuid"],
      );

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
      };
}
