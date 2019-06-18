// To parse this JSON data, do
//
//     final setPriceResponse = setPriceResponseFromJson(jsonString);

import 'dart:convert';

SetPriceResponse setPriceResponseFromJson(String str) => SetPriceResponse.fromJson(json.decode(str));

String setPriceResponseToJson(SetPriceResponse data) => json.encode(data.toJson());

class SetPriceResponse {
    Result result;

    SetPriceResponse({
        this.result,
    });

    factory SetPriceResponse.fromJson(Map<String, dynamic> json) => new SetPriceResponse(
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result.toJson(),
    };
}

class Result {
    String base;
    String rel;
    String maxBaseVol;
    String minBaseVol;
    int createdAt;
    Matches matches;
    String price;
    List<dynamic> startedSwaps;
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
        base: json["base"],
        rel: json["rel"],
        maxBaseVol: json["max_base_vol"],
        minBaseVol: json["min_base_vol"],
        createdAt: json["created_at"],
        matches: Matches.fromJson(json["matches"]),
        price: json["price"],
        startedSwaps: new List<dynamic>.from(json["started_swaps"].map((x) => x)),
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "base": base,
        "rel": rel,
        "max_base_vol": maxBaseVol,
        "min_base_vol": minBaseVol,
        "created_at": createdAt,
        "matches": matches.toJson(),
        "price": price,
        "started_swaps": new List<dynamic>.from(startedSwaps.map((x) => x)),
        "uuid": uuid,
    };
}

class Matches {
    Matches();

    factory Matches.fromJson(Map<String, dynamic> json) => new Matches(
    );

    Map<String, dynamic> toJson() => {
    };
}
