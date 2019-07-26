// To parse this JSON data, do
//
//     final ErrorString = errorStringFromJson(jsonString);

import 'dart:convert';

ErrorString errorStringFromJson(String str) =>
    ErrorString.fromJson(json.decode(str));

String errorStringToJson(ErrorString data) => json.encode(data.toJson());

class ErrorString {
  ErrorString({
    this.error,
  });

  factory ErrorString.fromJson(Map<String, dynamic> json) => ErrorString(
        error: json['error'] ?? '',
      );
  String error;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'error': error ?? '',
      };
}
