// To parse this JSON data, do
//
//     final coinInit = coinInitFromJson(jsonString);

import 'dart:convert';

List<CoinInit> coinInitFromJson(String str) => List<CoinInit>.from(json.decode(str).map((dynamic x) => CoinInit.fromJson(x)));

String coinInitToJson(List<CoinInit> data) => json.encode(List<dynamic>.from(data.map<dynamic>((dynamic x) => x.toJson())));


class CoinInit {
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
        this.txversion,
        this.overwintered,
        this.asset,
        this.etomic,
    });

    factory CoinInit.fromJson(Map<String, dynamic> json) => CoinInit(
        coin: json['coin'],
        name: json['name'],
        fname: json['fname'],
        rpcport: json['rpcport'],
        pubtype: json['pubtype'],
        p2Shtype: json['p2shtype'],
        wiftype: json['wiftype'],
        txfee: json['txfee'],
        mm2: json['mm2'],
        txversion: json['txversion'],
        overwintered: json['overwintered'],
        asset: json['asset'],
        etomic: json['etomic'],
    );

    String coin;
    String name;
    String fname;
    int rpcport;
    int pubtype;
    int p2Shtype;
    int wiftype;
    int txfee;
    int mm2;
    int txversion;
    int overwintered;
    String asset;
    String etomic;

    Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin,
        'name': name,
        'fname': fname,
        'rpcport': rpcport,
        'pubtype': pubtype,
        'p2shtype': p2Shtype,
        'wiftype': wiftype,
        'txfee': txfee,
        'mm2': mm2,
        'txversion': txversion,
        'overwintered': overwintered,
        'asset': asset,
        'etomic': etomic,
    };
}
