import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';

class OrderBookProvider extends ChangeNotifier {
  OrderBookProvider() {
    syncOrderbook.linkProvider(this);
    jobService.install('syncOrderbook', 7.77, (j) async {
      await syncOrderbook._updateOrderBooks();
    });
  }
  @override
  void dispose() {
    syncOrderbook.unlinkProvider(this);
    super.dispose();
  }

  void notify() => notifyListeners();

  Orderbook getOrderBook([CoinsPair coinsPair]) => syncOrderbook.getOrderBook();

  CoinsPair get activePair => syncOrderbook.activePair;

  set activePair(CoinsPair coinsPair) => syncOrderbook.activePair = coinsPair;

  OrderHealth getOrderHealth(Ask order) {
    // TODO(yurii): consider several order health metrics, such as:
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

  static String formatPrice(String value, [int digits = 6, int fraction = 2]) {
    final String rounded = double.parse(value).toStringAsFixed(fraction);
    if (rounded.length >= digits + 1) {
      return rounded;
    } else {
      return double.parse(value).toStringAsPrecision(digits);
    }
  }

  /// Returns [list] of Ask(), sorted by price (DESC),
  /// then by amount (DESC if [isAsks] is 'true', ASC if 'false'),
  /// then by age (DESC)
  static List<Ask> sortByPrice(List<Ask> list, {bool isAsks = false}) {
    final List<Ask> sorted = list;
    sorted.sort((a, b) {
      if (double.parse(a.price) > double.parse(b.price)) return 1;
      if (double.parse(a.price) < double.parse(b.price)) return -1;

      if (a.maxvolume > b.maxvolume) return isAsks ? 1 : -1;
      if (a.maxvolume < b.maxvolume) return isAsks ? -1 : 1;

      return a.age.compareTo(b.age);
    });
    return sorted;
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

SyncOrderbook syncOrderbook = SyncOrderbook();

/// In ECS terms it is a System coordinating the orderbook information.
class SyncOrderbook {
  /// [ChangeNotifier] proxies linked to this singleton.
  final Set<OrderBookProvider> _providers = {};

  final List<CoinsPair> _subscribedCoins = [];
  final Map<String, Orderbook> _orderBooks = {}; // {'BTC-KMD': Orderbook(),}
  CoinsPair _activePair;

  CoinsPair get activePair => _activePair;

  set activePair(CoinsPair coinsPair) {
    _activePair = coinsPair;
    _notifyListeners();
  }

  Orderbook getOrderBook([CoinsPair coinsPair]) {
    coinsPair ??= activePair;

    if (!_subscribedCoins.contains(coinsPair)) {
      _subscribedCoins.add(coinsPair);
    }
    return _orderBooks['${coinsPair.buy.abbr}/${coinsPair.sell.abbr}'];
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

    _notifyListeners();
  }

  /// Link a [ChangeNotifier] proxy to this singleton.
  void linkProvider(OrderBookProvider provider) {
    _providers.add(provider);
  }

  /// Unlink a [ChangeNotifier] proxy from this singleton.
  void unlinkProvider(OrderBookProvider provider) {
    _providers.remove(provider);
  }

  void _notifyListeners() {
    for (OrderBookProvider provider in _providers) provider.notify();
  }
}
