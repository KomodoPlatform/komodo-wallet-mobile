import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';

/// A class representing an account in a wallet.
///
/// Each account has an account ID and a name.
/// The account ID uniquely identifies the account within a wallet. An accountId
/// of -1 indicates that the wallet has not been migrated to the new HD
/// multi-account structure.
@HiveType(typeId: 200)
// TODO: Should Account store the wallet ID? We want the concerns to be separate.
class Account extends HiveObject {
  /// Creates a new Account instance.
  ///
  /// [accountId] is a required unique identifier for the account within a wallet.
  /// [name] is a required display name for the account.
  Account({
    required this.accountId,
    required this.name,
    this.description,
  });

  @HiveField(0)
  final AccountId accountId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  /// Creates an Account instance from a JSON map.
  ///
  /// [json] is the map containing the account data.
  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: AccountId.fromJson(json['accountId']),
      name: json['name'],
      description: json['description'],
    );
  }

  /// Creates a JSON map from an Account instance.
  ///
  /// Returns a map containing the account data.
  Map<String, dynamic> toJson() => {
        'accountId': accountId.toJson(),
        'name': name,
        'description': description,
      };
}
