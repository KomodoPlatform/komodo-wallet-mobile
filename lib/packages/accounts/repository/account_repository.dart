import 'package:hive/hive.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart' hide Account;
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'dart:async';

class AccountRepository {
  static const String _accountBoxName = 'accounts';

  Box<Account>? _accountBox;

  FutureOr<Box<Account>> _openAccountBox() async {
    if (_accountBox != null && _accountBox!.isOpen) {
      return _accountBox!;
    } else {
      _accountBox = await Hive.openBox<Account>(_accountBoxName);
      return _accountBox!;
    }
  }

  Stream<BoxEvent> _accountUpdatesStream() async* {
    final accountBox = await _openAccountBox();
    yield* accountBox.watch();
  }

  Stream<BoxEvent> accountUpdatesStreamByWalletId(String walletId) {
    return _accountUpdatesStream().transform(
      StreamTransformer.fromHandlers(
        handleData: (BoxEvent event, EventSink<BoxEvent> sink) {
          if (event.key.startsWith(walletId)) {
            sink.add(event);
          }
        },
      ),
    );
  }

  Future<void> storeAccount({
    required String walletId,
    required Account account,
  }) async {
    final accountBox = await _openAccountBox();
    await accountBox.put('${walletId}_${account.accountId}', account);
  }

  Future<Account?> getAccount({
    required String walletId,
    required AccountId accountId,
  }) async {
    final accountBox = await _openAccountBox();
    final account = accountBox.get('${walletId}_$accountId');
    return account;
  }

  // TODO: Look into using Hive's relations functionality to handle the
  // relationship between accounts and wallets instead of searching through
  // all accounts.
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
    await accountBox.delete('${walletId}_$accountId');
  }

  Future<void> dispose() async {
    if (_accountBox != null && _accountBox!.isOpen) {
      await _accountBox!.close();
    }
  }
}
