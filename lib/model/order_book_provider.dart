import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';

import 'get_orderbook.dart';

class OrderBookProvider extends ChangeNotifier {
  OrderBookProvider() {
    syncOrderbook.linkProvider(this);
    jobService.install('syncOrderbook', 2, (j) async {
      await syncOrderbook._updateOrderBooks();
    });
  }
  @override
  void dispose() {
    syncOrderbook.unlinkProvider(this);
    super.dispose();
  }

  void notify() => notifyListeners();

  Orderbook getOrderBook([CoinsPair coinsPair]) =>
      syncOrderbook.getOrderBook(coinsPair);

  CoinsPair get activePair => syncOrderbook.activePair;
  set activePair(CoinsPair coinsPair) => syncOrderbook.activePair = coinsPair;

  // TODO(AG): historical swap data for [coinsPair]
  List<Swap> getSwapHistory(CoinsPair coinsPair) {
    if (coinsPair.sell.abbr == 'VOTE2020' || coinsPair.buy.abbr == 'VOTE2020') {
      return null;
    }

    return [Swap()];
  }

  /// Returns [list] of Ask(), sorted by price (DESC),
  /// then by volume (DESC),
  /// then by age (DESC)
  static List<Ask> sortByPrice(List<Ask> list, {bool quotePrice = false}) {
    final List<Ask> sorted = quotePrice
        ? list.map((Ask ask) {
            final double price = 1 / double.parse(ask.price);
            return Ask(
              address: ask.address,
              age: ask.age,
              coin: ask.coin,
              pubkey: ask.pubkey,
              zcredits: ask.zcredits,
              price: price.toString(),
              maxvolume: ask.maxvolume,
            );
          }).toList()
        : List.from(list);

    sorted.sort((a, b) {
      if (double.parse(a.price) > double.parse(b.price)) return 1;
      if (double.parse(a.price) < double.parse(b.price)) return -1;

      if (a.maxvolume > b.maxvolume) return -1;
      if (a.maxvolume < b.maxvolume) return 1;

      return a.age.compareTo(b.age);
    });
    return sorted;
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

SyncOrderbook syncOrderbook = SyncOrderbook();

/// In ECS terms it is a System coordinating the orderbook information.
class SyncOrderbook {
  /// [ChangeNotifier] proxies linked to this singleton.
  final Set<OrderBookProvider> _providers = {};

  Map<String, Orderbook> _orderBooks; // {'BTC-KMD': Orderbook(),}
  CoinsPair _activePair;

  /// Maps short order IDs to latest liveliness markers.
  final List<CoinsPair> _tickers = [];

  CoinsPair get activePair => _activePair;

  set activePair(CoinsPair coinsPair) {
    _activePair = coinsPair;
    _notifyListeners();
  }

  Orderbook getOrderBook([CoinsPair coinsPair]) {
    coinsPair ??= activePair;
    if (!_tickers.contains(coinsPair)) _tickers.add(coinsPair);

    if (coinsPair.buy == null || coinsPair.sell == null) return null;

    return _orderBooks['${coinsPair.buy.abbr}-${coinsPair.sell.abbr}'];
  }

  Future<void> _updateOrderBooks() async {
    final Map<String, Orderbook> orderBooks = {};
    for (CoinsPair pair in _tickers) {
      final Orderbook orderbook = await MM.getOrderbook(
          MMService().client,
          GetOrderbook(
            base: pair.buy.abbr,
            rel: pair.sell.abbr,
          ));

      orderBooks['${pair.buy.abbr}-${pair.sell.abbr}'] = orderbook;
    }

    _orderBooks = orderBooks;
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
