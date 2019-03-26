import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';

class CoinBalance{
  Coin coin;
  Balance balance;
  double balanceUSD;

  CoinBalance(this.coin, this.balance);

  double getValue(double price){
    balanceUSD = balance.balance * price;
  }

  String getBalanceUSD() {
    return balanceUSD.toStringAsFixed(2);
  }  
}
