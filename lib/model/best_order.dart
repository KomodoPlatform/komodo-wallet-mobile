import '../model/get_best_orders.dart';
import '../model/market.dart';
import '../utils/utils.dart';
import 'package:rational/rational.dart';
import '../model/error_string.dart';

class BestOrders {
  BestOrders({this.result, this.error, this.request});

  factory BestOrders.fromJson(Map<String, dynamic> json) {
    final BestOrders bestOrders = BestOrders(request: json['request']);
    if (json['result'] == null) return bestOrders;

    final Market action = bestOrders.request.action;
    final Map<String, dynamic> result = json['result'];
    final Map<String, dynamic> resultOrders =
        result['orders'] as Map<String, dynamic>;

    resultOrders.forEach((String ticker, dynamic items) {
      bestOrders.result ??= {};
      final List<BestOrder> list = [];
      for (final Map<String, dynamic> item in items) {
        item['action'] = action;
        item['other_coin'] =
            action == Market.SELL ? bestOrders.request.coin : ticker;
        list.add(BestOrder.fromJson(item));
      }
      bestOrders.result[ticker] = list;
    });

    return bestOrders;
  }

  Map<String, List<BestOrder>> result;
  ErrorString error;
  GetBestOrders request;
}

class BestOrder {
  BestOrder({
    this.price,
    this.maxVolume,
    this.minVolume,
    this.coin,
    this.otherCoin,
    this.address,
    this.action,
  });

  factory BestOrder.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> price = json['price'];
    final Map<String, dynamic> address = json['address'];

    // base_ max and min volume are used, as the base and rel coins are swapped
    // for buy and sell orders, so the max volume is always the max volume of
    // the base coin. The web wallet has a similar implementation.
    final Map<String, dynamic> maxVolume = json['base_max_volume'];
    final Map<String, dynamic> minVolume = json['base_min_volume'];

    return BestOrder(
      price: fract2rat(price['fraction']) ?? Rational.parse(price['decimal']),
      maxVolume: fract2rat(maxVolume['fraction']) ??
          Rational.parse(maxVolume['decimal']),
      minVolume: fract2rat(minVolume['fraction']) ??
          Rational.parse(minVolume['decimal']),
      coin: json['coin'],
      otherCoin: json['other_coin'],
      address: address['address_data'],
      action: json['action'],
    );
  }

  Rational price;
  Rational maxVolume;
  Rational minVolume;
  String coin;
  String otherCoin;
  bool isMine;
  String address;
  Market action;
}
