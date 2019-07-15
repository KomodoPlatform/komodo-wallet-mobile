// To parse this JSON data, do
//
//     final coinToKickStart = coinToKickStartFromJson(jsonString);

import 'dart:convert';

CoinToKickStart coinToKickStartFromJson(String str) => CoinToKickStart.fromJson(json.decode(str));

String coinToKickStartToJson(CoinToKickStart data) => json.encode(data.toJson());

class CoinToKickStart {
      CoinToKickStart({
        this.result,
    });

    factory CoinToKickStart.fromJson(Map<String, dynamic> json) => CoinToKickStart(
        result: json['result'] ?? <String>[]
    );

    List<String> result;

    Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result ?? <String>[]
    };
}
