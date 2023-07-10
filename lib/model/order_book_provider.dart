import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import '../blocs/coins_bloc.dart';
import '../model/coin.dart';
import '../model/coin_balance.dart';
import '../model/error_string.dart';
import '../model/get_orderbook_depth.dart';
import '../model/market.dart';
import '../model/orderbook.dart';
import '../model/orderbook_depth.dart';
import '../model/swap.dart';
import '../screens/markets/coin_select.dart';
import '../services/job_service.dart';
import '../services/mm.dart';
import '../services/mm_service.dart';
import '../utils/log.dart';
import '../utils/utils.dart';
import 'get_orderbook.dart';

class OrderBookProvider extends ChangeNotifier {
  OrderBookProvider() {
    syncOrderbook.linkProvider(this);
    jobService.install('syncOrderbook', 5, (j) async {
      if (!mmSe.running) return;
      await syncOrderbook._updateOrderBooks();
      await syncOrderbook._updateOrderbookDepth();
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

  String getOrderbookError([CoinsPair coinsPair]) =>
      syncOrderbook.getOrderbookError(coinsPair);

  OrderbookDepth getDepth([CoinsPair coinsPair]) =>
      syncOrderbook.getDepth(coinsPair);

  // deprecated in favor of depthsForCoin
  // https://github.com/KomodoPlatform/AtomicDEX-mobile/issues/1146
  List<Orderbook> orderbooksForCoin([Coin coin]) =>
      syncOrderbook.orderbooksForCoin(coin);

  List<OrderbookDepth> depthsForCoin([Coin coin, Market type]) =>
      syncOrderbook.depthForCoin(coin, type);

  // deprecated in favor of subscribeDepth
  // https://github.com/KomodoPlatform/AtomicDEX-mobile/issues/1146
  Future<void> subscribeCoin([Coin coin, CoinType type]) =>
      syncOrderbook.subscribeCoin(coin, type);

  Future<void> subscribeDepth(String abbr, CoinType type) async =>
      await syncOrderbook.subscribeDepth(abbr, type);

  CoinsPair get activePair => syncOrderbook.activePair;
  set activePair(CoinsPair coinsPair) => syncOrderbook.activePair = coinsPair;

  void updateActivePair() => syncOrderbook.updateActivePair();

  // todo(AG): historical swap data for [coinsPair]
  List<Swap> getSwapHistory(CoinsPair coinsPair) {
    if (coinsPair.sell.abbr.startsWith('VOTE') ||
        coinsPair.buy.abbr.startsWith('VOTE')) {
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
            final Ask quoteAsk = Ask.fromJson(ask.toJson());
            quoteAsk.price = '${1 / double.parse(ask.price)}';
            quoteAsk.priceFract = ask.priceFract == null
                ? null
                : <String, dynamic>{
                    'numer': ask.priceFract['denom'],
                    'denom': ask.priceFract['numer'],
                  };
            return quoteAsk;
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

  Map<String, Orderbook> _orderBooks = {}; // {'BTC/KMD': Orderbook(),}
  Map<String, String> _orderBookErrors = {}; // {'BTC/KMD': 'error1',}
  Map<String, OrderbookDepth> _orderbooksDepth = {};
  CoinsPair _activePair;
  bool _updatingDepth = false;

  /// Maps short order IDs to latest liveliness markers.
  final List<String> _tickers = [];
  final List<String> _depthTickers = [];

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

  String getOrderbookError([CoinsPair coinsPair]) {
    coinsPair ??= activePair;
    if (coinsPair.buy == null || coinsPair.sell == null) return null;

    if (!_tickers.contains(_tickerStr(coinsPair)))
      _tickers.add(_tickerStr(coinsPair));

    return _orderBookErrors[_tickerStr(coinsPair)];
  }

  OrderbookDepth getDepth([CoinsPair coinsPair]) {
    coinsPair ??= activePair;
    if (coinsPair.buy == null || coinsPair.sell == null) return null;

    if (!_depthTickers.contains(_tickerStr(coinsPair))) {
      _depthTickers.add(_tickerStr(coinsPair));
    }
    return _orderbooksDepth[_tickerStr(coinsPair)];
  }

  Future<void> subscribeDepth(String abbr, CoinType type) async {
    if (_updatingDepth) await pauseUntil(() => !_updatingDepth);

    bool wasChanged = false;
    final LinkedHashMap<String, Coin> known = await coins;
    final List<CoinBalance> active = coinsBloc.coinBalance;

    active.removeWhere((e) => e.coin.walletOnly);
    final Coin coin = known[abbr];

    for (CoinBalance coinBalance in active) {
      if (coinBalance.coin.abbr == abbr) continue;

      final String ticker = _tickerStr(CoinsPair(
        sell: type == CoinType.base ? coin : coinBalance.coin,
        buy: type == CoinType.rel ? coin : coinBalance.coin,
      ));

      if (!_depthTickers.contains(ticker)) {
        _depthTickers.add(ticker);
        wasChanged = true;
      }
    }

    if (wasChanged) await _updateOrderbookDepth();
  }

  Future<void> subscribeCoin([Coin coin, CoinType type]) async {
    coin ??= activePair.sell;
    type ??= CoinType.base;

    bool wasChanged = false;
    final List<CoinBalance> coinsList = coinsBloc.coinBalance;
    coinsList.removeWhere((e) => e.coin.walletOnly);

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
      if (ticker.split('/')[0] == coin.abbr) {
        list.add(orderbook);
      }
    });

    return list;
  }

  List<OrderbookDepth> depthForCoin([Coin coin, Market type]) {
    coin ??= activePair?.sell;
    type ??= Market.SELL;

    final List<OrderbookDepth> list = [];
    _orderbooksDepth.forEach((ticker, orderbookDepth) {
      final int coinIndex = type == Market.SELL ? 0 : 1;
      if (ticker.split('/')[coinIndex] == coin?.abbr) {
        list.add(orderbookDepth);
      }
    });

    list.sort((a, b) => a.pair.rel.compareTo(b.pair.rel));
    return list;
  }

  Future<void> _updateOrderBooks() async {
    final Map<String, Orderbook> orderBooks = {};
    final Map<String, String> orderBookErrors = {};
    for (String pair in _tickers) {
      try {
        final List<String> abbr = pair.split('/');
        final dynamic orderbook = await MM.getOrderbook(
            mmSe.client,
            GetOrderbook(
              base: abbr[0],
              rel: abbr[1],
            ));

        if (orderbook is Orderbook) {
          orderBooks[pair] = orderbook;
        }
      } catch (e) {
        orderBookErrors[pair] = e.error;
        Log('order_book_provider] _updateOrderBooks', '$pair: ${e.error}');
      }
    }

    _orderBooks = orderBooks;
    _orderBookErrors = orderBookErrors;
    _notifyListeners();
  }

  Future<void> _updateOrderbookDepth() async {
    _updatingDepth = true;

    final List<List<String>> pairs = [];
    for (String pair in _depthTickers) {
      final List<String> abbr = pair.split('/');
      pairs.add(abbr);
    }

    final dynamic result =
        await MM.getOrderbookDepth(GetOrderbookDepth(pairs: pairs));

    if (result is ErrorString) {
      Log('order_book_provider', '_updateOrderbooksDepth] ${result.error}');
      _updatingDepth = false;
      return;
    }

    if (result is List<OrderbookDepth>) {
      final Map<String, OrderbookDepth> orderbooksDepth = {};

      for (OrderbookDepth item in result) {
        orderbooksDepth['${item.pair.base}/${item.pair.rel}'] = item;
      }

      _orderbooksDepth = orderbooksDepth;
      _notifyListeners();
    }

    _updatingDepth = false;
  }

  String _tickerStr(CoinsPair pair) {
    return '${pair.sell.abbr}/${pair.buy.abbr}';
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
