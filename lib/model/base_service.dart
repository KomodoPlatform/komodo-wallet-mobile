// To parse this JSON data, do
//
//     final baseService = baseServiceFromJson(jsonString);

import 'dart:convert';

BaseService baseServiceFromJson(String str) =>
    BaseService.fromJson(json.decode(str));

String baseServiceToJson(BaseService data) => json.encode(data.toJson());

class BaseService {
  BaseService({
    this.userpass,
    this.method,
  });

  factory BaseService.fromJson(Map<String, dynamic> json) => BaseService(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
      );

  String? userpass;
  String? method;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
      };
}
