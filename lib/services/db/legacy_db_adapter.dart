import 'dart:async';

import 'package:komodo_dex/atomicdex_api/atomicdex_api.dart';
import 'package:komodo_dex/packages/accounts/api/account_api.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/accounts/repository/account_repository.dart';
import 'package:komodo_dex/packages/accounts/repository/active_account_repository.dart';
import 'package:komodo_dex/packages/authentication/repository/authentication_repository.dart';
import 'package:komodo_dex/packages/wallets/repository/wallets_repository.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/wallet.dart' as legacy;

class LegacyDatabaseAdapter {
  LegacyDatabaseAdapter._({
    required WalletsRepository walletsRepository,
    required AuthenticationRepository authenticationRepository,
    required ActiveAccountRepository activeAccountRepository,
    required AccountRepository accountRepository,
  })  : _walletsRepository = walletsRepository,
        _accountRepository = accountRepository,
        _activeAccountRepository = activeAccountRepository,
        _authenticationRepository = authenticationRepository;

  static Future<void> init({
    required WalletsRepository walletsRepository,
    required AuthenticationRepository authenticationRepository,
    required ActiveAccountRepository activeAccountRepository,
    required AccountRepository accountRepository,
  }) async {
    assert(_instance == null);
    if (_instance != null) return;

    _instance = LegacyDatabaseAdapter._(
      walletsRepository: walletsRepository,
      authenticationRepository: authenticationRepository,
      activeAccountRepository: activeAccountRepository,
      accountRepository: accountRepository,
    );
  }

  static LegacyDatabaseAdapter? _instance;

  final AuthenticationRepository _authenticationRepository;
  final ActiveAccountRepository _activeAccountRepository;
  final AccountRepository _accountRepository;
  final WalletsRepository _walletsRepository;
  final AccountApi _accountApi = AccountApi();

  static LegacyDatabaseAdapter? get maybeInstance => _instance;

  Future<legacy.Wallet?> tryGetAuthenticatedWallet() async {
    var wallet = await getAuthenticatedWallet();
    var account = await getActiveAccount();

    return account?.asLegacyWallet();
  }

  Future<legacy.Wallet?> getAuthenticatedWallet() async {
    return (await _authenticationRepository.tryGetWallet())?.toLegacy();
  }

  Future<Account?> getActiveAccount() async {
    return await _activeAccountRepository.tryGetActiveAccount();
  }

  Future<List<legacy.Wallet>> listWallets() async {
    final wallets = await _walletsRepository.listWallets();

    return wallets.map((w) => w.toLegacy()).toList();
  }

  /// Migrate legacy wallets to the new storage format for multi-account
  /// support.
  ///
  /// Each legacy wallet which does not already exist in the new
  /// format will be migrated by creating a new-format wallet with a single
  /// Iguana account.
  ///
  /// After migration, the legacy wallet is deleted from SQLite.
  Future<void> migrateLegacyWallets() async {
    var legacyWallets = await getLegacyStoredWallets();
    var wallets = await _walletsRepository.listWallets();

    final nonMigratedWallets = getNonMigratedWallets(legacyWallets, wallets);
    logWalletMigration(nonMigratedWallets);

    for (final wallet in nonMigratedWallets) {
      await migrateWallet(wallet);
    }
  }

  Future<List<legacy.Wallet>> getLegacyStoredWallets() async {
    final Database db = await Db.db;
    final List<Map<String, dynamic>> walletsJson = await db.query('Wallet');

    Log('LegacyDatabaseAdapter:getLegacyStoredWallets', walletsJson.length);
    return walletsJson
        .map((e) => legacy.Wallet(id: e['id'], name: e['name']))
        .toList();
  }

  List<Wallet> getNonMigratedWallets(
      List<legacy.Wallet> legacyWallets, List<Wallet> wallets) {
    return legacyWallets
        .where((legacyWallet) => !walletExistsInWallets(legacyWallet, wallets))
        .map((w) => Wallet(
            name: w.name ?? 'My wallet', walletId: w.id!, description: ''))
        .toList();
  }

  bool walletExistsInWallets(legacy.Wallet legacyWallet, List<Wallet> wallets) {
    assert(legacyWallet.id != null);
    return wallets.any((wallet) => wallet.walletId == legacyWallet.id);
  }

  void logWalletMigration(List<Wallet> nonMigratedWallets) {
    bool needsToMigrateWallets = nonMigratedWallets.isNotEmpty;

    Log(
      'LegacyDatabaseAdapter:migrateLegacyWallets',
      needsToMigrateWallets
          ? 'Migrating ${nonMigratedWallets.length} '
              'legacy wallets to new storage format.'
          : 'No legacy wallets to migrate.',
    );
  }

  Future<void> migrateWallet(Wallet wallet) async {
    try {
      await createNewWallet(wallet);
      await deleteLegacyWallet(wallet);
    } catch (e) {
      revertWalletMigrationOnError(wallet, e);
    }
  }

  Future<void> createNewWallet(Wallet wallet) async {
    await _walletsRepository.createWalletWithoutPassphrase(wallet: wallet);

    final walletAccounts =
        await _accountApi.getAccountsByWalletId(wallet.walletId);

    if (walletAccounts.isEmpty) {
      await _accountApi.createAccount<IguanaAccountId>(
        walletId: wallet.walletId,
        // TODO: Localize
        name: 'Default account',
      );
    }
  }

  Future<void> deleteLegacyWallet(Wallet wallet) async {
    await Db.sqlDbInstance.delete(
      'Wallet',
      where: 'id = ?',
      whereArgs: [wallet.walletId],
    );
  }

  void revertWalletMigrationOnError(Wallet wallet, dynamic error) {
    _accountApi.deleteAccount(wallet.walletId, IguanaAccountId()).ignore();

    _walletsRepository.removeWallet(wallet.walletId).ignore();

    Db.sqlDbInstance
        .insert(
          'Wallet',
          {'id': wallet.walletId, 'name': wallet.name},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        )
        .ignore();

    Log(
      'LegacyDatabaseAdapter:migrateLegacyWallets',
      'Failed to migrate wallet: $error',
    );
  }
}
