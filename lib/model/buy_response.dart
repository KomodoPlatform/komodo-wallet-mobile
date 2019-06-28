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
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? null : result.toJson(),
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
        action: json["action"] == null ? null : json["action"],
        base: json["base"] == null ? null : json["base"],
        baseAmount: json["base_amount"] == null ? null : json["base_amount"],
        destPubKey: json["dest_pub_key"] == null ? null : json["dest_pub_key"],
        method: json["method"] == null ? null : json["method"],
        rel: json["rel"] == null ? null : json["rel"],
        relAmount: json["rel_amount"] == null ? null : json["rel_amount"],
        senderPubkey: json["sender_pubkey"] == null ? null : json["sender_pubkey"],
        uuid: json["uuid"] == null ? null : json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "action": action == null ? null : action,
        "base": base == null ? null : base,
        "base_amount": baseAmount == null ? null : baseAmount,
        "dest_pub_key": destPubKey == null ? null : destPubKey,
        "method": method == null ? null : method,
        "rel": rel == null ? null : rel,
        "rel_amount": relAmount == null ? null : relAmount,
        "sender_pubkey": senderPubkey == null ? null : senderPubkey,
        "uuid": uuid == null ? null : uuid,
    };
}
