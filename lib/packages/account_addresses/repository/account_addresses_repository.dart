import 'dart:async';
import 'dart:convert';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/packages/account_addresses/api/account_addresses_api_interface.dart';
import 'package:komodo_dex/packages/account_addresses/models/wallet_address.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:meta/meta.dart';

class AccountAddressesRepository {
  final AccountAddressesApiInterface _accountAddressesApi;
  String _currentWalletId;
  StreamController<WalletAddress> _controller;
  StreamSubscription<WalletAddress> _watchSubscription;
  bool _isDisposed = false;

  AccountAddressesRepository({
    @required AccountAddressesApiInterface accountAddressesApi,
  }) : _accountAddressesApi = accountAddressesApi {
    _controller = StreamController<WalletAddress>();
    _startPolling();
  }

  Future<void> _startPolling() async {
    while (!_isDisposed) {
      try {
        final currentWallet = await Db.getCurrentWallet();
        if (currentWallet != null && currentWallet.id != _currentWalletId) {
          _currentWalletId = currentWallet.id;

          _watchSubscription?.cancel();
          _watchSubscription = _accountAddressesApi
              .watchAll(walletId: _currentWalletId)
              .listen((WalletAddress walletAddress) async {
            _controller.add(walletAddress);
          });

          final String jsonStr = await Db.getWalletSnapshot();
          if (jsonStr != null) {
            List<dynamic> items;
            try {
              items = json.decode(jsonStr);
            } catch (e) {
              throw Exception('Failed to decode getWalletSnapshot JSON: $e');
            }

            if (items != null) {
              for (final item in items) {
                final coinBalance = CoinBalance.fromJson(item);

                final walletAddress = WalletAddress(
                  walletId: _currentWalletId,
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
          }
        }
      } catch (e) {
        _controller.addError(e);
      }

      await Future.delayed(Duration(seconds: 5));
    }
  }

  Stream<WalletAddress> watchCurrentWalletAddresses() async* {
    yield* _controller.stream;
  }

  void dispose() {
    _isDisposed = true;
    _watchSubscription?.cancel();
    _controller.close();
  }
}
