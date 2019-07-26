// To parse this JSON data, do
//
//     final uuid = uuidFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/coin.dart';

Uuid uuidFromJson(String str) {
  final dynamic jsonData = json.decode(str);
  return Uuid.fromJson(jsonData);
}

String uuidToJson(Uuid data) {
  final Map<String, dynamic> dyn = data.toJson();
  return json.encode(dyn);
}

class Uuid {
  Uuid(
      {this.uuid,
      this.pubkey,
      this.timeStart,
      this.base,
      this.rel,
      this.amountToBuy,
      this.amountToGet});

  factory Uuid.fromJson(Map<String, dynamic> json) =>
      Uuid(
          uuid: json['uuid'] ?? '',
          pubkey: json['pubkey'] ?? '',
          timeStart: json['timeStart'] ?? 0,
          base: Coin.fromJson(json['base']) ?? Coin(),
          rel: Coin.fromJson(json['rel']) ?? Coin(),
          amountToBuy: json['amountToBuy'].toDouble() ?? 0.0,
          amountToGet: json['amountToGet'].toDouble()) ??
      0.0;

  String uuid;
  String pubkey;
  int timeStart;
  Coin base;
  Coin rel;
  double amountToBuy;
  double amountToGet;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uuid': uuid ?? '',
        'pubkey': pubkey ?? '',
        'timeStart': timeStart ?? 0,
        'base': base.toJson() ?? Coin(),
        'rel': rel.toJson() ?? Coin(),
        'amountToBuy': amountToBuy ?? 0.0,
        'amountToGet': amountToGet ?? 0.0
      };
}
