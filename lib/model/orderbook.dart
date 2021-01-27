// To parse this JSON data, do
//
//     final orderbook = orderbookFromJson(jsonString);

import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';

Orderbook orderbookFromJson(String str) => Orderbook.fromJson(json.decode(str));

String orderbookToJson(Orderbook data) => json.encode(data.toJson());

List<Orderbook> orderbooksFromJson(String str) => List<Orderbook>.from(
    json.decode(str).map((dynamic x) => Orderbook.fromJson(x)));

String orderbooksToJson(List<Orderbook> data) => json
    .encode(List<dynamic>.from(data.map<dynamic>((Orderbook x) => x.toJson())));

class Orderbook {
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

  factory Orderbook.fromJson(Map<String, dynamic> json) => Orderbook(
        bids: json['bids'] == null
            ? null
            : List<Ask>.from(json['bids'].map((dynamic x) => Ask.fromJson(x)))
                .where((Ask bid) => bid != null)
                .toList(),
        numbids: json['numbids'] ?? 0,
        asks: json['asks'] == null
            ? null
            : List<Ask>.from(json['asks'].map((dynamic x) => Ask.fromJson(x)))
                .where((Ask ask) => ask != null)
                .toList(),
        numasks: json['numasks'] ?? 0,
        askdepth: json['askdepth'] ?? 0,
        base: json['base'] ?? '',
        rel: json['rel'] ?? '',
        timestamp: json['timestamp'] ?? DateTime.now().millisecond,
        netid: json['netid'] ?? 0,
      );

  List<Ask> bids;
  int numbids;
  List<Ask> asks;
  int numasks;
  int askdepth;
  String base;
  String rel;
  int timestamp;
  int netid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bids': bids == null
            ? null
            : List<dynamic>.from(bids.map<dynamic>((Ask x) => x.toJson())),
        'numbids': numbids ?? 0,
        'asks': asks == null
            ? null
            : List<dynamic>.from(asks.map<dynamic>((Ask x) => x.toJson())),
        'numasks': numasks ?? 0,
        'askdepth': askdepth ?? 0,
        'base': base ?? '',
        'rel': rel ?? '',
        'timestamp': timestamp ?? DateTime.now().millisecond,
        'netid': netid ?? 0,
      };
}

class Ask {
  Ask({
    this.coin,
    this.address,
    this.price,
    this.maxvolume,
    this.minVolume,
    this.pubkey,
    this.age,
    this.zcredits,
  });

  factory Ask.fromJson(Map<String, dynamic> json) {
    if (isInfinite(json['price'])) return null;
    if (isInfinite(json['maxvolume'])) return null;

    return Ask(
      coin: json['coin'] ?? '',
      address: json['address'] ?? '',
      price: json['price'] ?? 0.0,
      maxvolume: deci(json['maxvolume']),
      minVolume: double.tryParse(json['min_volume']),
      pubkey: json['pubkey'] ?? '',
      age: json['age'] ?? 0,
      zcredits: json['zcredits'] ?? 0,
    );
  }

  String coin;
  String address;
  String price;
  Decimal maxvolume;
  double minVolume;
  String pubkey;
  int age;
  int zcredits;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin ?? '',
        'address': address ?? '',
        'price': price ?? 0.0,
        'maxvolume': maxvolume.toString(),
        'min_volume': minVolume.toString(),
        'pubkey': pubkey ?? '',
        'age': age ?? 0,
        'zcredits': zcredits ?? 0,
      };

  Decimal getReceiveAmount(Decimal amountToSell) {
    Decimal buyAmount = amountToSell / deci(price);
    if (buyAmount >= maxvolume) buyAmount = maxvolume;
    return buyAmount;
  }

  Decimal getReceivePrice() => deci('1') / deci(price);

  bool isMine() {
    final String myAddress = coinsBloc.getBalanceByAbbr(coin).balance.address;

    return myAddress.toLowerCase() == address.toLowerCase();
  }
}
