// To parse this JSON data, do
//
//     final coinToKickStart = coinToKickStartFromJson(jsonString);

import 'dart:convert';

CoinToKickStart coinToKickStartFromJson(String str) => CoinToKickStart.fromJson(json.decode(str));

String coinToKickStartToJson(CoinToKickStart data) => json.encode(data.toJson());

class CoinToKickStart {
    List<String> result;

    CoinToKickStart({
        this.result,
    });

    factory CoinToKickStart.fromJson(Map<String, dynamic> json) => new CoinToKickStart(
        result: json["result"] == null ? null : new List<String>.from(json["result"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? null : new List<dynamic>.from(result.map((x) => x)),
    };
}
