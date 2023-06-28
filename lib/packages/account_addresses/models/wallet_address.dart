import 'package:meta/meta.dart';
import 'package:hive/hive.dart';

part 'wallet_address.g.dart';

@HiveType(typeId: 0)
class WalletAddress {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String address;

  @HiveField(2)
  final String ticker;

  @HiveField(3)
  final double availableBalance;

  @HiveField(4)
  final String accountId;

  WalletAddress({
    @required this.walletId,
    @required this.address,
    @required this.ticker,
    @required this.availableBalance,
    @required this.accountId,
  });
}
