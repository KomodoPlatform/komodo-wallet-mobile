// To parse this JSON data, do
//
//     final orderbook = orderbookFromJson(jsonString);

import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import '../generic_blocs/coins_bloc.dart';
import '../utils/utils.dart';

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
            : List<Ask>.from(
                json['bids'].map(
                  (dynamic x) => x == null ? null : Ask.fromJson(x),
                ),
              ).where((Ask? bid) => bid != null).toList(),
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

  List<Ask>? bids;
  int? numbids;
  List<Ask>? asks;
  int? numasks;
  int? askdepth;
  String? base;
  String? rel;
  int? timestamp;
  int? netid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bids': bids == null
            ? null
            : List<dynamic>.from(bids!.map<dynamic>((Ask x) => x.toJson())),
        'numbids': numbids ?? 0,
        'asks': asks == null
            ? null
            : List<dynamic>.from(asks!.map<dynamic>((Ask x) => x.toJson())),
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
    this.priceFract,
    this.maxvolume,
    this.maxvolumeFract,
    this.minVolume,
    this.pubkey,
    this.age,
    this.zcredits,
  });

  static Ask fromJson(Map<String, dynamic> json) {
    // if (isInfinite(json['price'])) return null;
    // if (isInfinite(json['maxvolume'])) return null;

    return Ask(
      coin: json['coin'] ?? '',
      address: json['address'] ?? '',
      price: json['price'] ?? 0.0 as String?,
      priceFract: json['price_fraction'],
      maxvolume: deci(json['maxvolume']),
      maxvolumeFract: json['max_volume_fraction'],
      minVolume: fract2rat(json['min_volume_fraction']) ??
          Rational.parse(json['min_volume']),
      pubkey: json['pubkey'] ?? '',
      age: json['age'] ?? 0,
      zcredits: json['zcredits'] ?? 0,
    );
  }

  String? coin;
  String? address;
  String? price;
  Map<String, dynamic>? priceFract;
  Map<String, dynamic>? maxvolumeFract;
  Decimal? maxvolume;
  Rational? minVolume;
  String? pubkey;
  int? age;
  int? zcredits;

  Rational get priceRat {
    return fract2rat(priceFract!) ?? Rational.parse(price!);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin ?? '',
        'address': address ?? '',
        'price': price ?? 0.0,
        'price_fraction': priceFract,
        'maxvolume': maxvolume.toString(),
        'max_volume_fraction': maxvolumeFract,
        'min_volume_fraction': rat2fract(minVolume!),
        'pubkey': pubkey ?? '',
        'age': age ?? 0,
        'zcredits': zcredits ?? 0,
      };

  Rational getReceiveAmount(Rational amountToSell) {
    Rational buyAmount = amountToSell / fract2rat(priceFract!)!;
    if (buyAmount >= fract2rat(maxvolumeFract!)!)
      buyAmount = fract2rat(maxvolumeFract!)!;
    return buyAmount;
  }

  Decimal getReceivePrice() => deci('1') / deci(price);

  bool isMine() {
    final String myAddress =
        coinsBloc.getBalanceByAbbr(coin)!.balance!.address!;

    return myAddress.toLowerCase() == address!.toLowerCase();
  }

  /// Deep copy of the object
  Ask deepCopy() {
    return Ask(
      coin: coin == null ? null : String.fromCharCodes(coin!.codeUnits),
      address:
          address == null ? null : String.fromCharCodes(address!.codeUnits),
      price: price == null ? null : String.fromCharCodes(price!.codeUnits),
      priceFract:
          priceFract == null ? null : Map<String, dynamic>.from(priceFract!),
      maxvolume:
          maxvolume == null ? null : Decimal.parse(maxvolume!.toString()),
      maxvolumeFract: maxvolumeFract == null
          ? null
          : Map<String, dynamic>.from(maxvolumeFract!),
      minVolume:
          minVolume == null ? null : Rational.parse(minVolume!.toString()),
      pubkey: pubkey == null ? null : String.fromCharCodes(pubkey!.codeUnits),
      age: age == null ? null : int.tryParse(age!.toString()),
      zcredits: zcredits == null ? null : int.tryParse(zcredits!.toString()),
    );
  }
}
