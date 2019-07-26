// To parse this JSON data, do
//
//     final resultSuccess = resultSuccessFromJson(jsonString);

import 'dart:convert';

ResultSuccess resultSuccessFromJson(String str) =>
    ResultSuccess.fromJson(json.decode(str));

String resultSuccessToJson(ResultSuccess data) => json.encode(data.toJson());

class ResultSuccess {
  ResultSuccess({
    this.result,
  });

  factory ResultSuccess.fromJson(Map<String, dynamic> json) => ResultSuccess(
        result: json['result'] ?? '',
      );

  String result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result ?? '',
      };
}
