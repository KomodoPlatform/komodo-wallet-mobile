import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/screens/dex/trade/protection_control.dart';
import 'package:komodo_dex/screens/dex/trade/build_trade_fees.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

import 'error_string.dart';
import 'get_setprice.dart';

class MultiOrderProvider extends ChangeNotifier {
  final AppLocalizations _localizations = AppLocalizations();
  String _baseCoin;
  double _sellAmt;
  bool _validated = false;

  final Map<String, double> _relCoins = {};
  final Map<String, ProtectionSettings> _protectionSettings = {};
  final Map<String, String> _errors = {};

  String get baseCoin => _baseCoin;
  set baseCoin(String coin) {
    _baseCoin = coin;
    _sellAmt = null;
    _relCoins.clear();
    _errors.clear();

    notifyListeners();
  }

  void reset() {
    baseCoin = null;
    validated = false;
  }

  bool get validated => _validated;
  set validated(bool val) {
    _validated = val;
    notifyListeners();
  }

  double get baseAmt => _sellAmt;
  set baseAmt(double value) {
    _sellAmt = value;
    notifyListeners();
  }

  Map<String, double> get relCoins => _relCoins;

  bool isRelCoinSelected(String coin) {
    return _relCoins.containsKey(coin);
  }

  void selectRelCoin(String coin, bool val) {
    if (val) {
      if (coin == baseCoin) return;
      if (!isRelCoinSelected(coin)) _relCoins[coin] = null;
    } else {
      _relCoins.remove(coin);
      _errors.remove(coin);
    }

    notifyListeners();
  }

  ProtectionSettings getProtectionSettings(String coin) {
    return _protectionSettings[coin];
  }

  void setProtectionSettings(String coin, ProtectionSettings settings) {
    _protectionSettings[coin] = settings;
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

  Future<bool> validate() async {
    bool isValid = true;
    _errors.clear();

    // check if sell amount is empty
    if (baseAmt == null) {
      isValid = false;
      _errors[baseCoin] = _localizations.multiInvalidSellAmt;
    }

    // check if sell amount is lower than available balance
    if (baseAmt != null) {
      final double max = await getMaxSellAmt();
      if (baseAmt > max) {
        isValid = false;
        _errors[baseCoin] = _localizations.multiMaxSellAmt +
            ' ${cutTrailingZeros(formatPrice(max, 8))} $baseCoin';
      }
    }

    // check min sell amount
    final double minSellAmt = baseCoin == 'QTUM' ? 3 : 0.00777;
    if (baseAmt != null && baseAmt < minSellAmt) {
      isValid = false;
      _errors[baseCoin] =
          _localizations.multiMinSellAmt + ' $minSellAmt $baseCoin';
    }

    for (String coin in _relCoins.keys) {
      final double relAmt = _relCoins[coin];

      // check for empty amount field
      if (relAmt == null || relAmt == 0) {
        isValid = false;
        _errors[coin] = _localizations.multiInvalidAmt;
      }

      // check for ETH balance
      if (coinsBloc.getCoinByAbbr(coin).type == 'erc') {
        final CoinBalance ethBalance = coinsBloc.getBalanceByAbbr('ETH');
        if (ethBalance == null) {
          isValid = false;
          _errors[coin] = _localizations.multiActivateEth;
        } else if (ethBalance.balance.balance.toDouble() <
            await getGasFee(coin)) {
          isValid = false;
          _errors[coin] = _localizations.multiLowEth;
        }
      }

      // TODO: check for QTUM balance

      // check min receive amount
      final double minReceiveAmt = baseCoin == 'QTUM' ? 3 : 0.00777;
      if (relAmt != null && relAmt < minReceiveAmt) {
        isValid = false;
        _errors[coin] =
            _localizations.multiMinReceiveAmt + ' $minReceiveAmt $coin';
      }
    }

    notifyListeners();

    return isValid;
  }

  Future<void> create() async {
    if (!(await validate())) return;

    final List<String> relCoins = List.from(_relCoins.keys);

    for (String coin in relCoins) {
      final double amount = _relCoins[coin];

      final GetSetPrice getSetPrice = GetSetPrice(
        base: baseCoin,
        rel: coin,
        cancelPrevious: false,
        max: false,
        volume: baseAmt.toString(),
        price: deci2s(deci(amount / baseAmt)),
      );

      if (_protectionSettings[coin] != null) {
        getSetPrice.relNota = _protectionSettings[coin].requiresNotarization;
        getSetPrice.relConfs = _protectionSettings[coin].requiredConfirmations;
      }

      final dynamic response = await MM.postSetPrice(mmSe.client, getSetPrice);
      if (response is SetPriceResponse) {
        _relCoins.remove(coin);
        _errors.remove(coin);
        _protectionSettings.remove(coin);
      } else if (response is ErrorString) {
        Log(
            'multi_order_provider]',
            'Failed to post setprice:'
                ' ${response.error}');
        _errors[coin] = response.error;
      }
    }

    notifyListeners();
  }

  Future<double> getMaxSellAmt() async {
    double maxAmt;
    if (baseCoin == null) {
      maxAmt = null;
    } else {
      final double balance =
          coinsBloc.getBalanceByAbbr(baseCoin).balance.balance.toDouble();
      maxAmt = balance - await _getBaseFee(balance);
    }

    return maxAmt;
  }

  Future<double> _getBaseFee(double amt) async {
    if (baseCoin == null || amt == null) return null;

    final double tradeFee = getTradeFee(amt);
    final double txFee = await getTxFee(baseCoin) ?? 0;

    return tradeFee + txFee;
  }
}
