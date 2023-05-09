import 'dart:async';
import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart'
    hide Account; // TODO: Figure out how to structure so not needed
import 'package:komodo_dex/atomicdex_api/src/models/account/account_id.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/accounts/repository/account_repository.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/wallets/api/wallet_storage_api.dart';
import 'package:komodo_dex/services/mm_service.dart';

class ActiveAccountRepository {
  ActiveAccountRepository({
    required AccountRepository accountRepository,
    required AuthenticationRepository authenticationRepository,
    // required WalletStorageApi walletStorageApi,
    required AtomicDexApi atomicDexApi,
  })  : _accountRepository = accountRepository,
        _authenticationRepository = authenticationRepository,
        // _walletStorageApi = walletStorageApi,
        _atomicDexApi = atomicDexApi;

  final AccountRepository _accountRepository;
  final AuthenticationRepository _authenticationRepository;
  // final WalletStorageApi _walletStorageApi;
  final AtomicDexApi _atomicDexApi;

  AccountId? _activeAccountId;

  Stream<Account?> get activeAccountStream async* {
    await for (final status in _authenticationRepository.status) {
      if (status == AuthenticationStatus.authenticated) {
        yield await tryGetActiveAccount();
      } else {
        yield null;
      }
    }
  }

  Future<void> setActiveAccount(AccountId accountId) async {
    final wallet = await _authenticationRepository.tryGetWallet();
    if (wallet == null) {
      throw Exception('Failed to get authenticated wallet.');
    }

    // Clear the passphrase from memory as soon as possible.
    String? passphrase;

    try {
      passphrase =
          await _authenticationRepository.getWalletPassphrase(wallet.walletId);

      if (passphrase == null) {
        throw Exception('Failed to get wallet passphrase.');
      }

      await _atomicDexApi.startSession(
          passphrase: passphrase, accountId: accountId);

      // TODO! Figure out which part of the pre-refactored code need to be
      // called to initialise them.

      _activeAccountId = accountId;
    } catch (e) {
      rethrow;
    } finally {
      // Clear the passphrase from memory as soon as possible.
      passphrase = null;
    }
  }

  Future<Account?> tryGetActiveAccount() async {
    final wallet = await _authenticationRepository.tryGetWallet();
    if (wallet != null && _activeAccountId != null) {
      return await _accountRepository.getAccount(accountId: _activeAccountId!);
    }
    return null;
  }

  Future<void> clearActiveAccount() async {
    _activeAccountId = null;

    await _atomicDexApi.endSession();

    // TODO: Handle any other cleanup that needs to happen for legacy code.
  }

  Future<bool> canChangeActiveAccount() async {
    // Placeholder logic, will be updated later
    return true;
  }

  Future<AccountId> _getActiveAccountId() async {
    if (_activeAccountId == null) {
      throw Exception('No active account set.');
    }
    return _activeAccountId!;
  }
}
