import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart' hide Account;
import 'package:komodo_dex/packages/accounts/api/account_api.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';

class AccountRepository {
  final AccountApi _accountApi;
  final AuthenticationRepository _authenticationRepository;

  AccountRepository({
    // required AccountApi accountApi,
    required AuthenticationRepository authenticationRepository,
  })  : _accountApi = AccountApi(),
        _authenticationRepository = authenticationRepository;

  /// Returns a stream of accounts for the currently authenticated user.
  Stream<List<Account>> accountsStream() async* {
    final wallet = await _authenticationRepository.tryGetWallet();

    if (wallet != null) {
      final walletId = wallet.walletId;
      yield await _accountApi.getAccountsByWalletId(walletId);
    }

    // Listen to changes in auth user to either close the stream or
    // update the walletId.
    await for (AuthenticationStatus status
        in _authenticationRepository.status) {
      if (status == AuthenticationStatus.authenticated) {
        final walletId = await _getAuthenticatedWalletId();
        yield* _accountApi.accountsStream(walletId);
      } else {
        // // Close the stream when unauthenticated or status is unknown.
        // // You can modify this behavior as needed.
        // break;
        yield [];
        break;
      }
    }
  }

  Future<Account> createAccount<T extends AccountId>({
    required String name,
    String? description,
    Color? themeColor,
    Uint8List? avatar,
  }) async {
    final walletId = await _getAuthenticatedWalletId();

    return _accountApi.createAccount<HDAccountId>(
      walletId: walletId,
      name: name,
      description: description,
      themeColor: themeColor,
      avatar: avatar,
    );
  }

  Future<Account> updateAccount({
    required AccountId accountId,
    required String name,
    String? description,
    Color? themeColor,
    Uint8List? avatar,
  }) async {
    final walletId = await _getAuthenticatedWalletId();

    return _accountApi.updateAccount(
      currentWalletId: walletId,
      account: Account(
        walletId: walletId,
        accountId: accountId,
        name: name,
        description: description,
        themeColor: themeColor,
        avatar: avatar,
      ),
    );
  }

  Future<Account?> getAccount({required AccountId accountId}) async {
    final walletId = await _getAuthenticatedWalletId();

    return await _accountApi.getAccount(
        walletId: walletId, accountId: accountId);
  }

  Future<List<Account>> getAuthUserAccounts() async {
    final walletId = await _getAuthenticatedWalletId();

    return await _accountApi.getAccountsByWalletId(walletId);
  }

  Future<void> deleteAccount(AccountId accountId) async {
    final walletId = await _getAuthenticatedWalletId();

    await _accountApi.deleteAccount(walletId, accountId);
  }

  Future<void> dispose() async {
    await _accountApi.dispose();
  }

  Future<String> _getAuthenticatedWalletId() async {
    final wallet = await _authenticationRepository.tryGetWallet();
    if (wallet == null) {
      throw Exception('Failed to get authenticated wallet.');
    }
    return wallet.walletId;
  }
}
