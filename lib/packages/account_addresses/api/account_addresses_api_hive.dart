import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:komodo_dex/packages/account_addresses/api/account_addresses_api_interface.dart';
import 'package:komodo_dex/packages/account_addresses/models/wallet_address.dart';

class AccountAddressesApiHive implements AccountAddressesApiInterface {
  Box<WalletAddress> _box;

  AccountAddressesApiHive() {
    Hive.registerAdapter(WalletAddressAdapter());
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox<WalletAddress>('account_addresses');
    } catch (e) {
      throw 'Failed to open Hive box: $e';
    }
  }

  @override
  Future<void> create(WalletAddress walletAddress) async {
    _validateWalletAddress(walletAddress);
    try {
      await _box.put(
          '${walletAddress.walletId}_${walletAddress.address}', walletAddress);
    } catch (e) {
      throw 'Failed to create WalletAddress: $e';
    }
  }

  @override
  Future<void> update(String walletId, String address,
      {WalletAddress updateFields}) async {
    final key = '${walletId}_$address';
    final existingWalletAddress = _box.get(key);

    if (existingWalletAddress == null) {
      throw Exception('WalletAddress not found');
    }

    if (updateFields != null) {
      _validateWalletAddress(updateFields);

      final updatedWalletAddress = WalletAddress(
        walletId: walletId,
        address: address,
        ticker: updateFields.ticker ?? existingWalletAddress.ticker,
        availableBalance: updateFields.availableBalance ??
            existingWalletAddress.availableBalance,
        accountId: updateFields.accountId ?? existingWalletAddress.accountId,
      );

      try {
        await _box.put(key, updatedWalletAddress);
      } catch (e) {
        throw 'Failed to update WalletAddress: $e';
      }
    }
  }

  @override
  Future<void> deleteOne(String walletId, String address) async {
    try {
      await _box.delete('${walletId}_$address');
    } catch (e) {
      throw 'Failed to delete WalletAddress: $e';
    }
  }

  @override
  Future<void> deleteAll(String walletId) async {
    final keys = _box.keys.where((key) => key.startsWith(walletId));
    try {
      await _box.deleteAll(keys);
    } catch (e) {
      throw 'Failed to delete WalletAddresses: $e';
    }
  }

  @override
  Future<WalletAddress> readOne(String walletId, String address) async {
    try {
      return _box.get('${walletId}_$address');
    } catch (e) {
      throw 'Failed to read WalletAddress: $e';
    }
  }

  @override
  Future<List<WalletAddress>> readAll(String walletId) async {
    try {
      return _box.values
          .where((walletAddress) => walletAddress.walletId == walletId)
          .toList();
    } catch (e) {
      throw 'Failed to read WalletAddresses: $e';
    }
  }

  @override
  Stream<WalletAddress> watchAll(String walletId) {
    return _box
        .watch()
        .where((event) => event.key.startsWith(walletId))
        .map((event) => event.value);
  }

  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      throw 'Failed to close Hive box: $e';
    }
  }

  void _validateWalletAddress(WalletAddress walletAddress) {
    if (walletAddress.walletId == null || walletAddress.walletId.isEmpty) {
      throw ArgumentError('Wallet ID must not be empty');
    }
    if (walletAddress.address == null || walletAddress.address.isEmpty) {
      throw ArgumentError('Address must not be empty');
    }
    if (walletAddress.availableBalance == null ||
        walletAddress.availableBalance < 0) {
      throw ArgumentError('Available balance must be non-negative');
    }
  }
}
