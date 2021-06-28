import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
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
    _sellAmount = value;
    notifyListeners();
  }

  Rational get buyAmount => _buyAmount;
  set buyAmount(Rational value) {
    _buyAmount = value;
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

  void onSellAmtFieldChange(String newText) {
    Rational newAmount;
    try {
      newAmount = Rational.parse(newText);
    } catch (_) {
      _sellAmount = null;
      notifyListeners();
      return;
    }

    if (newAmount == _sellAmount) return;

    if (newAmount > maxSellAmt) newAmount = maxSellAmt;

    // todo: check if greater than matching bid max volume

    _sellAmount = newAmount;
    notifyListeners();
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
}
