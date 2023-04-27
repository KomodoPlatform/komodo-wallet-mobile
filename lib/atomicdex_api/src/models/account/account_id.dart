abstract class AccountID {
  final String type;

  AccountID({required this.type});

  Map<String, dynamic> toJson();

  // Factory constructor to create an AccountID from JSON
  factory AccountID.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'iguana':
        return IguanaAccountID();
      case 'hd':
        return HDAccountID(accountIdx: json['account_idx']);
      case 'hw':
        return HWAccountID(devicePubkey: json['device_pubkey']);
      default:
        throw Exception('Unknown AccountID type');
    }
  }

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

class IguanaAccountID extends AccountID {
  IguanaAccountID() : super(type: 'iguana');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is IguanaAccountID && runtimeType == other.runtimeType);
  }

  @override
  int get hashCode => type.hashCode;
}

class HDAccountID extends AccountID {
  final int accountIdx;

  HDAccountID({required this.accountIdx}) : super(type: 'hd');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'account_idx': accountIdx,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HDAccountID &&
            runtimeType == other.runtimeType &&
            accountIdx == other.accountIdx);
  }

  @override
  int get hashCode => type.hashCode ^ accountIdx.hashCode;
}

class HWAccountID extends AccountID {
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
