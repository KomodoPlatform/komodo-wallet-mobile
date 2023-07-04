import 'package:meta/meta.dart';
import 'package:komodo_dex/packages/account_addresses/models/wallet_address.dart';

abstract class AccountAddressesApiInterface {
  Future<void> create({
    @required String walletId,
    @required String address,
    @required String ticker,
    @required double availableBalance,
    @required String accountId,
  });

  Future<void> update({
    @required String walletId,
    @required String address,
    String ticker,
    double availableBalance,
    String accountId,
  });

  Future<void> updateOrCreate({
    @required String walletId,
    @required String address,
    @required String ticker,
    @required double availableBalance,
    @required String accountId,
  });

  Future<void> deleteOne({
    @required String walletId,
    @required String address,
  });

  Future<void> deleteAll({
    @required String walletId,
  });

  Future<WalletAddress> readOne({
    @required String walletId,
    @required String address,
  });

  Future<List<WalletAddress>> readAll({
    @required String walletId,
  });

  Stream<WalletAddress> watchAll({
    @required String walletId,
  });

  Stream<List<WalletAddress>> watchAllList({
    @required String walletId,
  });
}
