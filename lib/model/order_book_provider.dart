import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/markets/coin_select.dart';
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

  List<Orderbook> orderbooksForCoin([Coin coin]) =>
      syncOrderbook.orderbooksForCoin(coin);

  Future<void> subscribeCoin([Coin coin, CoinType type]) =>
      syncOrderbook.subscribeCoin(coin, type);

  CoinsPair get activePair => syncOrderbook.activePair;
  set activePair(CoinsPair coinsPair) => syncOrderbook.activePair = coinsPair;

  void updateActivePair() => syncOrderbook.updateActivePair();

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
    if (list == null || list.isEmpty) return list;

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
  final List<String> _tickers = [];

  CoinsPair get activePair => _activePair;

  set activePair(CoinsPair coinsPair) {
    _activePair = coinsPair;
    _notifyListeners();
  }

  void updateActivePair() {
    // Check if coins in activePair are still activated
    if (_activePair?.sell != null &&
        coinsBloc.getCoinByAbbr(_activePair.sell.abbr) == null) {
      _activePair.sell = null;
    }
    if (_activePair?.buy != null &&
        coinsBloc.getCoinByAbbr(_activePair.buy.abbr) == null) {
      _activePair.buy = null;
    }

    _notifyListeners();
  }

  Orderbook getOrderBook([CoinsPair coinsPair]) {
    coinsPair ??= activePair;
    if (coinsPair.buy == null || coinsPair.sell == null) return null;

    if (!_tickers.contains(_tickerStr(coinsPair)))
      _tickers.add(_tickerStr(coinsPair));

    return _orderBooks[_tickerStr(coinsPair)];
  }

  Future<void> subscribeCoin([Coin coin, CoinType type]) async {
    coin ??= activePair.sell;
    type ??= CoinType.base;

    bool wasChanged = false;
    final List<CoinBalance> coinsList = coinsBloc.coinBalance;

    for (CoinBalance coinBalance in coinsList) {
      if (coinBalance.coin.abbr == coin.abbr) continue;

      final String ticker = _tickerStr(CoinsPair(
        sell: type == CoinType.base ? coin : coinBalance.coin,
        buy: type == CoinType.rel ? coin : coinBalance.coin,
      ));

      if (!_tickers.contains(ticker)) {
        _tickers.add(ticker);
        wasChanged = true;
      }
    }

    if (wasChanged) await _updateOrderBooks();
  }

  List<Orderbook> orderbooksForCoin([Coin coin]) {
    coin ??= activePair.sell;

    final List<Orderbook> list = [];
    _orderBooks.forEach((ticker, orderbook) {
      if (ticker.split('-')[0] == coin.abbr) {
        list.add(orderbook);
      }
    });

    return list;
  }

  Future<void> _updateOrderBooks() async {
    final Map<String, Orderbook> orderBooks = {};
    for (String pair in _tickers) {
      final List<String> abbr = pair.split('-');
      final Orderbook orderbook = await MM.getOrderbook(
          MMService().client,
          GetOrderbook(
            base: abbr[0],
            rel: abbr[1],
          ));

      orderBooks[pair] = orderbook;
    }

    _orderBooks = orderBooks;
    _notifyListeners();
  }

  String _tickerStr(CoinsPair pair) {
    return '${pair.sell.abbr}-${pair.buy.abbr}';
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
