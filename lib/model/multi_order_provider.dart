import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin_balance.dart';

class MultiOrderProvider extends ChangeNotifier {
  CoinBalance _baseCoin;

  CoinBalance get baseCoin => _baseCoin;
  set baseCoin(CoinBalance coin) {
    _baseCoin = coin;
    notifyListeners();
  }
}
