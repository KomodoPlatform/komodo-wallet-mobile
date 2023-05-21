import 'dart:async';

interface class AppMigration {
  String get key => throw UnimplementedError();

  /// List of keys of migrations which this migration depends on
  List<Type> get dependsOn => [];

  /// Tells the migration manager whether this migration should be executed.
  ///
  /// If the depencencies of this migration are not satisfied, [run] will not
  /// be called regardless of the return value of this method.
  ///
  /// Returns true if this migration should be ran. If another migration
  /// depends on this migration and this method returns true, this migration
  /// must be ran before the other migration.
  ///
  /// This method should be idempotent and not have any side effects.
  FutureOr<bool> shouldMigrate() => throw UnimplementedError();

  /// Runs the migration and returns true if it was successful.
  Future<bool> run() => throw UnimplementedError();
}
