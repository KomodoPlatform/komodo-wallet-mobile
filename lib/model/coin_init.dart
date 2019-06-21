// To parse this JSON data, do
//
//     final coinInit = coinInitFromJson(jsonString);

import 'dart:convert';

List<CoinInit> coinInitFromJson(String str) => new List<CoinInit>.from(json.decode(str).map((x) => CoinInit.fromJson(x)));

String coinInitToJson(List<CoinInit> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class CoinInit {
    String coin;
    String name;
    String fname;
    int rpcport;
    int pubtype;
    int p2Shtype;
    int wiftype;
    int txfee;
    int mm2;
    String asset;
    String etomic;

    CoinInit({
        this.coin,
        this.name,
        this.fname,
        this.rpcport,
        this.pubtype,
        this.p2Shtype,
        this.wiftype,
        this.txfee,
        this.mm2,
        this.asset,
        this.etomic,
    });

    factory CoinInit.fromJson(Map<String, dynamic> json) => new CoinInit(
        coin: json["coin"],
        name: json["name"] == null ? null : json["name"],
        fname: json["fname"] == null ? null : json["fname"],
        rpcport: json["rpcport"] == null ? null : json["rpcport"],
        pubtype: json["pubtype"] == null ? null : json["pubtype"],
        p2Shtype: json["p2shtype"] == null ? null : json["p2shtype"],
        wiftype: json["wiftype"] == null ? null : json["wiftype"],
        txfee: json["txfee"] == null ? null : json["txfee"],
        mm2: json["mm2"] == null ? null : json["mm2"],
        asset: json["asset"] == null ? null : json["asset"],
        etomic: json["etomic"] == null ? null : json["etomic"],
    );

    Map<String, dynamic> toJson() => {
        "coin": coin,
        "name": name == null ? null : name,
        "fname": fname == null ? null : fname,
        "rpcport": rpcport == null ? null : rpcport,
        "pubtype": pubtype == null ? null : pubtype,
        "p2shtype": p2Shtype == null ? null : p2Shtype,
        "wiftype": wiftype == null ? null : wiftype,
        "txfee": txfee == null ? null : txfee,
        "mm2": mm2 == null ? null : mm2,
        "asset": asset == null ? null : asset,
        "etomic": etomic == null ? null : etomic,
    };
}
