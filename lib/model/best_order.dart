import 'package:komodo_dex/utils/utils.dart';
import 'package:rational/rational.dart';

import 'package:komodo_dex/model/error_string.dart';

class BestOrders {
  BestOrders({this.result, this.error});

  factory BestOrders.fromJson(Map<String, dynamic> json) {
    final BestOrders bestOrders = BestOrders();
    if (json['result'] == null) return bestOrders;

    json['result'].forEach((String ticker, dynamic items) {
      bestOrders.result ??= {};
      final List<BestOrder> list = [];
      for (dynamic item in items) {
        list.add(BestOrder.fromJson(item));
      }
      bestOrders.result[ticker] = list;
    });

    return bestOrders;
  }

  Map<String, List<BestOrder>> result;
  ErrorString error;
}

class BestOrder {
  BestOrder({
    this.price,
    this.coin,
  });

  factory BestOrder.fromJson(Map<String, dynamic> json) {
    return BestOrder(
      price: fract2rat(json['price_fraction']),
      coin: json['coin'],
    );
  }

  Rational price;
  String coin;
}
