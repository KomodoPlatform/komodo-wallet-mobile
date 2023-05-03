import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';

abstract class Account {
  final AccountId accountId;

  Account({required this.accountId});

  // Factory constructor to create an Account from JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    final accountIdJson = json['account_id'] as Map<String, dynamic>;
    final accountId = AccountId.fromJson(accountIdJson);

    switch (accountId.type) {
      case 'iguana':
        return IguanaAccount.fromJson(json);
      case 'hd':
        return HDAccount.fromJson(json);
      case 'hw':
        return HardwareAccount.fromJson(json);
      default:
        throw Exception('Unknown Account type');
    }
  }
}

class IguanaAccount extends Account {
  IguanaAccount({required IguanaAccountId accountId})
      : super(accountId: accountId);

  factory IguanaAccount.fromJson(Map<String, dynamic> json) {
    final accountId = AccountId.fromJson(json['account_id']);
    return IguanaAccount(accountId: accountId as IguanaAccountId);
  }
}

/// Represents a hierarchical-deterministic (HD) wallet account.
///
/// See: https://gemini.com/cryptopedia/hd-crypto-wallets-hierachichal-deterministic
class HDAccount extends Account {
  HDAccount({required HDAccountID accountId}) : super(accountId: accountId);

  factory HDAccount.fromJson(Map<String, dynamic> json) {
    final accountId = AccountId.fromJson(json['account_id']);
    return HDAccount(accountId: accountId as HDAccountID);
  }
}

class HardwareAccount extends Account {
  HardwareAccount({required HWAccountID accountId})
      : super(accountId: accountId);

  factory HardwareAccount.fromJson(Map<String, dynamic> json) {
    final accountId = AccountId.fromJson(json['account_id']);
    return HardwareAccount(accountId: accountId as HWAccountID);
  }
}
