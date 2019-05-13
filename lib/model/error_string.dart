// To parse this JSON data, do
//
//     final error = errorFromJson(jsonString);

import 'dart:convert';

ErrorString errorFromJson(String str) {
  final jsonData = json.decode(str);
  return ErrorString.fromJson(jsonData);
}

String errorToJson(ErrorString data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class ErrorString {
  String error;

  ErrorString({
    this.error,
  });

  factory ErrorString.fromJson(Map<String, dynamic> json) => new ErrorString(
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "error": error,
      };
}
