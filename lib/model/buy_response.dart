// To parse this JSON data, do
//
//     final buyResponse = buyResponseFromJson(jsonString);

import 'dart:convert';

BuyResponse buyResponseFromJson(String str) {
    final jsonData = json.decode(str);
    return BuyResponse.fromJson(jsonData);
}

String buyResponseToJson(BuyResponse data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class BuyResponse {
    List<dynamic> netamounts;
    Pending pending;
    String result;
    List<List<int>> swaps;
    String uuid;

    BuyResponse({
        this.netamounts,
        this.pending,
        this.result,
        this.swaps,
        this.uuid,
    });

    factory BuyResponse.fromJson(Map<String, dynamic> json) => new BuyResponse(
        netamounts: new List<dynamic>.from(json["netamounts"].map((x) => x)),
        pending: Pending.fromJson(json["pending"]),
        result: json["result"],
        swaps: new List<List<int>>.from(json["swaps"].map((x) => new List<int>.from(x.map((x) => x)))),
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "netamounts": new List<dynamic>.from(netamounts.map((x) => x)),
        "pending": pending.toJson(),
        "result": result,
        "swaps": new List<dynamic>.from(swaps.map((x) => new List<dynamic>.from(x.map((x) => x)))),
        "uuid": uuid,
    };
}

class Pending {
    String alice;
    int aliceid;
    String base;
    double basevalue;
    String bob;
    String desthash;
    int expiration;
    int quoteid;
    String rel;
    double relvalue;
    int requestid;
    int timeleft;
    int tradeid;
    String uuid;

    Pending({
        this.alice,
        this.aliceid,
        this.base,
        this.basevalue,
        this.bob,
        this.desthash,
        this.expiration,
        this.quoteid,
        this.rel,
        this.relvalue,
        this.requestid,
        this.timeleft,
        this.tradeid,
        this.uuid,
    });

    factory Pending.fromJson(Map<String, dynamic> json) => new Pending(
        alice: json["alice"],
        aliceid: json["aliceid"],
        base: json["base"],
        basevalue: json["basevalue"].toDouble(),
        bob: json["bob"],
        desthash: json["desthash"],
        expiration: json["expiration"],
        quoteid: json["quoteid"],
        rel: json["rel"],
        relvalue: json["relvalue"].toDouble(),
        requestid: json["requestid"],
        timeleft: json["timeleft"],
        tradeid: json["tradeid"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "alice": alice,
        "aliceid": aliceid,
        "base": base,
        "basevalue": basevalue,
        "bob": bob,
        "desthash": desthash,
        "expiration": expiration,
        "quoteid": quoteid,
        "rel": rel,
        "relvalue": relvalue,
        "requestid": requestid,
        "timeleft": timeleft,
        "tradeid": tradeid,
        "uuid": uuid,
    };
}
