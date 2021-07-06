import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/app_config.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_trade_preimage.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/get_best_orders.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
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

      // if > than order max volume
      if (_matchingOrder != null) {
        final Rational price = _matchingOrder.action == MarketAction.SELL
            ? _matchingOrder.price
            : _matchingOrder.price.inverse;

        final Rational maxOrderAmt = _matchingOrder.maxVolume / price;
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

        final Rational price = _matchingOrder.action == MarketAction.BUY
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
    /// todo: implement max balance calculation,
    /// considering fees, max_taker_volume(?), preimage etc.
    if (_sellCoin == null) return null;

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

  Future<BestOrders> getBestOrders(CoinType coinsListType) async {
    String coin;
    Rational amount;
    MarketAction action;

    if (coinsListType == CoinType.base) {
      coin = _buyCoin;
      amount = _buyAmount;
      action = MarketAction.BUY;
    } else {
      coin = _sellCoin;
      amount = _sellAmount;
      action = MarketAction.SELL;
    }

    final BestOrders bestOrders = await MM.getBestOrders(GetBestOrders(
      coin: coin,
      action: action,
      volume: amount,
    ));

    if (bestOrders.error != null) return bestOrders;

    final LinkedHashMap<String, Coin> known = await coins;
    final List<String> tickers = List.from(bestOrders.result.keys);
    for (String ticker in tickers) {
      if (!known.containsKey(ticker)) bestOrders.result.remove(ticker);
    }

    return bestOrders;
  }

  void selectOrder(BestOrder order) {
    _matchingOrder = order;

    if (order.action == MarketAction.BUY) {
      sellCoin = order.otherCoin;
      sellAmount = order.price * _buyAmount;
    } else {
      buyCoin = order.coin;
      buyAmount = order.price * _sellAmount;
    }
  }

  Future<void> _updatePreimage() async {
    if (haveAllData) {
      try {
        _preimage = await MM.getTradePreimage(GetTradePreimage(
            swapMethod: 'buy',
            base: _buyCoin,
            rel: _sellCoin,
            volume: _buyAmount.toDouble().toString(),
            price: (_sellAmount / _buyAmount).toDouble().toString()));
      } catch (e) {
        _preimage = null;
      }
      notifyListeners();
    } else {
      _preimage = null;
      notifyListeners();
    }
  }
}
