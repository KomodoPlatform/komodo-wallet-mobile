// To parse this JSON data, do
//
//     final setPriceResponse = setPriceResponseFromJson(jsonString);

import 'dart:convert';
import 'package:komodo_dex/model/orders.dart';

SetPriceResponse setPriceResponseFromJson(String str) => SetPriceResponse.fromJson(json.decode(str));

String setPriceResponseToJson(SetPriceResponse data) => json.encode(data.toJson());

class SetPriceResponse {
    Result result;

    SetPriceResponse({
        this.result,
    });

    factory SetPriceResponse.fromJson(Map<String, dynamic> json) => new SetPriceResponse(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? null : result.toJson(),
    };
}

class Result {
    String base;
    String rel;
    String maxBaseVol;
    String minBaseVol;
    int createdAt;
    Map<String, Match> matches;
    String price;
    List<String> startedSwaps;
    String uuid;

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

    factory Result.fromJson(Map<String, dynamic> json) => new Result(
        base: json["base"] == null ? null : json["base"],
        rel: json["rel"] == null ? null : json["rel"],
        maxBaseVol: json["max_base_vol"] == null ? null : json["max_base_vol"],
        minBaseVol: json["min_base_vol"] == null ? null : json["min_base_vol"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        matches: json["matches"] == null ? null : new Map.from(json["matches"]).map((k, v) => new MapEntry<String, Match>(k, Match.fromJson(v))),
        price: json["price"] == null ? null : json["price"],
        startedSwaps: json["started_swaps"] == null ? null : new List<String>.from(json["started_swaps"].map((x) => x)),
        uuid: json["uuid"] == null ? null : json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "base": base == null ? null : base,
        "rel": rel == null ? null : rel,
        "max_base_vol": maxBaseVol == null ? null : maxBaseVol,
        "min_base_vol": minBaseVol == null ? null : minBaseVol,
        "created_at": createdAt == null ? null : createdAt,
        "matches": matches == null ? null : new Map.from(matches).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "price": price == null ? null : price,
        "started_swaps": startedSwaps == null ? null : new List<dynamic>.from(startedSwaps.map((x) => x)),
        "uuid": uuid == null ? null : uuid,
    };
}