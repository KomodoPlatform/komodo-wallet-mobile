import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/get_trade_preimage.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/protection_control.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

import 'error_string.dart';
import 'get_setprice.dart';

class MultiOrderProvider extends ChangeNotifier {
  final AppLocalizations _localizations = AppLocalizations();
  String _baseCoin;
  String _baseCoinError;
  double _sellAmt;
  bool _isMax = false;
  bool _validated = false;

  final Map<String, MultiOrderRelCoin> _relCoins = {};

  String get baseCoin => _baseCoin;
  set baseCoin(String coin) {
    reset();
    _baseCoin = coin;

    notifyListeners();
  }

  void reset() {
    _baseCoin = null;
    _baseCoinError = null;
    _sellAmt = null;
    _isMax = false;
    _validated = false;
    _relCoins.clear();

    notifyListeners();
  }

  bool get validated => _validated;
  set validated(bool val) {
    _validated = val;
    notifyListeners();
  }

  bool get isMax => _isMax;
  set isMax(bool value) {
    _isMax = value;
    notifyListeners();
  }

  double get baseAmt => _sellAmt;
  set baseAmt(double value) {
    _sellAmt = value;
    notifyListeners();

    _updateAllPreimages();
  }

  Map<String, MultiOrderRelCoin> get relCoins => _relCoins;

  bool isRelCoinSelected(String coin) {
    return _relCoins.containsKey(coin);
  }

  void selectRelCoin(String coin, bool val) {
    if (val) {
      if (coin == baseCoin) return;
      if (!isRelCoinSelected(coin)) _relCoins[coin] = MultiOrderRelCoin();
    } else {
      _relCoins.remove(coin);
    }

    notifyListeners();
  }

  ProtectionSettings getProtectionSettings(String coin) {
    return relCoins[coin]?.protectionSettings;
  }

  void setProtectionSettings(String coin, ProtectionSettings settings) {
    _relCoins[coin] ??= MultiOrderRelCoin();
    _relCoins[coin].protectionSettings = settings;
    notifyListeners();
  }

  double getRelCoinAmt(String coin) {
    return _relCoins[coin] == null ? null : _relCoins[coin].amount;
  }

  TradePreimage getPreimage(String coin) => _relCoins[coin]?.preimage;

  String getError(String coin) {
    if (coin == _baseCoin) return _baseCoinError;

    return _relCoins[coin]?.error;
  }

  Future<void> setRelCoinAmt(String coin, double amt) async {
    if (amt == _relCoins[coin]?.amount) return;

    _relCoins[coin] ??= MultiOrderRelCoin();
    _relCoins[coin].amount = amt;
    notifyListeners();

    _updatePreimage(coin);
  }

  bool processing() {
    bool processing = false;
    _relCoins.forEach((abbr, coin) {
      if (coin?.processing == true) processing = true;
    });
    return processing;
  }

  Future<bool> validate() async {
    bool isValid = true;
    _relCoins.forEach((abbr, coin) => coin.error = null);
    _baseCoinError = null;

    // check if sell amount is empty
    if (baseAmt == null) {
      isValid = false;
      _baseCoinError = _localizations.multiInvalidSellAmt;
    }

    // check if sell amount is lower than available balance
    if (baseAmt != null) {
      final double max = getMaxSellAmt();
      if (baseAmt > max) {
        isValid = false;
        _baseCoinError = _localizations.multiMaxSellAmt +
            ' ${cutTrailingZeros(formatPrice(max, 8))} $baseCoin';
      }
    }

    // check min sell amount
    final double minSellAmt = await tradeForm.minVolumeDefault(_baseCoin);
    if (baseAmt != null && baseAmt < minSellAmt) {
      isValid = false;
      _baseCoinError =
          _localizations.multiMinSellAmt + ' $minSellAmt $baseCoin';
    }

    final validator = TradeFormValidator();
    for (String relCoin in _relCoins.keys) {
      _relCoins[relCoin].processing = true;
      notifyListeners();

      final double relAmt = _relCoins[relCoin].amount;

      // check for empty amount field
      if (relAmt == null || relAmt == 0) {
        isValid = false;
        _relCoins[relCoin].error = _localizations.multiInvalidAmt;
      }

      // check for base coin gas balance for every order
      final String baseCoinGasError = await validator.validateGasFor(
          _baseCoin, _relCoins[relCoin].preimage);
      if (baseCoinGasError != null) {
        isValid = false;
        _baseCoinError = baseCoinGasError;
      }
      // check for every rel coin gas balance
      final String relCoinGasError =
          await validator.validateGasFor(relCoin, _relCoins[relCoin].preimage);
      if (relCoinGasError != null) {
        isValid = false;
        _relCoins[relCoin].error = relCoinGasError;
      }

      // check min receive amount
      final double minReceiveAmt = await tradeForm.minVolumeDefault(relCoin);
      if (relAmt != null && relAmt < minReceiveAmt) {
        isValid = false;
        relCoins[relCoin].error =
            _localizations.multiMinReceiveAmt + ' $minReceiveAmt $relCoin';
      }

      _relCoins[relCoin].processing = false;
      notifyListeners();
    }

    notifyListeners();

    return isValid;
  }

  Future<void> create() async {
    if (!(await validate())) return;

    final List<String> relCoins = List.from(_relCoins.keys);

    for (String coin in relCoins) {
      final double amount = _relCoins[coin].amount;

      final GetSetPrice getSetPrice = GetSetPrice(
        base: baseCoin,
        rel: coin,
        cancelPrevious: false,
        max: _isMax,
        volume: baseAmt.toString(),
        price: deci2s(deci(amount / baseAmt)),
      );

      if (_relCoins[coin]?.protectionSettings != null) {
        getSetPrice.relNota =
            _relCoins[coin].protectionSettings.requiresNotarization;
        getSetPrice.relConfs =
            _relCoins[coin].protectionSettings.requiredConfirmations;
      }

      final dynamic response = await MM.postSetPrice(mmSe.client, getSetPrice);
      if (response is SetPriceResponse) {
        _relCoins.remove(coin);
      } else if (response is ErrorString) {
        Log(
            'multi_order_provider]',
            'Failed to post setprice:'
                ' ${response.error}');
        _relCoins[coin].error = response.error;
      }
    }

    notifyListeners();
  }

  double getMaxSellAmt() {
    if (baseCoin == null) return null;

    return coinsBloc.getBalanceByAbbr(baseCoin).balance.balance.toDouble();
  }

  void _updateAllPreimages() {
    _relCoins.forEach((abbr, coin) => _updatePreimage(abbr));
  }

  Future<void> _updatePreimage(String coin) async {
    if (_baseCoin == null) return;
    if (_sellAmt == null || _sellAmt == 0.0) return;
    if (coin == null || _relCoins[coin] == null) return;
    if (_relCoins[coin].amount == null || _relCoins[coin].amount == 0.0) return;

    _relCoins[coin].processing = true;
    notifyListeners();

    TradePreimage preimage;
    try {
      preimage = await MM.getTradePreimage(GetTradePreimage(
        base: _baseCoin,
        rel: coin,
        max: _isMax,
        swapMethod: 'setprice',
        volume: _sellAmt.toString(),
        price: (_relCoins[coin].amount / _sellAmt).toString(),
      ));
    } catch (e) {
      _relCoins[coin].processing = false;
      _relCoins[coin].preimage = null;
      Log('multi_order_provider', '_updatePreimage] $e');
      _relCoins[coin].error = e.toString();
      notifyListeners();
      return;
    }

    _relCoins[coin].processing = false;
    _relCoins[coin].preimage = preimage;
    _relCoins[coin].error = null;
    notifyListeners();
  }
}

class MultiOrderRelCoin {
  MultiOrderRelCoin({
    this.amount,
    this.protectionSettings,
    this.error,
    this.preimage,
    this.processing,
  });

  double amount;
  ProtectionSettings protectionSettings;
  String error;
  TradePreimage preimage;
  bool processing;
}
