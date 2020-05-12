import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
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

  Orderbook getOrderBook([CoinsPair coinsPair]) =>
      syncOrderbook.getOrderBook(coinsPair);

  CoinsPair get activePair => syncOrderbook.activePair;

  set activePair(CoinsPair coinsPair) => syncOrderbook.activePair = coinsPair;

  OrderHealth getOrderHealth(Ask order) => syncOrderbook.getOrderHealth(order);

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
  /// then by volume (DESC),
  /// then by age (DESC)
  static List<Ask> sortByPrice(List<Ask> list) {
    final List<Ask> sorted = list;
    
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

/// Liveliness marker (good and bad things we know of an order, like whether it's alive and kicking or not)
class LivMarker {
  /// '+' if the marker author considers the (detected) condition to be a positive sign,
  /// '-' if they are considering it to be a negative one
  String sign;

  /// Alphabetical code ([a-zA-Z]+) of the marker,
  /// allowing the UI to recognize it and apply custom ratings and localizations
  String code;

  /// Payload optionally coming with the marker.
  /// It does not start with [a-zA-Z] and does not have [ +-] in it.
  /// Other than that, format is specific to the kind of the marker (cf. `code`).
  String payload;

  /// English description provided by the marker's author (usually by a caretaker)
  String defaultDesc;

  /// Rating modification assigned by the UI to this marker
  int mod;
}

class OrderHealth {
  OrderHealth({this.rating, this.markers});

  int rating;
  List<LivMarker> markers;
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
  Map<String, String> _livMarkers;

  /// Liveliness marker descriptions provided by a caretaker.
  /// Allows UI to display new / unknown / not-localized-yet markers.
  Map<String, String> _markDesc;

  CoinsPair get activePair => _activePair;

  set activePair(CoinsPair coinsPair) {
    _activePair = coinsPair;
    _notifyListeners();
  }

  Orderbook getOrderBook([CoinsPair coinsPair]) {
    coinsPair ??= activePair;

    return _orderBooks['${coinsPair.buy.abbr}-${coinsPair.sell.abbr}'];
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
    final Map<String, dynamic> obr = components['orderbook.1'];
    final Map<String, dynamic> sb = obr['short_book'];
    _markDesc = Map.from(obr['mark_desc']);

    final Map<String, Orderbook> orderBooks = {};
    final Map<String, String> livMarkers = {};

    for (String pair in sb.keys) {
      final List<Ask> bids = [];

      final List<String> coins = pair.split('-');
      final String line = sb[pair];
      //Log('order_book_provider:178', 'pair $pair; $line');
      for (String so in line.split(';')) {
        final List<String> sol = so.split(' ');
        final id = sol[0];
        final balance = base62rdec(sol[1]);
        final price = base62rdec(sol[2]);
        final markers = sol.length > 3 ? sol[3] : '';

        //Log('order_book_provider:186', '$id; balance $balance; price $price');
        bids.add(Ask(
            coin: coins[0],
            address: '',
            price: price.toDecimalString(),
            maxvolume: deci(balance),
            pubkey: id,
            age: 1 // TODO(AG): Caretaker should share the age of the order.
            ));
        livMarkers[id] = markers;
      }
      orderBooks[pair] = Orderbook(
          bids: bids, numbids: bids.length, base: coins[0], rel: coins[1]);
    }

    _orderBooks = orderBooks;
    _livMarkers = livMarkers;

    // TODO(AG): Only notify if there were actual changes.
    _notifyListeners();
  }

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
    final String markerS = _livMarkers[order.pubkey] ?? '';
    final List<LivMarker> markers = [];
    int rating = 100;
    // -s123-a
    for (RegExpMatch caps
        in RegExp(r'([+-])([a-zA-Z]+)([^\+\-]*)').allMatches(markerS)) {
      final LivMarker lm = LivMarker();
      lm.sign = caps[1];
      lm.code = caps[2];
      lm.payload = caps[3];
      lm.defaultDesc = _markDesc[lm.code];

      if (lm.code == 'a' && lm.sign == '-') {
        lm.mod = -20; // Custom rating
      } else if (lm.sign == '+') {
        lm.mod = 10; // Default rating
      } else if (lm.sign == '-') {
        lm.mod = -10;
      }
      rating += lm.mod;
      markers.add(lm);
    }

    if (rating < 0) rating = 0;
    return OrderHealth(rating: rating, markers: markers);
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
