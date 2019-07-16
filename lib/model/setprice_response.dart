// To parse this JSON data, do
//
//     final setPriceResponse = setPriceResponseFromJson(jsonString);

import 'dart:convert';
import 'package:komodo_dex/model/orders.dart';

SetPriceResponse setPriceResponseFromJson(String str) =>
    SetPriceResponse.fromJson(json.decode(str));

String setPriceResponseToJson(SetPriceResponse data) =>
    json.encode(data.toJson());

class SetPriceResponse {
  SetPriceResponse({
    this.result,
  });

  factory SetPriceResponse.fromJson(Map<String, dynamic> json) =>
      SetPriceResponse(
        result: json['result'] ?? Result(),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result ?? Result(),
      };
}

class Result {
  Result({
    this.base,
    this.rel,
    this.maxBaseVol,
    this.minBaseVol,
    this.createdAt,
    this.matches,
    this.price,
    this.startedSwaps,
    this.uuid,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        base: json['base'] ?? '',
        rel: json['rel'] ?? '',
        maxBaseVol: json['max_base_vol'] ?? '',
        minBaseVol: json['min_base_vol'] ?? '',
        createdAt: json['created_at'] ?? 0,
        matches: json['matches'] ?? <String, Match>{},
        price: json['price'] ?? '',
        startedSwaps: json['started_swaps'] ?? <String>[],
        uuid: json['uuid'] ?? '',
      );

  String base;
  String rel;
  String maxBaseVol;
  String minBaseVol;
  int createdAt;
  Map<String, Match> matches;
  String price;
  List<String> startedSwaps;
  String uuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'base': base ?? '',
        'rel': rel ?? '',
        'max_base_vol': maxBaseVol ?? '',
        'min_base_vol': minBaseVol ?? '',
        'created_at': createdAt ?? 0,
        'matches': matches ?? <String, Match>{},
        'price': price ?? '',
        'started_swaps': startedSwaps ?? <String>[],
        'uuid': uuid ?? '',
      };
}
