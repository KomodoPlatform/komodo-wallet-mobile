// To parse this JSON data, do
//
//     final coin = coinFromJson(jsonString);

import 'dart:convert';

Coin coinFromJson(String str) {
  final jsonData = json.decode(str);
  return Coin.fromJson(jsonData);
}

String coinToJson(Coin data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Coin {
  String name;
  String address;
  int port;
  String proto;
  int txfee;
  String abbr;
  List<String> serverList;

  Coin({
    this.name,
    this.address,
    this.port,
    this.proto,
    this.txfee,
    this.abbr,
    this.serverList,
  });

  factory Coin.fromJson(Map<String, dynamic> json) => new Coin(
    name: json["name"],
    address: json["address"],
    port: json["port"],
    proto: json["proto"],
    txfee: json["txfee"],
    abbr: json["abbr"],
    serverList: new List<String>.from(json["serverList"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "address": address,
    "port": port,
    "proto": proto,
    "txfee": txfee,
    "abbr": abbr,
    "serverList": new List<dynamic>.from(serverList.map((x) => x)),
  };
}
