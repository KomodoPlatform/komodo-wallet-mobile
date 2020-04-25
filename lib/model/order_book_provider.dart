import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';

class OrderBookProvider extends ChangeNotifier {
  OrderBookProvider() {
    Timer.periodic(const Duration(milliseconds: 500), (_) async {
      _updateOrderBooks();
    });
  }

  final List<CoinsPair> _subscribedCoins = [];
  final Map<String, Orderbook> _orderBooks = {}; // {'BTC/KMD': Orderbook(),}
  CoinsPair _activePair;

  Orderbook getOrderBook([CoinsPair coinsPair]) {
    coinsPair ??= activePair;

    if (!_subscribedCoins.contains(coinsPair)) {
      _subscribedCoins.add(coinsPair);
    }
    return _orderBooks['${coinsPair.buy.abbr}/${coinsPair.sell.abbr}'];
  }

  CoinsPair get activePair => _activePair;

  set activePair(CoinsPair coinsPair) {
    _activePair = coinsPair;
    notifyListeners();
  }

  OrderHealth getOrderHealth(Ask order) {
    // TODO(yurii): concider several order health metrics, such as:
    //  - overall swaps number for address
    //  - last 24h swaps number for address
    //  - overall swaps volume for address
    //  - order age
    //  - average order lifetime for address
    //  - average swap duration for address
    //  - online status of address
    //  - ...

    return OrderHealth(
        // just some demo double value in 0-100 range,
        // which depends of order.adress
        rating: (order.address.codeUnitAt(1).toDouble() - 65) * 4);
  }

  // TODO(AG): historical swap data for [coinsPair]
  List<Swap> getSwapHistory(CoinsPair coinsPair) {
    if (coinsPair.sell.abbr == 'VOTE2020' || coinsPair.buy.abbr == 'VOTE2020') {
      return null;
    }

    return [Swap()];
  }

  Future<void> _updateOrderBooks() async {
    for (int i = 0; i < _subscribedCoins.length; i++) {
      _orderBooks[
              '${_subscribedCoins[i].buy.abbr}/${_subscribedCoins[i].sell.abbr}'] =
          await MM.getOrderbook(
              MMService().client,
              GetOrderbook(
                base: _subscribedCoins[i].buy.abbr,
                rel: _subscribedCoins[i].sell.abbr,
              ));
    }

    notifyListeners();
  }

  static String formatPrice(String value, [int digits = 6, int fraction = 2]) {
    final String rounded = double.parse(value).toStringAsFixed(fraction);
    if (rounded.length >= digits + 1) {
      return rounded;
    } else {
      return double.parse(value).toStringAsPrecision(digits);
    }
  }
}

class OrderHealth {
  OrderHealth({this.rating});

  double rating;
}

class CoinsPair {
  CoinsPair({
    this.buy,
    this.sell,
  });

  Coin buy;
  Coin sell;
}
