// To parse this JSON data, do
//
//     final setPriceResponse = setPriceResponseFromJson(jsonString);

import 'dart:convert';
import '../model/orders.dart';

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
        result: Result.fromJson(json['result']) ?? Result(),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson() ?? Result().toJson(),
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
        matches: Map<String, Match>.from(json['matches']).map<String, Match>(
                (dynamic k, dynamic v) =>
                    MapEntry<String, Match>(k, Match.fromJson(v))) ??
            <String, Match>{},
        price: json['price'] ?? '',
        startedSwaps: List<String>.from(
                json['started_swaps'].map<dynamic>((dynamic x) => x)) ??
            <String>[],
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
        'matches': Map<dynamic, dynamic>.from(matches).map<dynamic, dynamic>(
                (dynamic k, dynamic v) =>
                    MapEntry<String, dynamic>(k, v.toJson())) ??
            <String, Match>{},
        'price': price ?? '',
        'started_swaps':
            List<dynamic>.from(startedSwaps.map<dynamic>((dynamic x) => x)) ??
                <String>[],
        'uuid': uuid ?? '',
      };
}
