import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:komodo_dex/atomicdex_api/src/models/value/asset.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/model/wallet.dart' as legacy;

/// A class representing a wallet containing accounts.
///
/// Each wallet has a name, a wallet ID, a description, a nullable balance, and a list of accounts.
/// The wallet ID uniquely identifies the wallet.
@HiveType(typeId: 100)
class Wallet extends HiveObject {
  @HiveField(0)
  final String name;

  // TODO: Determine wallet ID deterministically from passphrase.
  @HiveField(1)
  final String walletId;

  @HiveField(2)
  final String description;

  // @HiveField(3)
  // final FiatAsset? balance;

  FiatAsset get balance => FiatAsset.currency(FiatCurrency.USD, 69.42);

  // Material colour based on the wallet ID.
  Color get color =>
      Colors.primaries[walletId.hashCode % Colors.primaries.length];

  /// Creates a new Wallet instance.
  ///
  /// [name] is a required display name for the wallet.
  /// [walletId] is a required unique identifier for the wallet.
  /// [description] is a required description for the wallet.
  /// [balance] is an optional balance for the wallet.
  Wallet({
    required this.name,
    required this.walletId,
    required this.description,
    // this.balance,
  });

  legacy.Wallet toLegacy() => legacy.Wallet(
        name: name,
        id: walletId,
        // balance: balance,
      );

  List<Object?> get props => [
        name,
        walletId,
        description,
        // balance,
      ];

  /// Creates a Wallet instance from a JSON map.
  ///
  /// [json] is the map containing the wallet data.
  static Wallet fromJson(Map<String, dynamic> json) => Wallet(
        name: json['name'],
        walletId: json['walletId'],
        description: json['description'],
        //TODO: Implement properly
        // balance: json['balance'] != null
        //     ? FiatAsset()
        //     : null,
      );

  /// Creates a JSON map from a Wallet instance.
  ///
  /// Returns a map containing the wallet data.
  Map<String, dynamic> toJson() => {
        'name': name,
        'walletId': walletId,
        'description': description,
        // 'balance': balance?.toJson(),
      };
}

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 100;

  @override
  Wallet read(BinaryReader reader) {
    final name = reader.readString();
    final walletId = reader.readString();
    final description = reader.readString();
    // final balanceJson = reader.read();
    // final balance = balanceJson != null
    //     ? FiatAsset.fromJson(jsonDecode(balanceJson) as Map<String, dynamic>)
    //     : null;
    return Wallet(
      name: name,
      walletId: walletId,
      description: description,
      // balance: balance,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.walletId);
    writer.writeString(obj.description);
    // final balanceJson =
    //     obj.balance != null ? jsonEncode(obj.balance!.toJson()) : null;
    // writer.write(balanceJson);
  }
}
