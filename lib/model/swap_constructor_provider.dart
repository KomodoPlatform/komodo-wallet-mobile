import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';

class ConstructorProvider extends ChangeNotifier {
  String _sellCoin;
  String _buyCoin;
  double _sellAmount;

  String get sellCoin => _sellCoin;
  set sellCoin(String value) {
    _sellCoin = value;
    notifyListeners();
  }

  String get buyCoin => _buyCoin;
  set buyCoin(String value) {
    _buyCoin = value;
    notifyListeners();
  }

  double get sellAmount => _sellAmount;
  set sellAmount(double value) {
    _sellAmount = value;
    notifyListeners();
  }

  double maxSellAmt() {
    /// todo: implement max balance calculation,
    /// considering fees, max_taker_volume(?), preimage etc.
    if (_sellCoin == null) return null;

    final CoinBalance coinBalance = coinsBloc.getBalanceByAbbr(_sellCoin);
    if (coinBalance == null) return null;

    return coinBalance.balance.balance.toDouble();
  }
}
