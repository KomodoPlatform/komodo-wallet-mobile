import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

import 'get_trade_fee.dart';

class MultiOrderProvider extends ChangeNotifier {
  String _baseCoin;
  double _sellAmt;
  final Map<String, double> _relCoins = {};

  String get baseCoin => _baseCoin;
  set baseCoin(String coin) {
    _baseCoin = coin;
    _calculateSellAmt(coin);
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

  Future<void> _calculateSellAmt(String coin) async {
    final double balance =
        coinsBloc.getBalanceByAbbr(coin).balance.balance.toDouble();
    _sellAmt = balance - await _getBaseFee(coin, balance);
    notifyListeners();
  }

  Future<double> _getBaseFee(String coin, double balance) async {
    final double tradeFee = _getTradeFee(balance);
    final double txFee = await _getTxFee(coin) ?? 0;

    return tradeFee + txFee;
  }

  double _getTradeFee(double balance) {
    return balance / 777;
  }

  Future<double> _getTxFee(String coin) async {
    try {
      final dynamic tradeFeeResponse =
          await MM.getTradeFee(MMService().client, GetTradeFee(coin: coin));

      if (tradeFeeResponse is TradeFee) {
        return double.parse(tradeFeeResponse.result.amount);
      } else {
        return null;
      }
    } catch (e) {
      Log('multi_order_provider] failed to get tx fee', e);
      rethrow;
    }
  }
}
