// To parse this JSON data, do
//
//     final ErrorString = errorStringFromJson(jsonString);

import 'dart:convert';

ErrorString errorStringFromJson(String str) => ErrorString.fromJson(json.decode(str));

String errorStringToJson(ErrorString data) => json.encode(data.toJson());

class ErrorString {
    String error;

    ErrorString({
        this.error,
    });

    factory ErrorString.fromJson(Map<String, dynamic> json) => new ErrorString(
        error: json["error"] == null ? null : json["error"],
    );

    Map<String, dynamic> toJson() => {
        "error": error == null ? null : error,
    };
}
