import 'package:komodo_dex/packages/wallets/models/wallet.dart';

/// An abstract interface for interacting with Wallet data storage.
///
/// Implementations of this interface should provide methods for storing,
/// retrieving, listing, and removing Wallet instances and their associated accounts.
abstract class WalletStorageApiInterface {
  /// Stores a Wallet instance.
  ///
  /// [wallet] is the Wallet instance to store.
  ///
  /// Overwrites an existing Wallet instance if the wallet ID already exists.
  Future<void> createWallet({
    required Wallet wallet,
    required String passphrase,
  });

  /// Retrieves a Wallet instance by its wallet ID.
  ///
  /// [walletId] is the ID of the wallet to retrieve.
  ///
  /// Returns a Wallet instance if found, null otherwise.
  Future<Wallet?> getWallet(String walletId);

  /// Retrieves a list of all Wallet instances.
  ///
  /// Returns a list of Wallet instances.
  Future<List<Wallet>> listWallets();

  /// Returns a stream of list of Wallet instances.
  ///
  /// This stream emits new lists whenever there are changes in the data storage.
  Stream<List<Wallet>> watchWallets();

  /// Removes a Wallet instance by its wallet ID.
  ///
  /// [walletId] is the ID of the wallet to remove.
  ///
  /// NB! This method does not remove the wallet passphrase from biometric
  /// storage or delete the wallet from the blockchain. This is purely for
  /// local persistence and account management.
  Future<void> removeWallet(String walletId);
}
