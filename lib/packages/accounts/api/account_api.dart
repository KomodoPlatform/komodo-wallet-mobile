import 'dart:typed_data';
import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart' hide Account;
import 'package:komodo_dex/atomicdex_api/src/exceptions.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'dart:async';

class AccountApi {
  AccountApi() {
    Hive.registerAdapter(AccountAdapter(), override: true);
  }
  static const String _accountBoxName = 'accounts';

  Box<Account>? _accountBox;

  FutureOr<Box<Account>> _openAccountBox() async {
    if (_accountBox != null && _accountBox!.isOpen) {
      return _accountBox!;
    } else {
      _accountBox = await Hive.openBox<Account>(_accountBoxName);
      // await _accountBox!.deleteFromDisk();
      return _accountBox!;
    }
  }

  static String _generateBoxKey(String walletId, AccountId accountId) {
    return '${walletId}_${accountId.toJson().toString()}';
  }

  Stream<List<Account>> accountsStream(String walletId) async* {
    final accountBox = await _openAccountBox();

    final initialAccounts = await getAccountsByWalletId(walletId);

    yield initialAccounts;

    yield* accountBox.watch().asyncMap((event) async {
      final accounts = await getAccountsByWalletId(walletId);

      return accounts;
    });
  }

  Future<Account> createAccount<T extends AccountId>({
    required String walletId,
    required String name,
    String? description,
    Color? themeColor,
    Uint8List? avatar,
  }) async {
    final newAccountId = await getNewAccountId<T>(walletId);

    final account = Account(
      walletId: walletId,
      accountId: newAccountId,
      name: name,
      description: description,
      themeColor: themeColor,
      avatar: avatar,
    );

    await storeAccount(walletId: walletId, account: account);

    return account;
  }

  Future<void> storeAccount({
    required String walletId,
    required Account account,
  }) async {
    final accountBox = await _openAccountBox();
    await accountBox.put(_generateBoxKey(walletId, account.accountId), account);
  }

  // TODO: Move to A-Dex API pakcage
  Future<T> getNewAccountId<T extends AccountId>(String walletId) async {
    // Beware that the function will return the same ID if called again before
    // a new account is created with the returned ID.

    if (T == HWAccountID)
      throw UnimplementedError('No hardware wallet support yet.');

    final List<Account> accounts = await getAccountsByWalletId(walletId);

    if (T == IguanaAccountId) {
      // Each wallet can only have one Iguana account.
      final hasIguanaAccount =
          accounts.any((account) => account.accountId is IguanaAccountId);

      return hasIguanaAccount
          ? throw AccountExistsAlreadyException()
          : IguanaAccountId() as T;
    }

    final hdIds =
        accounts.map((account) => account.accountId).whereType<HDAccountId>();

    // Get the highest hdId
    final hdId = hdIds.isEmpty
        ? 0
        : hdIds.reduce((a, b) => a.hdId > b.hdId ? a : b).hdId;

    final newHdId = hdId + 1;

    return HDAccountId(hdId: newHdId) as T;
  }

  Future<Account?> getAccount({
    required String walletId,
    required AccountId accountId,
  }) async {
    final accountBox = await _openAccountBox();
    final account = accountBox.get(_generateBoxKey(walletId, accountId));
    return account;
  }

  Future<List<Account>> getAccountsByWalletId(String walletId) async {
    final accountBox = await _openAccountBox();
    final accounts = accountBox.values
        .where((account) => accountBox
            .keyAt(accountBox.values.toList().indexOf(account))
            .startsWith(walletId))
        .toList();
    return accounts;
  }

  Future<void> deleteAccount(String walletId, AccountId accountId) async {
    final accountBox = await _openAccountBox();
    await accountBox.delete(_generateBoxKey(walletId, accountId));
  }

  Future<void> dispose() async {
    if (_accountBox != null && _accountBox!.isOpen) {
      await _accountBox!.close();
    }
  }
}
