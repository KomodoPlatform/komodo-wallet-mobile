// To parse this JSON data, do
//
//     final resultSuccess = resultSuccessFromJson(jsonString);

import 'dart:convert';

ResultSuccess resultSuccessFromJson(String str) => ResultSuccess.fromJson(json.decode(str));

String resultSuccessToJson(ResultSuccess data) => json.encode(data.toJson());

class ResultSuccess {
    String result;

    ResultSuccess({
        this.result,
    });

    factory ResultSuccess.fromJson(Map<String, dynamic> json) => new ResultSuccess(
        result: json["result"] == null ? null : json["result"],
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? null : result,
    };
}
