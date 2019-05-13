// To parse this JSON data, do
//
//     final baseService = baseServiceFromJson(jsonString);

import 'dart:convert';

BaseService baseServiceFromJson(String str) {
  final jsonData = json.decode(str);
  return BaseService.fromJson(jsonData);
}

String baseServiceToJson(BaseService data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class BaseService {
  String userpass;
  String method;

  BaseService({
    this.userpass,
    this.method,
  });

  factory BaseService.fromJson(Map<String, dynamic> json) => new BaseService(
        userpass: json["userpass"],
        method: json["method"],
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
      };
}
