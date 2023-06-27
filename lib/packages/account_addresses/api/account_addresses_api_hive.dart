import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:komodo_dex/packages/account_addresses/api/account_addresses_api_interface.dart';
import 'package:komodo_dex/packages/account_addresses/models/wallet_address.dart';

class HiveException implements Exception {
  final String message;
  final Exception originalException;

  HiveException(this.message, [this.originalException]);

  @override
  String toString() => 'HiveException: $message';
}

class AccountAddressesApiHive implements AccountAddressesApiInterface {
  final Box<WalletAddress> _box;

  AccountAddressesApiHive._(this._box);

  static FutureOr<AccountAddressesApiHive> initialize() async {
    Hive.registerAdapter(WalletAddressAdapter());
    Box<WalletAddress> box;
    try {
      box = await Hive.openBox<WalletAddress>('account_addresses');
    } catch (e) {
      throw HiveException('Failed to open Hive box: $e', e);
    }
    return AccountAddressesApiHive._(box);
  }

  String _getKey(String walletId, String address) {
    return '${walletId}_$address';
  }

  @override
  Future<void> create(String walletId, String address, String ticker,
      double availableBalance, String accountId) async {
    _validateFields(walletId, address, availableBalance);
    try {
      await _box.put(
          _getKey(walletId, address),
          WalletAddress(
              walletId: walletId,
              address: address,
              ticker: ticker,
              availableBalance: availableBalance,
              accountId: accountId));
    } catch (e) {
      throw HiveException('Failed to create WalletAddress: $e', e);
    }
  }

  @override
  Future<void> updateOrCreate(String walletId, String address, String ticker,
      double availableBalance, String accountId) async {
    final key = _getKey(walletId, address);
    if (_box.containsKey(key)) {
      await update(walletId, address,
          ticker: ticker,
          availableBalance: availableBalance,
          accountId: accountId);
    } else {
      await create(walletId, address, ticker, availableBalance, accountId);
    }
  }

  @override
  Future<void> update(String walletId, String address,
      {String ticker, double availableBalance, String accountId}) async {
    _validateFields(walletId, address, availableBalance);
    final key = _getKey(walletId, address);
    final existingWalletAddress = _box.get(key);

    if (existingWalletAddress == null) {
      throw Exception('WalletAddress not found');
    }

    final updatedWalletAddress = WalletAddress(
      walletId: walletId,
      address: address,
      ticker: ticker ?? existingWalletAddress.ticker,
      availableBalance:
          availableBalance ?? existingWalletAddress.availableBalance,
      accountId: accountId ?? existingWalletAddress.accountId,
    );

    try {
      await _box.put(key, updatedWalletAddress);
    } catch (e) {
      throw HiveException('Failed to update WalletAddress: $e', e);
    }
  }

  @override
  Future<void> deleteOne(String walletId, String address) async {
    try {
      await _box.delete(_getKey(walletId, address));
    } catch (e) {
      throw HiveException('Failed to delete WalletAddress: $e', e);
    }
  }

  @override
  Future<void> deleteAll(String walletId) async {
    final keys = _box.keys.where((key) => key.startsWith(walletId));
    try {
      await _box.deleteAll(keys);
    } catch (e) {
      throw HiveException('Failed to delete WalletAddresses: $e', e);
    }
  }

  @override
  Future<WalletAddress> readOne(String walletId, String address) async {
    try {
      return _box.get(_getKey(walletId, address));
    } catch (e) {
      throw HiveException('Failed to read WalletAddress: $e', e);
    }
  }

  @override
  Future<List<WalletAddress>> readAll(String walletId) async {
    try {
      return _box.values
          .where((walletAddress) => walletAddress.walletId == walletId)
          .toList();
    } catch (e) {
      throw HiveException('Failed to read WalletAddresses: $e', e);
    }
  }

  @override
  Stream<WalletAddress> watchAll(String walletId) {
    return _box
        .watch()
        .where((event) =>
            event.key.startsWith(walletId) && event.value is WalletAddress)
        .map((event) => event.value as WalletAddress);
  }

  Future<void> close() async {
    try {
      await _box.close();
    } catch (e) {
      throw HiveException('Failed to close Hive box: $e', e);
    }
  }

  void _validateFields(
      String walletId, String address, double availableBalance) {
    if (walletId == null || walletId.isEmpty) {
      throw ArgumentError('Wallet ID must not be empty');
    }
    if (address == null || address.isEmpty) {
      throw ArgumentError('Address must not be empty');
    }
    if (availableBalance == null || availableBalance < 0) {
      throw ArgumentError('Available balance must be non-negative');
    }
  }
}
