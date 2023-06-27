import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:komodo_dex/packages/account_addresses/api/account_addresses_api_interface.dart';
import 'package:komodo_dex/packages/account_addresses/models/wallet_address.dart';

class AccountAddressesApiHive implements AccountAddressesApiInterface {
  Box<WalletAddress> _box;

  AccountAddressesApiHive() {
    Hive.registerAdapter(WalletAddressAdapter());
    Hive.openBox<WalletAddress>('account_addresses').then((box) => _box = box);
  }

  @override
  Future<void> create(WalletAddress walletAddress) async {
    await _box.put(
        '${walletAddress.walletId}_${walletAddress.address}', walletAddress);
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
      final updatedWalletAddress = WalletAddress(
        walletId: walletId,
        address: address,
        ticker: updateFields.ticker ?? existingWalletAddress.ticker,
        availableBalance: updateFields.availableBalance ??
            existingWalletAddress.availableBalance,
        accountId: updateFields.accountId ?? existingWalletAddress.accountId,
      );

      await _box.put(key, updatedWalletAddress);
    }
  }

  @override
  Future<void> deleteOne(String walletId, String address) async {
    await _box.delete('${walletId}_$address');
  }

  @override
  Future<void> deleteAll(String walletId) async {
    final keys = _box.keys.where((key) => key.startsWith(walletId));
    await _box.deleteAll(keys);
  }

  @override
  Future<WalletAddress> readOne(String walletId, String address) async {
    return _box.get('${walletId}_$address');
  }

  @override
  Future<List<WalletAddress>> readAll(String walletId) async {
    return _box.values
        .where((walletAddress) => walletAddress.walletId == walletId)
        .toList();
  }

  @override
  Stream<WalletAddress> watchAll(String walletId) {
    return _box
        .watch()
        .where((event) => event.key.startsWith(walletId))
        .map((event) => event.value);
  }
}
