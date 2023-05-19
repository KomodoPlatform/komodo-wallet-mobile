import 'dart:async';

import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/accounts/repository/active_account_repository.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/wallets/repository/wallets_repository.dart';

import '../../model/wallet.dart';

class LegacyDatabaseAdapter {
  LegacyDatabaseAdapter._({
    required WalletsRepository walletsRepository,
    required AuthenticationRepository authenticationRepository,
    required ActiveAccountRepository activeAccountRepository,
  })  : _walletsRepository = walletsRepository,
        _authenticationRepository = authenticationRepository,
        _activeAccountRepository = activeAccountRepository;

  static Future<void> init({
    required WalletsRepository walletsRepository,
    required AuthenticationRepository authenticationRepository,
    required ActiveAccountRepository activeAccountRepository,
  }) async {
    // if (_instance != null) return _instance!;

    _instance = LegacyDatabaseAdapter._(
      walletsRepository: walletsRepository,
      authenticationRepository: authenticationRepository,
      activeAccountRepository: activeAccountRepository,
    );
  }

  static LegacyDatabaseAdapter? _instance;

  final AuthenticationRepository _authenticationRepository;
  final ActiveAccountRepository _activeAccountRepository;
  final WalletsRepository _walletsRepository;

  static LegacyDatabaseAdapter? get maybeInstance => _instance;

  Future<Wallet?> tryGetAuthenticatedWallet() async {
    Wallet? wallet;
    Account? account;

    final futures = <Future<void>>[
      Future(() async {
        // Gets the wallet in the new format
        wallet = (await _authenticationRepository.tryGetWallet())?.toLegacy();
      }),
      Future(() async {
        // Gets the account in the new format
        account = await _activeAccountRepository.tryGetActiveAccount();
      }),
    ];

    await Future.wait<void>(futures);

    if (wallet == null) return null;

    return account?.asLegacyWallet();
  }
}
