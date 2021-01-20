// To parse this JSON data, do
//
//     final getBuy = getBuyFromJson(jsonString);

import 'dart:convert';

GetBuySell getBuyFromJson(String str) => GetBuySell.fromJson(json.decode(str));

String getBuyToJson(GetBuySell data) => json.encode(data.toJson());

/// https://developers.atomicdex.io/basic-docs/atomicdex/atomicdex-api.html#buy
class GetBuySell {
  /// https://developers.atomicdex.io/basic-docs/atomicdex/atomicdex-api.html#buy
  GetBuySell({
    this.userpass,
    this.method = 'buy',
    this.base,
    this.rel,
    this.volume,
    this.max,
    this.price,
    this.baseNota,
    this.baseConfs,
    this.relNota,
    this.relConfs,
  });

  factory GetBuySell.fromJson(Map<String, dynamic> json) => GetBuySell(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        base: json['base'] ?? '',
        rel: json['rel'] ?? '',
        volume: json['volume'] ?? '',
        max: json['max'] ?? false,
        price: json['price'] ?? '',
        baseNota: json['base_nota'],
        baseConfs: json['base_confs'],
        relNota: json['rel_nota'],
        relConfs: json['rel_confs'],
      );

  String userpass;
  String method;
  String base;
  String rel;
  String volume;
  bool max;
  String price;
  bool baseNota;
  int baseConfs;
  bool relNota;
  int relConfs;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'base': base ?? '',
        'rel': rel ?? '',
        'volume': volume ?? '',
        'max': max ?? 'false',
        'price': price ?? '',
        'base_nota': baseNota,
        'base_confs': baseConfs,
        'rel_nota': relNota,
        'rel_confs': relConfs,
      };
}
