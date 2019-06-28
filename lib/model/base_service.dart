// To parse this JSON data, do
//
//     final baseService = baseServiceFromJson(jsonString);

import 'dart:convert';

BaseService baseServiceFromJson(String str) => BaseService.fromJson(json.decode(str));

String baseServiceToJson(BaseService data) => json.encode(data.toJson());

class BaseService {
    String userpass;
    String method;

    BaseService({
        this.userpass,
        this.method,
    });

    factory BaseService.fromJson(Map<String, dynamic> json) => new BaseService(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
    };
}
