// To parse this JSON data, do
//
//     final errorCode = errorCodeFromJson(jsonString);

import 'dart:convert';

ErrorCode errorCodeFromJson(String str) => ErrorCode.fromJson(json.decode(str));

String errorCodeToJson(ErrorCode data) => json.encode(data.toJson());

class ErrorCode {
  ErrorCode({
    this.error,
  });

  factory ErrorCode.fromJson(Map<String, dynamic> json) => ErrorCode(
        error: Error.fromJson(json['error']) ?? Error(),
      );

  Error error;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'error': error.toJson() ?? '',
      };
}

class Error {
  Error({
    this.code = 0,
    this.message = '',
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        code: json['code'] ?? 0,
        message: json['message'] ?? '',
      );

  int code;
  String message;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code ?? 0,
        'message': message ?? '',
      };
}
