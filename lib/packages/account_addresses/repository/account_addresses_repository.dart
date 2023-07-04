import 'dart:async';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/packages/account_addresses/api/account_addresses_api_interface.dart';
import 'package:komodo_dex/packages/account_addresses/models/wallet_address.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:meta/meta.dart';

class AccountAddressesRepository {
  final AccountAddressesApiInterface _accountAddressesApi;

  AccountAddressesRepository({
    @required AccountAddressesApiInterface accountAddressesApi,
  }) : _accountAddressesApi = accountAddressesApi;

  Future<void> clearAll(String walletId) async {
    await _accountAddressesApi.deleteAll(walletId: walletId);
  }

  Future<void> storeSnapshot({
    @required List<Map<String, dynamic>> snapshotListJson,
    @required String walletId,
  }) async {
    if (snapshotListJson == null) return;

    for (final item in snapshotListJson ?? []) {
      final coinBalance = CoinBalance.fromJson(item);

      final walletAddress = WalletAddress(
        walletId: walletId,
        address: coinBalance.balance.address,
        ticker: coinBalance.coin.abbr,
        availableBalance: coinBalance.balance.balance.toDouble(),
        accountId: 'iguana',
      );

      await _accountAddressesApi.updateOrCreate(
        walletId: walletAddress.walletId,
        address: walletAddress.address,
        ticker: walletAddress.ticker,
        availableBalance: walletAddress.availableBalance,
        accountId: walletAddress.accountId,
      );
    }
  }

  /// Returns a stream of all addresses for the current wallet.
  ///
  /// The stream emits all initial addresses for the current wallet, and then
  /// watches for updated/created addresses for the current wallet.
  ///
  /// The stream will switch to a new stream when the current wallet changes.
  ///
  Stream<WalletAddress> watchCurrentWalletAddresses() async* {
    String lastStreamWalletId;

    final didWalletChange = (wallet) =>
        wallet != null &&
        (wallet.id != lastStreamWalletId || lastStreamWalletId == null);

    await for (final wallet in Db.watchCurrentWallet().where(didWalletChange)) {
      lastStreamWalletId = wallet.id;

      for (final address in await _accountAddressesApi.readAll(
        walletId: lastStreamWalletId,
      )) {
        yield address;
      }

      final addressesStream = _accountAddressesApi
          .watchAll(
            walletId: lastStreamWalletId,
          )
          .takeWhile((address) => address.walletId == lastStreamWalletId);

      await for (final address in addressesStream) {
        yield address;

        if (address.walletId != (await Db.getCurrentWallet())?.id) {
          break;
        }
      }
    }
  }
}
