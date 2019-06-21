// To parse this JSON data, do
//
//     final errorCode = errorCodeFromJson(jsonString);

import 'dart:convert';

ErrorCode errorCodeFromJson(String str) => ErrorCode.fromJson(json.decode(str));

String errorCodeToJson(ErrorCode data) => json.encode(data.toJson());

class ErrorCode {
    Error error;

    ErrorCode({
        this.error,
    });

    factory ErrorCode.fromJson(Map<String, dynamic> json) => new ErrorCode(
        error: Error.fromJson(json["error"]),
    );

    Map<String, dynamic> toJson() => {
        "error": error.toJson(),
    };
}

class Error {
    int code;
    String message;

    Error({
        this.code,
        this.message,
    });

    factory Error.fromJson(Map<String, dynamic> json) => new Error(
        code: json["code"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
    };
}
