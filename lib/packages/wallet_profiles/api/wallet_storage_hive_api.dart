import 'package:hive/hive.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/wallet_profile_adapter.dart';
import 'package:komodo_dex/packages/wallet_profiles/models/wallet_profile.dart';

/// An abstract interface for interacting with WalletProfile data storage.
///
/// Implementations of this interface should provide methods for storing,
/// retrieving, listing, and removing WalletProfile instances.
abstract class WalletProfileApi {
  /// Stores a WalletProfile instance.
  ///
  /// [profile] is the WalletProfile instance to store.
  ///
  /// Overwrites an existing WalletProfile instance if the ID already exists.
  Future<void> storeWalletProfile(WalletProfile profile);

  /// Retrieves a WalletProfile instance by its ID.
  ///
  /// [walletId] is the ID of the wallet profile to retrieve.
  ///
  /// Returns a WalletProfile instance if found, null otherwise.
  Future<WalletProfile?> getWalletProfile(String walletId);

  /// Retrieves a list of all WalletProfile instances.
  ///
  /// Returns a list of WalletProfile instances.
  Future<List<WalletProfile>> listWalletProfiles();

  /// Returns a stream of list of WalletProfile instances.
  ///
  /// This stream emits new lists whenever there are changes in the data storage.
  Stream<List<WalletProfile>> watchWalletProfiles();

  /// Removes a WalletProfile instance by its ID.
  ///
  /// [walletId] is the ID of the wallet profile to remove.
  Future<void> removeWalletProfile(String walletId);
}

/// A class responsible for handling Hive storage operations for
/// wallet profiles. Implements [WalletProfileApi].
///
/// Example:
///
/// ```dart
/// Hive.registerAdapter(WalletProfileAdapter());
/// final hiveStorageApi = HiveStorageApi();
/// ```
class WalletProfileHiveApi implements WalletProfileApi {
  WalletProfileHiveApi._({required Box<WalletProfile> box}) : _box = box;

  static Future<WalletProfileHiveApi> create() async {
    Hive.registerAdapter(WalletProfileAdapter());
    final box = await Hive.openBox<WalletProfile>('wallet_profiles');
    return WalletProfileHiveApi._(box: box);
  }

  final Box<WalletProfile> _box;

  final String _walletProfilesBoxName = 'wallet_profiles';

  @override
  Future<void> storeWalletProfile(WalletProfile profile) async {
    final box = await Hive.openBox<WalletProfile>(_walletProfilesBoxName);
    await box.put(profile.id, profile);
  }

  @override
  Future<WalletProfile?> getWalletProfile(String walletId) async {
    return _box.get(walletId);
  }

  @override
  Future<List<WalletProfile>> listWalletProfiles() async {
    return _box.values.toList();
  }

  Stream<List<WalletProfile>> watchWalletProfiles() {
    return _box.watch().map((event) => _box.values.toList());
  }

  @override
  Future<void> removeWalletProfile(String walletId) async {
    await _box.delete(walletId);
  }
}
