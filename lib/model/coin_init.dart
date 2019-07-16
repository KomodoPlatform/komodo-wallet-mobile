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
        this.asset,
        this.etomic,
    });

    factory CoinInit.fromJson(Map<String, dynamic> json) => CoinInit(
        coin: json['coin'] ?? '',
        name: json['name'] ?? '',
        fname: json['fname'] ?? '',
        rpcport: json['rpcport'] ?? 0,
        pubtype: json['pubtype'] ?? 0,
        p2Shtype: json['p2shtype'] ?? 0,
        wiftype: json['wiftype'] ?? 0,
        txfee: json['txfee'] ?? 0,
        mm2: json['mm2'] ?? 0,
        asset: json['asset'] ?? '',
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
    String asset;
    String etomic;

    Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin,
        'name': name ?? '',
        'fname': fname ?? '',
        'rpcport': rpcport ?? 0,
        'pubtype': pubtype ?? 0,
        'p2shtype': p2Shtype ?? 0,
        'wiftype': wiftype ?? 0,
        'txfee': txfee ?? 0,
        'mm2': mm2 ?? 0,
        'asset': asset ?? '',
        'etomic': etomic,
    };
}
