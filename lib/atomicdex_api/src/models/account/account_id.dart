import 'package:uuid/uuid.dart';

abstract class AccountId {
  AccountId({required this.type});

  Map<String, dynamic> toJson();

  final String type;

  // Factory constructor to create an AccountID from JSON
  factory AccountId.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'iguana':
        return IguanaAccountId();
      case 'hd':
        return HDAccountID(hdId: json['account_id']);
      case 'hw':
        return HWAccountID(devicePubkey: json['device_pubkey']);
      default:
        throw Exception('Unknown AccountID type');
    }
  }

  //TODO:
  // String get uuid;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

class IguanaAccountId extends AccountId {
  IguanaAccountId() : super(type: 'iguana');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }

  //TODO:
  // @override
  // String get uuid {
  //   final uuid = Uuid();
  //   final namespace =
  //       Uuid.NAMESPACE_OID; // Use a fixed namespace for deterministic UUIDs
  //   return uuid.v4(UuidUtil .cryptoRNG)
  // }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IguanaAccountId && runtimeType == other.runtimeType);
  }

  @override
  int get hashCode => type.hashCode;
}

class HDAccountID extends AccountId {
  final int hdId;

  HDAccountID({required this.hdId}) : super(type: 'hd');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'account_id': hdId,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HDAccountID &&
            runtimeType == other.runtimeType &&
            hdId == other.hdId);
  }

  @override
  int get hashCode => type.hashCode ^ hdId.hashCode;
}

class HWAccountID extends AccountId {
  final String devicePubkey;

  HWAccountID({required this.devicePubkey}) : super(type: 'hw');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'device_pubkey': devicePubkey,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HWAccountID &&
            runtimeType == other.runtimeType &&
            devicePubkey == other.devicePubkey);
  }

  @override
  int get hashCode => type.hashCode ^ devicePubkey.hashCode;
}
