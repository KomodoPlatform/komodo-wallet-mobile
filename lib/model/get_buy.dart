// To parse this JSON data, do
//
//     final getBuy = getBuyFromJson(jsonString);

import 'dart:convert';

GetBuySell getBuyFromJson(String str) => GetBuySell.fromJson(json.decode(str));

String getBuyToJson(GetBuySell data) => json.encode(data.toJson());

/// https://developers.komodoplatform.com/basic-docs/atomicdex/atomicdex-api.html#buy
class GetBuySell {
  /// https://developers.komodoplatform.com/basic-docs/atomicdex/atomicdex-api.html#buy
  GetBuySell({
    this.userpass,
    this.method = 'buy',
    this.base,
    this.rel,
    this.volume,
    this.price,
    this.orderType,
    this.baseNota,
    this.baseConfs,
    this.relNota,
    this.relConfs,
  });

  factory GetBuySell.fromJson(Map<String, dynamic> json) {
    final String typeStr =
        json['order_type'] != null && json['order_type']['type'] != null
            ? json['order_type']['type']
            : null;

    BuyOrderType orderType;
    switch (typeStr) {
      case 'FillOrKill':
        orderType = BuyOrderType.FillOrKill;
        break;
      default:
        orderType = BuyOrderType.GoodTillCancelled;
    }

    return GetBuySell(
      userpass: json['userpass'] ?? '',
      method: json['method'] ?? '',
      base: json['base'] ?? '',
      rel: json['rel'] ?? '',
      volume: json['volume'] ?? '',
      price: json['price'] ?? '',
      orderType: orderType,
      baseNota: json['base_nota'],
      baseConfs: json['base_confs'],
      relNota: json['rel_nota'],
      relConfs: json['rel_confs'],
    );
  }

  String userpass;
  String method;
  String base;
  String rel;
  BuyOrderType orderType;
  bool baseNota;
  int baseConfs;
  bool relNota;
  int relConfs;
  dynamic price; // numerical String or {'numer': '1', 'denom': '3'}
  dynamic volume; // https://bit.ly/2O2DxWh

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'base': base ?? '',
        'rel': rel ?? '',
        'volume': volume ?? '',
        'price': price ?? '',
        'order_type': {
          'type': orderType == BuyOrderType.FillOrKill
              ? 'FillOrKill'
              : 'GoodTillCancelled'
        },
        'base_nota': baseNota,
        'base_confs': baseConfs,
        'rel_nota': relNota,
        'rel_confs': relConfs,
      };
}

enum BuyOrderType { GoodTillCancelled, FillOrKill }
