import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';

class CoinBalance {
  CoinBalance(this.coin, this.balance);

  Coin coin;
  Balance balance;
  double balanceUSD;
  String priceForOne;

  String getBalanceUSD() {
    return balanceUSD.toStringAsFixed(2);
  }
}
