import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

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

  Orderbook getOrderBook([CoinsPair coinsPair]) => syncOrderbook.getOrderBook(coinsPair);

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
    // Exploratory (should combine ECS syncs into a single service or helper)

    final List<String> tickers = (await Db.activeCoins).toList();

    final pr = await mmSe.client.post('http://ct.cipig.net/sync',
        body: json.encode(<String, dynamic>{
          'components': <String, dynamic>{
            'orderbook.1': <String, dynamic>{
              // Coins we're currently interested in (e.g. activated)
              'tickers': tickers,
              // TODO(AG): Use `skip` to skip known long lines
            }
          }
        }));
    if (pr.statusCode != 200) throw Exception('HTTP ${pr.statusCode}');
    final ct = pr.headers['content-type'] ?? '';
    if (ct != 'application/json') throw Exception('HTTP Content-Type $ct');
    // NB: `http` fails to recognize that 'application/json' is UTF-8 by default.
    final body = const Utf8Decoder().convert(pr.bodyBytes);
    final Map<String, dynamic> js = json.decode(body);
    final Map<String, dynamic> components = js['components'];
    if (components == null || !components.containsKey('orderbook.1')) return;
    final Map<String, dynamic> sb = components['orderbook.1']['short_book'];

    final List<Ask> bids = [];

    for (String pair in sb.keys) {
      final List<String> coins = pair.split('-');
      final String line = sb[pair];
      //Log('order_book_provider:161', 'pair $pair; $line');
      for (String so in line.split(';')) {
        final List<String> sol = so.split(' ');
        final id = sol[0];
        final balance = base62rdec(sol[1]);
        final price = base62rdec(sol[2]);
        //Log('order_book_provider:167', '$id; balance $balance; price $price');
        bids.add(Ask(
            coin: coins[0],
            address: '',
            price: price.toDecimalString(),
            maxvolume: deci(balance),
            pubkey: id,
            age: 1 // TODO(AG): Caretaker should share the age of the order.
            ));
      }
      _orderBooks[pair] = Orderbook(
          bids: bids, numbids: bids.length, base: coins[0], rel: coins[1]);
    }

    // TODO(AG): Only notify if there were actual changes.
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
