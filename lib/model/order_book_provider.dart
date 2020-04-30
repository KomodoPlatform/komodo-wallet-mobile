import 'package:flutter/material.dart';
import 'package:komodo_dex/model/orderbook.dart';

class OrderBookProvider extends ChangeNotifier {
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
