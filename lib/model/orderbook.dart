// To parse this JSON data, do
//
//     final orderbook = orderbookFromJson(jsonString);

import 'dart:convert';

Orderbook orderbookFromJson(String str) => Orderbook.fromJson(json.decode(str));

String orderbookToJson(Orderbook data) => json.encode(data.toJson());

class Orderbook {
    List<Ask> bids;
    int numbids;
    List<Ask> asks;
    int numasks;
    int askdepth;
    String base;
    String rel;
    int timestamp;
    int netid;

    Orderbook({
        this.bids,
        this.numbids,
        this.asks,
        this.numasks,
        this.askdepth,
        this.base,
        this.rel,
        this.timestamp,
        this.netid,
    });

    factory Orderbook.fromJson(Map<String, dynamic> json) => new Orderbook(
        bids: json["bids"] == null ? null : new List<Ask>.from(json["bids"].map((x) => Ask.fromJson(x))),
        numbids: json["numbids"] == null ? null : json["numbids"],
        asks: json["asks"] == null ? null : new List<Ask>.from(json["asks"].map((x) => Ask.fromJson(x))),
        numasks: json["numasks"] == null ? null : json["numasks"],
        askdepth: json["askdepth"] == null ? null : json["askdepth"],
        base: json["base"] == null ? null : json["base"],
        rel: json["rel"] == null ? null : json["rel"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        netid: json["netid"] == null ? null : json["netid"],
    );

    Map<String, dynamic> toJson() => {
        "bids": bids == null ? null : new List<dynamic>.from(bids.map((x) => x.toJson())),
        "numbids": numbids == null ? null : numbids,
        "asks": asks == null ? null : new List<dynamic>.from(asks.map((x) => x.toJson())),
        "numasks": numasks == null ? null : numasks,
        "askdepth": askdepth == null ? null : askdepth,
        "base": base == null ? null : base,
        "rel": rel == null ? null : rel,
        "timestamp": timestamp == null ? null : timestamp,
        "netid": netid == null ? null : netid,
    };
}

class Ask {
    String coin;
    String address;
    double price;
    double maxvolume;
    String pubkey;
    int age;
    int zcredits;

    Ask({
        this.coin,
        this.address,
        this.price,
        this.maxvolume,
        this.pubkey,
        this.age,
        this.zcredits,
    });

    factory Ask.fromJson(Map<String, dynamic> json) => new Ask(
        coin: json["coin"] == null ? null : json["coin"],
        address: json["address"] == null ? null : json["address"],
        price: json["price"] == null ? null : json["price"].toDouble(),
        maxvolume: json["maxvolume"] == null ? null : json["maxvolume"].toDouble(),
        pubkey: json["pubkey"] == null ? null : json["pubkey"],
        age: json["age"] == null ? null : json["age"],
        zcredits: json["zcredits"] == null ? null : json["zcredits"],
    );

    Map<String, dynamic> toJson() => {
        "coin": coin == null ? null : coin,
        "address": address == null ? null : address,
        "price": price == null ? null : price,
        "maxvolume": maxvolume == null ? null : maxvolume,
        "pubkey": pubkey == null ? null : pubkey,
        "age": age == null ? null : age,
        "zcredits": zcredits == null ? null : zcredits,
    };
}
