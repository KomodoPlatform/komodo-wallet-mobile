import 'package:komodo_dex/migration_manager/app_migration.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the migrations used to
final class MigrationManager {
  MigrationManager(this.migrations);

  final List<AppMigration> migrations;

  String get _completedMigrationsKey => 'completed_migrations';

  Future<bool> runAll() async {
    await _dryRun();

    final prefs = await SharedPreferences.getInstance();
    final completedMigrations =
        prefs.getStringList(_completedMigrationsKey) ?? [];

    for (final migration in migrations) {
      if (completedMigrations.contains(migration.key)) {
        // This migration has already been run.
        continue;
      }

      // Check if all dependencies have been run
      for (final dependency in migration.dependsOn) {
        final dependentMigration =
            migrations.firstWhere((m) => m.runtimeType == dependency);
        if (!completedMigrations.contains(dependentMigration.key) &&
            await dependentMigration.shouldMigrate()) {
          // If a dependent migration should be run and hasn't been run yet, throw an exception.
          throw Exception(
              'Migration ${migration.key} depends on ${dependentMigration.key} which has not yet run.');
        }
      }

      if (await migration.shouldMigrate()) {
        final success = await migration.run();
        if (success) {
          completedMigrations.add(migration.key);
          await prefs.setStringList(
              _completedMigrationsKey, completedMigrations);
        } else {
          // The migration failed.
          return false;
        }
      }
    }

    // All migrations completed successfully.
    return true;
  }

  Future<void> _dryRun() async {
    final prefs = await SharedPreferences.getInstance();
    final completedMigrations =
        prefs.getStringList(_completedMigrationsKey) ?? [];

    for (final migration in migrations) {
      if (completedMigrations.contains(migration.key)) {
        // This migration has already been run.
        continue;
      }

      // Check if all dependencies have been run
      for (final dependency in migration.dependsOn) {
        final dependentMigration =
            migrations.firstWhere((m) => m.runtimeType == dependency);
        if (!completedMigrations.contains(dependentMigration.key) &&
            await dependentMigration.shouldMigrate()) {
          // If a dependent migration should be run and hasn't been run yet, throw an exception.
          throw Exception(
              'Migration ${migration.key} depends on ${dependentMigration.key} which has not yet run.');
        }
      }

      if (await migration.shouldMigrate()) {
        completedMigrations.add(migration.key);
      }
    }
  }
}
