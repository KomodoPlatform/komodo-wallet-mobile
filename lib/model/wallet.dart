import 'dart:convert';

import 'package:flutter/material.dart';

List<Wallet> walletFromJson(String str) =>
    List<Wallet>.from(json.decode(str).map((dynamic x) => Wallet.fromJson(x)));

String walletToJson(List<Wallet> data) => json
    .encode(List<dynamic>.from(data.map<dynamic>((dynamic x) => x.toJson())));

class Wallet {
  Wallet(
      {@required this.name,
      @required this.id,
      @required this.isFastEncryption});

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isFastEncryption: json['is_fast_encryption'] ?? false);

  String name;
  String id;
  bool isFastEncryption;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id ?? '',
        'name': name ?? '',
        'is_fast_encryption': isFastEncryption ?? false
      };
}
