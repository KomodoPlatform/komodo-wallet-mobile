import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/atomicdex_api/src/models/value/asset.dart';
import 'package:komodo_dex/model/wallet.dart' as legacy;

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
    required this.walletId,
    this.description,
    this.avatar,
    Color? themeColor,
  }) : _themeColor = _serializeColor(themeColor) {
    _checkImageSize(avatar, 300);
  }

  @HiveField(0)
  final AccountId accountId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? _themeColor;

  @HiveField(4)
  final List<int>? avatar;

  @HiveField(5)
  final String walletId;

  ImageProvider? get avatarImageProvider =>
      avatar != null ? MemoryImage(Uint8List.fromList(avatar!)) : null;

  // TODO: Replace with actual serializable balance.
  FiatAsset get balance => FiatAsset.currency(FiatCurrency.USD, 0);

  Color? get themeColor =>
      _themeColor != null ? Color(int.parse(_themeColor!, radix: 16)) : null;

  /// Provides a unique identifier for the account to identify it across wallets.
  ///
  /// This can be used in the single-account legacy code as the wallet ID.
  String get legacyId => '$walletId:${accountId.toJson().toString()}';

  legacy.Wallet asLegacyWallet() => legacy.Wallet(
        name: name,
        id: legacyId,
      );

  /// Creates an Account instance from a JSON map.
  ///
  /// [json] is the map containing the account data.
  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      walletId: json['walletId'] as String,
      accountId: AccountId.fromJson(json['accountId']),
      name: json['name'],
      description: json['description'] as String?,
      themeColor: _parseColor(json['themeColor'] as String?),
      avatar: json['avatar'] == null
          ? null
          : (json['avatar'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  /// Creates a JSON map from an Account instance.
  ///
  /// Returns a map containing the account data.

  Map<String, dynamic> toJson() => {
        'accountId': accountId.toJson(),
        'name': name,
        'description': description,
        'themeColor': themeColor,
        'avatar': avatar,
      };

  static void _checkImageSize(List<int>? imageBytes, int maxSizeInKB) {
    if (imageBytes != null && imageBytes.length > maxSizeInKB * 1024) {
      throw Exception(
          'Image size exceeds the maximum limit of $maxSizeInKB KB.');
    }
  }
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 200;

  @override
  Account read(BinaryReader reader) {
    final accountIdJson = jsonDecode(reader.readString());
    final accountId = AccountId.fromJson(accountIdJson);

    final name = reader.readString();

    // final description = _readNullable<String>(reader.read());
    final description = reader.read() as String?;

    // final colorString = _readNullable<String>(reader.read());
    final colorString = reader.read() as String?;
    final themeColor = _parseColor(colorString);

    // final avatar = _readNullable<List<int>>(reader.read());
    final avatar = reader.read() as List<int>?;

    final walletId = reader.readString();

    return Account(
      walletId: walletId,
      accountId: accountId,
      name: name,
      description: description,
      themeColor: themeColor,
      avatar: avatar,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer.writeString(jsonEncode(obj.accountId.toJson()));

    writer.writeString(obj.name);

    writer.write<String?>(obj.description);
    // writer.write(null);

    writer.write<String?>(_serializeColor(obj.themeColor));
    // writer.write(null);

    writer.write<List<int>?>(obj.avatar);
    // writer.write(null);

    writer.writeString(obj.walletId);
  }

  /// Reads a nullable value from the reader. We can't directly store null
  /// values in Hive, so we use a special value to represent null. If the value
  /// is the special value, we return null. Otherwise, we return the value.
  T? _readNullable<T>(dynamic readValue) {
    if (T is bool) {
      return readValue == -1 ? null : readValue as T;
    } else {
      return (readValue == false) ? null : readValue as T?;
    }
  }

  /// Serializes a nullable value. We can't directly store null values in Hive,
  /// so we use a special value to represent null. If the value is null, we
  /// return the special value. Otherwise, we return the value. If the value is
  /// the special value, we store it as the second special value.
  dynamic _serializeNullable<T>(T? value) {
    if (T is bool) {
      return (value == null) ? -1 : value;
    } else {
      return value ?? false;
    }
  }

// static const _nullValuePrimary = -1;
// static const _nullValueSecondary = -2;
}

Color? _parseColor(String? colorString) {
  if (colorString == null) {
    return null;
  }

  return Color(int.parse(colorString, radix: 16));
}

String? _serializeColor(Color? color) {
  if (color == null) {
    return null;
  }

  return color.value.toRadixString(16);
}
