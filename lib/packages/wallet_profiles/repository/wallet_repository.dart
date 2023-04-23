import 'package:hive/hive.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/biometric_storage_api.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/wallet_profile_adapter.dart';
import 'package:komodo_dex/packages/wallet_profiles/api/wallet_storage_hive_api.dart';
import 'package:komodo_dex/packages/wallet_profiles/models/wallet_profile.dart';

/// A class responsible for managing wallet-related data.
///
/// The WalletRepository class uses BiometricStorageApi and WalletProfileHiveApi
/// to interact with biometric storage and Hive storage, respectively.
///
/// Example:
///
/// ```dart
/// final biometricStorage = BiometricStorage();
/// final biometricStorageApi = BiometricStorageApi(biometricStorage: biometricStorage);
/// final walletProfileHiveApi = WalletProfileHiveApi();
/// final walletRepository = WalletRepository(biometricStorageApi: biometricStorageApi, walletProfileHiveApi: walletProfileHiveApi);
/// ```
class WalletRepository {
  final WalletProfileHiveApi _walletProfileHiveApi;

  WalletRepository({
    // required BiometricStorageApi biometricStorageApi,
    required WalletProfileHiveApi walletProfileHiveApi,
  }) :
        //  _biometricStorageApi = biometricStorageApi,
        _walletProfileHiveApi = walletProfileHiveApi;

  /// Creates a WalletRepository instance.
  ///
  /// Convenience method for default WalletRepository constructor.
  /// handling all the necessary initialization of dependencies.
  ///
  /// Initialize using the default constructor if you want to inject your own
  /// instances of the dependencies.
  static Future<WalletRepository> create() async {
    // Initialize BiometricStorageApi

    // Initialize WalletProfileHiveApi
    final walletProfileHiveApi = await WalletProfileHiveApi.create();

    // Initialize WalletRepository
    return WalletRepository(
      walletProfileHiveApi: walletProfileHiveApi,
    );
  }

  Future<void> storeWalletProfile(WalletProfile profile) async {
    await _walletProfileHiveApi.storeWalletProfile(profile);
  }

  Future<WalletProfile?> getWalletProfile(String walletId) async {
    return await _walletProfileHiveApi.getWalletProfile(walletId);
  }

  Future<List<WalletProfile>> listWalletProfiles() async {
    return await _walletProfileHiveApi.listWalletProfiles();
  }

  /// Removes a WalletProfile instance from the list of wallet profiles.
  ///
  /// NB: This method does not remove the wallet passphrase from biometric
  /// storage or delete the wallet from the blockchain.
  Future<void> removeWalletProfile(String walletId) async {
    await _walletProfileHiveApi.removeWalletProfile(walletId);
  }
}
