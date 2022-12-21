// To parse this JSON data, do
//
//     final ErrorString = errorStringFromJson(jsonString);

import 'dart:convert';
import '../utils/log.dart';

Future<ErrorString> errorStringFromJson(String str) async =>
    removeLineFromMM2(ErrorString.fromJson(json.decode(str)));

String errorStringToJson(ErrorString data) => json.encode(data.toJson());

ErrorString removeLineFromMM2(ErrorString errorString) {
  Log.println('error_string:14', errorString.error);
  if (errorString.error.lastIndexOf(']') != -1) {
    errorString.error = errorString.error
        .substring(errorString.error.lastIndexOf(']') + 1)
        .trim();
  }
  return errorString;
}

class ErrorString implements Exception {
  ErrorString(this.error);

  /// Extracts the "error" field.
  /// Uses an empty error string if the field is absent.
  factory ErrorString.fromJson(Map<String, dynamic> json) =>
      ErrorString(json['error'] ?? '');

  String error;

  @override
  String toString() => error;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'error': error ?? '',
      };
}
