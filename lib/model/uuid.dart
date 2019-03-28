// To parse this JSON data, do
//
//     final uuid = uuidFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/coin.dart';

Uuid uuidFromJson(String str) {
    final jsonData = json.decode(str);
    return Uuid.fromJson(jsonData);
}

String uuidToJson(Uuid data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Uuid {
    String uuid;
    String pubkey;
    int timeStart;
    Coin base;
    Coin rel;
    double amountToBuy;
    double amountToGet;

    Uuid({
        this.uuid,
        this.pubkey,
        this.timeStart,
        this.base, 
        this.rel, 
        this.amountToBuy,
        this.amountToGet
    });

    factory Uuid.fromJson(Map<String, dynamic> json) => new Uuid(
        uuid: json["uuid"],
        pubkey: json["pubkey"],
        timeStart: json["timeStart"],
        base: Coin.fromJson(json["base"]),
        rel: Coin.fromJson(json["rel"]),
        amountToBuy: json["amountToBuy"].toDouble(),
        amountToGet: json["amountToGet"].toDouble()
    );

    Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "pubkey": pubkey,
        "timeStart": timeStart,
        "base": base.toJson(),
        "rel": rel.toJson(),
        "amountToBuy": amountToBuy,
        "amountToGet": amountToGet
    };
}