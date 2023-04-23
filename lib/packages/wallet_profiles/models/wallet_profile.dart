import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// A Hive object representing a wallet profile. Wallet profiles
/// are the equivalent of user accounts in a traditional
/// authentication system.
///
/// A wallet profile contains a wallet ID and a wallet name.
/// The WalletProfile class is used to store and retrieve wallet
/// information that doesn't need to be protected by biometrics.
///
/// To use this class, register the applicable adapters and open
/// the appropriate Hive box.
///
/// Example:
///
/// ```dart
/// Hive.registerAdapter(WalletProfileAdapter());
/// final box = await Hive.openBox<WalletProfile>('wallet_profiles');
/// ```
@HiveType(typeId: 10)
class WalletProfile {
  /// Creates a new WalletProfile instance.
  ///
  /// [id] is a required unique identifier for the wallet.
  /// [name] is a required display name for the wallet.
  WalletProfile({required this.id, required this.name});

  /// A unique identifier for the wallet.
  @HiveField(0)
  final String id;

  /// The display name of the wallet.
  @HiveField(1)
  final String name;

  // Use hashCode to generare a material color for the wallet profile
  Color get color => Colors.primaries[id.hashCode % Colors.primaries.length];

  List<Object?> get props => [id, name];

  /// Creates a WalletProfile instance from a JSON map.
  ///
  /// Used for deserializing data from HydratedBloc. Hive uses the
  /// [WalletProfileAdapter] to serialize/deserialize data.
  static WalletProfile fromJson(Map<String, dynamic> json) => WalletProfile(
        id: json['id'],
        name: json['name'],
      );

  /// Creates a JSON map from a WalletProfile instance.
  ///
  /// Used for serializing data for HydratedBloc. Hive uses the
  /// [WalletProfileAdapter] to serialize/deserialize data.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

// //
// class WalletProfile {
//   WalletProfile({
//     required this.id,
//     required this.name,
//   });

//   final String id;
//   final String name;

//   static WalletProfile fromJson(Map<String, dynamic> json) => WalletProfile(
//         id: json['id'],
//         name: json['name'],
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//       };
// }
