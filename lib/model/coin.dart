// To parse this JSON data, do
//
//     final coin = coinFromJson(jsonString);

import 'dart:convert';

Coin coinFromJson(String str) {
  final jsonData = json.decode(str);
  return Coin.fromJson(jsonData);
}

List<Coin> listCoinFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Coin>.from(jsonData.map((x) => Coin.fromJson(x)));
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
  int mm2;
  String swap_contract_address;
  List<String> serverList;
  List<String> explorerUrl;
  String colorCoin;

  Coin({
    this.name,
    this.address,
    this.port,
    this.proto,
    this.txfee,
    this.abbr,
    this.mm2,
    this.swap_contract_address,
    this.serverList,
    this.explorerUrl,
    this.colorCoin
  });

  factory Coin.fromJson(Map<String, dynamic> json) => new Coin(
    name: json["name"],
    address: json["address"],
    port: json["port"],
    proto: json["proto"],
    txfee: json["txfee"],
    abbr: json["abbr"],
    mm2: json["mm2"],
    swap_contract_address: json["swap_contract_address"],
    colorCoin: json["colorCoin"],
    serverList: new List<String>.from(json["serverList"].map((x) => x)),
    explorerUrl: new List<String>.from(json["explorerUrl"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "address": address,
    "port": port,
    "proto": proto,
    "txfee": txfee,
    "abbr": abbr,
    "mm2": mm2,
    "swap_contract_address": swap_contract_address,
    "colorCoin": colorCoin,
    "serverList": new List<dynamic>.from(serverList.map((x) => x)),
    "explorerUrl": new List<dynamic>.from(explorerUrl.map((x) => x)),
  };

  String getTxFeeSatoshi() {
      return (txfee / 100000000).toString();
  }
}
