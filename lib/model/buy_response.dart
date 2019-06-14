// To parse this JSON data, do
//
//     final buyResponse = buyResponseFromJson(jsonString);

import 'dart:convert';

BuyResponse buyResponseFromJson(String str) => BuyResponse.fromJson(json.decode(str));

String buyResponseToJson(BuyResponse data) => json.encode(data.toJson());

class BuyResponse {
    Result result;

    BuyResponse({
        this.result,
    });

    factory BuyResponse.fromJson(Map<String, dynamic> json) => new BuyResponse(
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result.toJson(),
    };
}

class Result {
    String action;
    String base;
    String baseAmount;
    String destPubKey;
    String method;
    String rel;
    String relAmount;
    String senderPubkey;
    String uuid;

    Result({
        this.action,
        this.base,
        this.baseAmount,
        this.destPubKey,
        this.method,
        this.rel,
        this.relAmount,
        this.senderPubkey,
        this.uuid,
    });

    factory Result.fromJson(Map<String, dynamic> json) => new Result(
        action: json["action"],
        base: json["base"],
        baseAmount: json["base_amount"],
        destPubKey: json["dest_pub_key"],
        method: json["method"],
        rel: json["rel"],
        relAmount: json["rel_amount"],
        senderPubkey: json["sender_pubkey"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "action": action,
        "base": base,
        "base_amount": baseAmount,
        "dest_pub_key": destPubKey,
        "method": method,
        "rel": rel,
        "rel_amount": relAmount,
        "sender_pubkey": senderPubkey,
        "uuid": uuid,
    };
}
