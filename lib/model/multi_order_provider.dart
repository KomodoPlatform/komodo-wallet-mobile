import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

import 'get_trade_fee.dart';

class MultiOrderProvider extends ChangeNotifier {
  String _baseCoin;
  double _sellAmt;
  final Map<String, double> _relCoins = {};
  final Map<String, String> _errors = {};

  String get baseCoin => _baseCoin;
  set baseCoin(String coin) {
    _baseCoin = coin;
    _calculateSellAmt();
    _relCoins.clear();
    _errors.clear();

    notifyListeners();
  }

  void reset() {
    baseCoin = null;
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
      _errors.remove(coin);
    }

    notifyListeners();
  }

  double getRelCoinAmt(String coin) {
    return _relCoins[coin];
  }

  String getError(String coin) {
    return _errors[coin];
  }

  void setRelCoinAmt(String coin, double amt) {
    _relCoins[coin] = amt;
    notifyListeners();
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
        // Magic 'x2' added to match fee, returned by
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

  Future<double> getERCfee(String coin) async {
    final TradeFee tradeFeeResponseERC = await ApiProvider()
        .getTradeFee(MMService().client, GetTradeFee(coin: coin));
    return double.parse(tradeFeeResponseERC.result.amount);
  }

  Future<bool> validate() async {
    bool isValid = true;
    _errors.clear();

    // check min sell amount
    final double minSellAmt = baseCoin == 'QTUM' ? 3 : 0.00777;
    if (baseAmt != null && baseAmt < minSellAmt) {
      isValid = false;
      _errors[baseCoin] = 'Min sell amount is $minSellAmt $baseCoin';
    }

    for (String coin in _relCoins.keys) {
      final double relAmt = _relCoins[coin];

      // check for empty amount field
      if (relAmt == null || relAmt == 0) {
        isValid = false;
        _errors[coin] = 'Amount cannot be empty';
      }

      // check for ETH balance
      if (coinsBloc.getCoinByAbbr(coin).swapContractAddress.isNotEmpty) {
        final CoinBalance ethBalance = coinsBloc.getBalanceByAbbr('ETH');
        if (ethBalance == null) {
          isValid = false;
          _errors[coin] = 'Activate ETH and top-up balance first';
        } else if (ethBalance.balance.balance.toDouble() <
            await getERCfee(coin)) {
          isValid = false;
          _errors[coin] = 'ETH balance is too low';
        }
      }

      // check min receive amount
      final double minReceiveAmt = baseCoin == 'QTUM' ? 3 : 0.00777;
      if (relAmt != null && relAmt < minReceiveAmt) {
        isValid = false;
        _errors[coin] = 'Min receive amount is $minReceiveAmt $coin';
      }
    }

    notifyListeners();

    return isValid;
  }

  Future<void> _calculateSellAmt() async {
    if (baseCoin == null) {
      _sellAmt = null;
    } else {
      final double balance =
          coinsBloc.getBalanceByAbbr(baseCoin).balance.balance.toDouble();
      _sellAmt = balance - await _getBaseFee();
    }

    notifyListeners();
  }

  Future<double> _getBaseFee() async {
    final double tradeFee = getTradeFee();
    final double txFee = await getTxFee() ?? 0;

    return tradeFee + txFee;
  }
}
