import 'dart:convert';

import 'package:flutter/material.dart';

List<Wallet> walletFromJson(String str) =>
    new List<Wallet>.from(json.decode(str).map((x) => Wallet.fromJson(x)));

String walletToJson(List<Wallet> data) =>
    json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Wallet {
  String name;
  String id;
  bool isFastEncryption;

  Wallet({@required this.name, @required this.id, @required this.isFastEncryption});

    factory Wallet.fromJson(Map<String, dynamic> json) => new Wallet(
        id: json["id"],
        name: json["name"],
        isFastEncryption: json["is_fast_encryption"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "is_fast_encryption": isFastEncryption
      };
}