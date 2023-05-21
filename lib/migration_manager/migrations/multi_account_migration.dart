import 'dart:async';

import 'package:komodo_dex/migration_manager/app_migration.dart';
import 'package:komodo_dex/services/db/legacy_db_adapter.dart';

final class MultiAccountMigration implements AppMigration {
  @override
  String get key => 'multi_account_migration_01';

  @override
  List<Type> get dependsOn => [];

  @override
  FutureOr<bool> shouldMigrate() async {
    return true;
  }

  @override
  Future<bool> run() async {
    try {
      await LegacyDatabaseAdapter.maybeInstance!.migrateLegacyWallets();

      return true;
    } catch (e) {
      return false;
    }
  }
}
