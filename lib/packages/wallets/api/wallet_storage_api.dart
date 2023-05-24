import 'package:hive/hive.dart';
import 'package:komodo_dex/packages/authentication/repository/exceptions.dart';
import 'package:komodo_dex/packages/biometrics/api/biometric_storage_api.dart';
import 'package:komodo_dex/packages/wallets/api/wallets_api_interface.dart';
import 'package:komodo_dex/packages/accounts/models/account.dart';
import 'package:komodo_dex/packages/wallets/models/wallet.dart';
import 'package:komodo_dex/utils/iterable_utils.dart';

/// A class responsible for handling Hive storage operations for
/// wallet profiles. Implements [WalletProfileApiInterface].
///
/// Example:
///
/// ```dart
/// Hive.registerAdapter(WalletProfileAdapter());
/// final hiveStorageApi = HiveStorageApi();
/// ```
class WalletStorageApi implements WalletStorageApiInterface {
  WalletStorageApi._({
    required Box<Wallet> box,
    required BiometricStorageApi biometricStorageApi,
  })  : _box = box,
        _biometricStorageApi = biometricStorageApi;

  static Future<WalletStorageApi> create() async {
    Hive.registerAdapter<Wallet>(WalletAdapter());
    // await Hive.deleteBoxFromDisk(_walletProfilesBoxName);
    final box = await Hive.openBox<Wallet>(_walletProfilesBoxName);
    final biometricStorage = BiometricStorageApi(
      baseStorageKey: 'wallets_',
    );
    return WalletStorageApi._(box: box, biometricStorageApi: biometricStorage);
  }

  final Box<Wallet> _box;
  final BiometricStorageApi _biometricStorageApi;
  static const String _walletProfilesBoxName = 'wallets_';

  @override
  Future<void> createWallet({
    required Wallet wallet,
    required String passphrase,
  }) async {
    try {
      _ensureWalletDoesNotExist(wallet.walletId);

      await _box.put(wallet.walletId, wallet);

      // TODO! Integrate biometric storage as separate bloc
      // Store the passphrase in biometric storage
      await _biometricStorageApi.create(id: wallet.walletId, data: passphrase);
    } catch (e) {
      // Delete the profile if creation fails. Await future but ignore result
      _box.delete(wallet.walletId).ignore();
      _biometricStorageApi.delete(wallet.walletId).ignore();

      return Future.error(e);
    }
  }

  // TODO: Move to authentication bloc
  // @override
  Future<String?> getWalletPassphrase(String walletId) {
    _ensureWalletExists(walletId);
    try {
      return _biometricStorageApi.read(walletId);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Wallet> createWalletWithoutPassphrase({
    required Wallet wallet,
  }) async {
    try {
      _ensureWalletDoesNotExist(wallet.walletId);
      await _box.put(wallet.walletId, wallet);
      return wallet;
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<Wallet?> getWallet(String walletId) async {
    return _box.values.firstWhereOrNull((w) => w.walletId == walletId);
  }

  @override
  Future<List<Wallet>> listWallets() async {
    return _box.values.toList();
  }

  @override
  Stream<List<Wallet>> watchWallets() {
    return _box.watch().map((event) => _box.values.toList());
  }

  @override
  Future<void> removeWallet(String walletId) async {
    await _box.delete(walletId);
  }

  Future<bool> canBiometricAuthenticate() async {
    return _biometricStorageApi.canAuthenticate();
  }

  void _ensureWalletExists(String walletId) {
    if (!_box.containsKey(walletId)) {
      throw WalletNotFoundException();
    }
  }

  void _ensureWalletDoesNotExist(String walletId) {
    if (_box.containsKey(walletId)) {
      throw WalletAlreadyExistsException();
    }
  }
}
