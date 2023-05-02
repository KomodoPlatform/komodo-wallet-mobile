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


// /// A Hive object representing an account. Accounts are used
// /// to group wallets.
// ///
// /// An account contains an ID, name, and a list of wallets.
// /// The Account class is used to store and retrieve account
// /// information.
// ///
// /// To use this class, register the applicable adapters and open
// /// the appropriate Hive box.
// ///
// /// Example:
// ///
// /// ```dart
// /// Hive.registerAdapter(AccountAdapter());
// /// Hive.registerAdapter(WalletAdapter());
// /// final box = await Hive.openBox<Account>('accounts');
// /// ```
// @HiveType(typeId: 10)
// class Account extends HiveObject {
//   /// Creates a new Account instance.
//   ///
//   /// [id] is a required unique identifier for the account.
//   /// [name] is a required display name for the account.
//   /// [wallets] is a required list of wallets.
//   Account({required this.id, required this.name, required this.wallets});

//   /// A unique identifier for the account.
//   @HiveField(0)
//   final String id;

//   /// The display name of the account.
//   @HiveField(1)
//   final String name;

//   /// The list of wallets associated with the account.
//   @HiveField(2)
//   final List<Wallet> wallets;

//   /// Generates a material color for the account.
//   Color get color => Colors.primaries[id.hashCode % Colors.primaries.length];

//   List<Object?> get props => [id, name, wallets];

//   /// Creates an Account instance from a JSON map.
//   ///
//   /// Used for deserializing data from HydratedBloc. Hive uses the
//   /// [AccountAdapter] to serialize/deserialize data.
//   static Account fromJson(Map<String, dynamic> json) => Account(
//         id: json['id'],
//         name: json['name'],
//         wallets: (json['wallets'] as List)
//             .map((wallet) => Wallet.fromJson(wallet as Map<String, dynamic>))
//             .toList(),
//       );

//   /// Creates a JSON map from an Account instance.
//   ///
//   /// Used for serializing data for HydratedBloc. Hive uses the
//   /// [AccountAdapter] to serialize/deserialize data.
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'wallets': wallets.map((wallet) => wallet.toJson()).toList(),
//       };
// }

// // Account adapter
// class AccountAdapter extends TypeAdapter<Account> {
//   @override
//   final int typeId = 10;

//   @override
//   Account read(BinaryReader reader) {
//     final id = reader.readString();
//     final name = reader.readString();
//     final wallets = reader.readHiveList().castHiveList<Wallet>();
//     return Account(id: id, name: name, wallets: wallets);
//   }

//   @override
//   void write(BinaryWriter writer, Account obj) {
//     writer.writeString(obj.id);
//     writer.writeString(obj.name);
//     writer.writeStringList(
//   }
// }
