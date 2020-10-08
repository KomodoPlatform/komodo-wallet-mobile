import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';

class CoinBalance {
  CoinBalance(this.coin, this.balance);

  CoinBalance.fromJson(Map<String, dynamic> json) {
    coin = Coin.fromJson(null, json['coin']);
    balance = Balance.fromJson(json['balance']);
    balanceUSD = json['balanceUSD'];
    priceForOne = json['priceForOne'];
  }

  Coin coin;
  Balance balance;
  double balanceUSD;
  String priceForOne;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coin': coin.toJson(),
      'balance': balance.toJson(),
      'balanceUSD': balanceUSD,
      'priceForOne': priceForOne,
    };
  }

  String getBalanceUSD() {
    return balanceUSD.toStringAsFixed(2);
  }
}
