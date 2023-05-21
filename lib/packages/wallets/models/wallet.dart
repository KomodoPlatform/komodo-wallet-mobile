import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:komodo_dex/atomicdex_api/src/models/value/asset.dart';
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
  final String? description;

  @HiveField(3)
  final FiatAsset? balance;

  // RESERVED FOR FUTURE USE
  @HiveField(4)
  final Color? color;

  // RESERVED FOR FUTURE USE
  @HiveField(5)
  final Uint8List? profileImage;

  /// Creates a new Wallet instance.
  ///
  /// [name] is a required display name for the wallet.
  /// [walletId] is a required unique identifier for the wallet.
  /// [description] is a required description for the wallet.
  /// [balance] is an optional balance for the wallet.
  Wallet({
    required this.name,
    required this.walletId,
    this.description,
    this.balance,
    this.color,
    this.profileImage,
  });

  legacy.Wallet toLegacy() => legacy.Wallet(
        name: name,
        id: walletId,
      );

  List<Object?> get props => [
        name,
        walletId,
        description,
        balance,
        color,
        profileImage,
      ];

  /// Creates a Wallet instance from a JSON map.
  ///
  /// [json] is the map containing the wallet data.
  static Wallet fromJson(Map<String, dynamic> json) => Wallet(
        name: json['name'],
        walletId: json['walletId'],
        description: json['description'],
        balance: json['balance'] != null
            ? FiatAsset.fromJson(json['balance'])
            : null,
      );

  /// Creates a JSON map from a Wallet instance.
  ///
  /// Returns a map containing the wallet data.
  Map<String, dynamic> toJson() => {
        'name': name,
        'walletId': walletId,
        'description': description,
        'balance': balance?.toJson(),
      };
}

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 100;

  @override
  Wallet read(BinaryReader reader) {
    final name = reader.readString();
    final walletId = reader.readString();
    final description = reader.read() as String?;

    final balanceJson = reader.read() as Map<String, dynamic>?;
    final balance =
        balanceJson != null ? FiatAsset.fromJson(balanceJson) : null;

    // FIELDS RESERVED FOR FUTURE USE
    reader.read() as Color?;
    reader.read() as List<int>?;

    return Wallet(
      name: name,
      walletId: walletId,
      description: description,
      balance: balance,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.walletId);
    writer.write(obj.description);
    writer.write(obj.balance?.toJson());

    // FIELD RESERVED FOR FUTURE USE
    const Color? color = null;
    writer.write(color);

    // FIELD RESERVED FOR FUTURE USE
    const Uint8List? profileImage = null;
    writer.write(profileImage);
  }
}
