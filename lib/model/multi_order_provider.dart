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
    _calculateSellAmt();
    _relCoins.clear();

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

  Future<void> _calculateSellAmt() async {
    final double balance =
        coinsBloc.getBalanceByAbbr(baseCoin).balance.balance.toDouble();
    _sellAmt = balance - await _getBaseFee();

    notifyListeners();
  }

  Future<double> _getBaseFee() async {
    final double tradeFee = getTradeFee();
    final double txFee = await getTxFee() ?? 0;

    return tradeFee + txFee;
  }

  double getTradeFee() {
    if (baseCoin == null) return null;

    final double balance =
        coinsBloc.getBalanceByAbbr(baseCoin).balance.balance.toDouble();

    return balance / 777;
  }

  Future<double> getTxFee() async {
    if (baseCoin == null) return null;

    try {
      final dynamic tradeFeeResponse =
          await MM.getTradeFee(MMService().client, GetTradeFee(coin: baseCoin));

      if (tradeFeeResponse is TradeFee) {
        // Magic x2 added to match fee, returned by
        // TradePage.getTxFee (trade_page.dart:294)
        return double.parse(tradeFeeResponse.result.amount) * 2;
      } else {
        return null;
      }
    } catch (e) {
      Log('multi_order_provider] failed to get tx fee', e);
      rethrow;
    }
  }
}
