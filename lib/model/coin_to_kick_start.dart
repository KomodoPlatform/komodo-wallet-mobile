// To parse this JSON data, do
//
//     final coinToKickStart = coinToKickStartFromJson(jsonString);

import 'dart:convert';

CoinToKickStart coinToKickStartFromJson(String str) =>
    CoinToKickStart.fromJson(json.decode(str));

String coinToKickStartToJson(CoinToKickStart data) =>
    json.encode(data.toJson());

class CoinToKickStart {
  CoinToKickStart({
    this.result,
  });

  factory CoinToKickStart.fromJson(Map<String, dynamic> json) =>
      CoinToKickStart(
          result: List<String>.from(json['result'].map((dynamic x) => x)) ??
              <String>[]);

  List<String> result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': List<dynamic>.from(result.map<dynamic>((dynamic x) => x)) ??
            <String>[]
      };
}
