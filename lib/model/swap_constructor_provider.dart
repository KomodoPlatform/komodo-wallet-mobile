import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/get_trade_preimage_2.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:komodo_dex/model/rpc_error.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/app_config.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_max_taker_volume.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/model/get_best_orders.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';

class ConstructorProvider extends ChangeNotifier {
  String _sellCoin;
  String _buyCoin;
  Rational _sellAmount;
  Rational _buyAmount;
  BestOrder _matchingOrder;
  TradePreimage _preimage;
  Rational _maxTakerVolume;
  String _error;

  String get error => _error;

  TradePreimage get preimage => _preimage;
  set preimage(TradePreimage value) {
    _preimage = value;
    notifyListeners();
  }

  bool get haveAllData {
    return _sellCoin != null &&
        _buyCoin != null &&
        (_buyAmount?.toDouble() ?? 0) > 0 &&
        (_sellAmount?.toDouble() ?? 0) > 0 &&
        _matchingOrder != null;
  }

  String get sellCoin => _sellCoin;
  set sellCoin(String value) {
    _sellCoin = value;
    _sellAmount = null;
    _updateMaxTakerVolume();
    notifyListeners();
  }

  String get buyCoin => _buyCoin;
  set buyCoin(String value) {
    _buyCoin = value;
    _buyAmount = null;
    notifyListeners();
  }

  Rational get sellAmount => _sellAmount;
  set sellAmount(Rational value) {
    if (value != null) {
      // if > than balance
      if (value > maxSellAmt) value = maxSellAmt;

      if (_matchingOrder != null) {
        final Rational price = _matchingOrder.action == Market.SELL
            ? _matchingOrder.price
            : _matchingOrder.price.inverse;

        final Rational maxOrderAmt = _matchingOrder.maxVolume / price;
        // if > than order max volume
        if (value > maxOrderAmt) value = maxOrderAmt;

        _buyAmount = value * price;
      }
    }

    _sellAmount = value;
    notifyListeners();

    _updatePreimage();
  }

  Rational get buyAmount => _buyAmount;
  set buyAmount(Rational value) {
    if (value != null) {
      if (_matchingOrder != null) {
        final Rational maxOrderAmt = _matchingOrder.maxVolume;
        // if > than order max volume
        if (value > maxOrderAmt) value = maxOrderAmt;

        final Rational price = _matchingOrder.action == Market.BUY
            ? _matchingOrder.price
            : _matchingOrder.price.inverse;

        // if > than max sell balance
        if (value * price > maxSellAmt) value = maxSellAmt / price;

        _sellAmount = value * price;
      }
    }

    _buyAmount = value;
    notifyListeners();

    _updatePreimage();
  }

  BestOrder get matchingOrder => _matchingOrder;
  set matchingOrder(BestOrder value) {
    _matchingOrder = value;
    notifyListeners();
  }

  Rational get maxSellAmt {
    if (_sellCoin == null) return null;

    if (_maxTakerVolume != null) return _maxTakerVolume;

    final CoinBalance coinBalance = coinsBloc.getBalanceByAbbr(_sellCoin);
    if (coinBalance == null) return null;

    return deci2rat(coinBalance.balance.balance);
  }

  void onBuyAmtFieldChange(String newText) {
    Rational newAmount;
    try {
      newAmount = Rational.parse(newText);
    } catch (_) {
      _buyAmount = null;
      if (_matchingOrder != null) _sellAmount = null;
      _preimage = null;
      notifyListeners();
      return;
    }

    if (_buyAmount != null) {
      final String currentText = cutTrailingZeros(
          _buyAmount.toStringAsFixed(appConfig.tradeFormPrecision));
      if (newText == currentText) return;
    }

    buyAmount = newAmount;
  }

  void onSellAmtFieldChange(String newText) {
    Rational newAmount;
    try {
      newAmount = Rational.parse(newText);
    } catch (_) {
      _sellAmount = null;
      if (_matchingOrder != null) _buyAmount = null;
      _preimage = null;
      notifyListeners();
      return;
    }

    if (_sellAmount != null) {
      final String currentText = cutTrailingZeros(
          _sellAmount.toStringAsFixed(appConfig.tradeFormPrecision));
      if (newText == currentText) return;
    }

    sellAmount = newAmount;
  }

  Future<BestOrders> getBestOrders(Market coinsListType) async {
    String coin;
    Rational amount;
    Market action;

    if (coinsListType == Market.SELL) {
      coin = _buyCoin;
      amount = _buyAmount;
      action = Market.BUY;
    } else {
      coin = _sellCoin;
      amount = _sellAmount;
      action = Market.SELL;
    }

    final BestOrders bestOrders = await MM.getBestOrders(GetBestOrders(
      coin: coin,
      action: action,
      volume: amount,
    ));

    if (bestOrders.error != null) return bestOrders;
    if (bestOrders.result == null) return bestOrders;

    final LinkedHashMap<String, Coin> known = await coins;
    final List<String> tickers = List.from(bestOrders.result.keys);
    for (String ticker in tickers) {
      if (!known.containsKey(ticker)) bestOrders.result.remove(ticker);
    }

    return bestOrders;
  }

  Future<void> selectOrder(BestOrder order) async {
    _matchingOrder = order;

    if (order.action == Market.BUY) {
      sellCoin = order.otherCoin;
      await _updateMaxTakerVolume();
      sellAmount = order.price * _buyAmount;
    } else {
      buyCoin = order.coin;
      buyAmount = order.price * _sellAmount;
    }
  }

  Future<void> _updatePreimage() async {
    if (haveAllData) {
      final TradePreimage preimage = await MM.getTradePreimage2(
          GetTradePreimage2(
              swapMethod: 'buy',
              base: _buyCoin,
              rel: _sellCoin,
              volume: _buyAmount,
              price: _sellAmount / _buyAmount));

      if (_validatePreimage(preimage)) {
        _preimage = preimage;
      } else {
        _preimage = null;
      }
    } else {
      _preimage = null;
    }

    notifyListeners();
  }

  bool _validatePreimage(TradePreimage preimage) {
    bool isValid = true;

    if (preimage.error != null) {
      isValid = false;
      _error = _getHumanPreimageError(preimage.error);
    } else {
      // check active coins
      for (CoinFee coinFee in preimage.totalFees) {
        final CoinBalance coinBalance =
            coinsBloc.getBalanceByAbbr(coinFee.coin);
        if (coinBalance == null) {
          isValid = false;
          _error = '${coinFee.coin} is not active';
          break;
        }
      }

      // if < than order min volume
      final Rational minOrderVolume = _matchingOrder.minVolume;
      if (minOrderVolume != null && minOrderVolume > _buyAmount) {
        isValid = false;
        final Rational price = _matchingOrder.action == Market.SELL
            ? _matchingOrder.price
            : _matchingOrder.price.inverse;
        final Rational minSellVolume = minOrderVolume / price;
        _error = 'Min order volume is'
            ' ${minSellVolume.toStringAsFixed(appConfig.tradeFormPrecision)}'
            ' ${_matchingOrder.otherCoin}'
            '\n(${minOrderVolume.toStringAsFixed(appConfig.tradeFormPrecision)}'
            ' ${_matchingOrder.coin})';
      }
    }

    if (isValid) _error = null;
    return isValid;
  }

  String _getHumanPreimageError(RpcError error) {
    String str;
    switch (error.type) {
      case RpcErrorType.NotSufficientBaseCoinBalance:
        str = '${error.data['coin']} balance is not sufficient'
            ' to pay fees';
        break;
      case RpcErrorType.NotSufficientBalance:
        str = '${error.data['coin']} balance is not sufficient for trade. '
            'Min required balance is '
            '${cutTrailingZeros(formatPrice(error.data['required']))} '
            '${error.data['coin']}';
        break;
      case RpcErrorType.VolumeTooLow:
        str =
            'Min volume is ${cutTrailingZeros(formatPrice(error.data['threshold']))}'
            ' ${error.data['coin']}';
        break;
      default:
        str = error.message ?? 'Something went wrong. Please try again.';
    }

    return str;
  }

  Future<void> _updateMaxTakerVolume() async {
    _error = null;

    if (_sellCoin == null) {
      _maxTakerVolume = null;
      return;
    }

    try {
      _maxTakerVolume =
          await MM.getMaxTakerVolume(GetMaxTakerVolume(coin: _sellCoin));

      if (_maxTakerVolume.toDouble() == 0) {
        _error = '$_sellCoin balance is not sufficient for trade';
      }
    } catch (e) {
      _maxTakerVolume = null;
    }

    notifyListeners();
  }
}
