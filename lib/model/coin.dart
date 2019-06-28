// To parse this JSON data, do
//
//     final coin = coinFromJson(jsonString);

import 'dart:convert';

List<Coin> coinFromJson(String str) => new List<Coin>.from(json.decode(str).map((x) => Coin.fromJson(x)));

String coinToJson(List<Coin> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Coin {
    String name;
    String address;
    int port;
    String proto;
    int txfee;
    double priceUsd;
    int mm2;
    String abbr;
    String colorCoin;
    List<String> serverList;
    List<String> explorerUrl;
    String swapContractAddress;

    Coin({
        this.name,
        this.address,
        this.port,
        this.proto,
        this.txfee,
        this.priceUsd,
        this.mm2,
        this.abbr,
        this.swapContractAddress,
        this.colorCoin,
        this.serverList,
        this.explorerUrl,
    });

    factory Coin.fromJson(Map<String, dynamic> json) => new Coin(
        name: json["name"] == null ? null : json["name"],
        address: json["address"] == null ? null : json["address"],
        port: json["port"] == null ? null : json["port"],
        proto: json["proto"] == null ? null : json["proto"],
        txfee: json["txfee"] == null ? null : json["txfee"],
        priceUsd: json["priceUSD"] == null ? null : json["priceUSD"].toDouble(),
        mm2: json["mm2"] == null ? null : json["mm2"],
        abbr: json["abbr"] == null ? null : json["abbr"],
        swapContractAddress: json["swap_contract_address"] == null ? null : json["swap_contract_address"],
        colorCoin: json["colorCoin"] == null ? null : json["colorCoin"],
        serverList: json["serverList"] == null ? null : new List<String>.from(json["serverList"].map((x) => x)),
        explorerUrl: json["explorerUrl"] == null ? null : new List<String>.from(json["explorerUrl"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "address": address == null ? null : address,
        "port": port == null ? null : port,
        "proto": proto == null ? null : proto,
        "txfee": txfee == null ? null : txfee,
        "priceUSD": priceUsd == null ? null : priceUsd,
        "mm2": mm2 == null ? null : mm2,
        "abbr": abbr == null ? null : abbr,
        "swap_contract_address": swapContractAddress == null ? null : swapContractAddress,
        "colorCoin": colorCoin == null ? null : colorCoin,
        "serverList": serverList == null ? null : new List<dynamic>.from(serverList.map((x) => x)),
        "explorerUrl": explorerUrl == null ? null : new List<dynamic>.from(explorerUrl.map((x) => x)),
    };

      String getTxFeeSatoshi() {
    return (txfee / 100000000).toString();
  }
}