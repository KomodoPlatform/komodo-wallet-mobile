import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';

class MultiOrderProvider extends ChangeNotifier {
  String _baseCoin;
  double _sellAmt;
  final Map<String, double> _relCoins = {};

  String get baseCoin => _baseCoin;
  set baseCoin(String coin) {
    _baseCoin = coin;
    // TODO: calculate actual max available balance
    _sellAmt = coinsBloc.getBalanceByAbbr(coin).balance.balance.toDouble();
    selectRelCoin(coin, false);
    notifyListeners();
  }

  double get baseAmt => _sellAmt;

  Map<String, double> get relCoins => _relCoins;

  bool isRelCoinSelected(String coin) {
    return _relCoins.containsKey(coin);
  }

  void selectRelCoin(String coin, bool val) {
    if (val) {
      if (!isRelCoinSelected(coin)) _relCoins[coin] = null;
    } else {
      _relCoins.remove(coin);
    }

    notifyListeners();
  }

  double getRelCoinAmt(String coin) {
    return _relCoins[coin];
  }

  void setRelCoinAmt(String coin, double amt) {
    _relCoins[coin] = amt;
    notifyListeners();
  }
}
