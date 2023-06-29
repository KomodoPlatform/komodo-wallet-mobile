import 'dart:async';
import 'dart:convert';
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

  Stream<WalletAddress> watchCurrentWalletAddresses() async* {
    StreamController<WalletAddress> controller;
    StreamSubscription<WalletAddress> subscription;

    controller = StreamController<WalletAddress>(
      onListen: () async {
        String currentWalletId;

        while (controller.hasListener) {
          final currentWallet = await Db.getCurrentWallet();
          if (currentWallet != null && currentWallet.id != currentWalletId) {
            currentWalletId = currentWallet.id;

            // Emit the switched wallet information
            final String jsonStr = await Db.getWalletSnapshot();
            if (jsonStr != null) {
              List<dynamic> items;
              try {
                items = json.decode(jsonStr);
              } catch (e) {
                controller
                    .addError('Failed to decode getWalletSnapshot JSON: $e');
              }

              if (items != null) {
                for (final item in items) {
                  final coinBalance = CoinBalance.fromJson(item);

                  final walletAddress = WalletAddress(
                    walletId: currentWalletId,
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

                  controller.add(walletAddress);
                }
              }
            }

            // Listen and emit newer changes that will occur
            await subscription?.cancel();
            subscription = _accountAddressesApi
                .watchAll(walletId: currentWalletId)
                .listen((updatedAddress) {
              controller.add(updatedAddress);
            });
          }

          await Future.delayed(Duration(seconds: 5));
        }
      },
      onCancel: () async {
        await subscription?.cancel();
      },
    );

    yield* controller.stream;
  }
}
