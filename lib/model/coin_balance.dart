import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';

class CoinBalance {
  Coin coin;
  Balance balance;
  double balanceUSD;
  double priceForOne;

  CoinBalance(this.coin, this.balance);

  String getBalanceUSD() {
    return balanceUSD.toStringAsFixed(2);
  }
}
