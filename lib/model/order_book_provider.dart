import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/orderbook.dart';
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

  Orderbook getOrderBook(CoinsPair coinsPair) {
    if (!_subscribedCoins.contains(coinsPair)) {
      _subscribedCoins.add(coinsPair);
    }
    return _orderBooks['${coinsPair.buy.abbr}/${coinsPair.sell.abbr}'];
  }

  Future<void> _updateOrderBooks() async {
    for (int i = 0; i < _subscribedCoins.length; i++) {
      _orderBooks['${_subscribedCoins[i].buy.abbr}/${_subscribedCoins[i].sell.abbr}'] =
          await MM.getOrderbook(
              MMService().client,
              GetOrderbook(
                base: _subscribedCoins[i].buy.abbr,
                rel: _subscribedCoins[i].sell.abbr,
              ));
    }

    notifyListeners();
  }
}

class CoinsPair {
  CoinsPair({
    this.buy,
    this.sell,
  });

  Coin buy;
  Coin sell;
}