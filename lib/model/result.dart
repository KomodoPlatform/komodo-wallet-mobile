// To parse this JSON data, do
//
//     final result = resultFromJson(jsonString);

import 'dart:convert';

ResultSuccess resultFromJson(String str) => ResultSuccess.fromJson(json.decode(str));

String resultToJson(ResultSuccess data) => json.encode(data.toJson());

class ResultSuccess {
    String result;

    ResultSuccess({
        this.result,
    });

    factory ResultSuccess.fromJson(Map<String, dynamic> json) => new ResultSuccess(
        result: json["result"],
    );

    Map<String, dynamic> toJson() => {
        "result": result,
    };
}
