// To parse this JSON data, do
//
//     final orderbook = orderbookFromJson(jsonString);

import 'dart:convert';

Orderbook orderbookFromJson(String str) {
  final jsonData = json.decode(str);
  return Orderbook.fromJson(jsonData);
}

String orderbookToJson(Orderbook data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Orderbook {
  int askdepth;
  List<Ask> asks;
  String base;
  int biddepth;
  List<Ask> bids;
  int netid;
  int numasks;
  int numbids;
  String rel;
  int timestamp;

  Orderbook({
    this.askdepth,
    this.asks,
    this.base,
    this.biddepth,
    this.bids,
    this.netid,
    this.numasks,
    this.numbids,
    this.rel,
    this.timestamp,
  });

  factory Orderbook.fromJson(Map<String, dynamic> json) => new Orderbook(
        askdepth: json["askdepth"],
        asks: new List<Ask>.from(json["asks"].map((x) => Ask.fromJson(x))),
        base: json["base"],
        biddepth: json["biddepth"],
        bids: new List<Ask>.from(json["bids"].map((x) => Ask.fromJson(x))),
        netid: json["netid"],
        numasks: json["numasks"],
        numbids: json["numbids"],
        rel: json["rel"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "askdepth": askdepth,
        "asks": new List<dynamic>.from(asks.map((x) => x.toJson())),
        "base": base,
        "biddepth": biddepth,
        "bids": new List<dynamic>.from(bids.map((x) => x.toJson())),
        "netid": netid,
        "numasks": numasks,
        "numbids": numbids,
        "rel": rel,
        "timestamp": timestamp,
      };
}

class Ask {
  String address;
  int age;
  int avevolume;
  String coin;
  int depth;
  double maxvolume;
  int numutxos;
  double price;
  String pubkey;
  int zcredits;

  Ask({
    this.address,
    this.age,
    this.avevolume,
    this.coin,
    this.depth,
    this.maxvolume,
    this.numutxos,
    this.price,
    this.pubkey,
    this.zcredits,
  });

  factory Ask.fromJson(Map<String, dynamic> json) => new Ask(
        address: json["address"],
        age: json["age"],
        avevolume: json["avevolume"],
        coin: json["coin"],
        depth: json["depth"],
        maxvolume: json["maxvolume"].toDouble(),
        numutxos: json["numutxos"],
        price: json["price"].toDouble(),
        pubkey: json["pubkey"],
        zcredits: json["zcredits"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "age": age,
        "avevolume": avevolume,
        "coin": coin,
        "depth": depth,
        "maxvolume": maxvolume,
        "numutxos": numutxos,
        "price": price,
        "pubkey": pubkey,
        "zcredits": zcredits,
      };
}
