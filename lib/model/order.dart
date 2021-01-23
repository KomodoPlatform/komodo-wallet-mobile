import 'package:komodo_dex/model/swap.dart';

class Order {
  Order(
      {this.base,
      this.orderType,
      this.rel,
      this.startedSwaps,
      this.relAmount,
      this.uuid,
      this.baseAmount,
      this.createdAt,
      this.cancelable});

  String base;
  String baseAmount;
  String rel;
  OrderType orderType;
  String relAmount;
  String uuid;
  int createdAt;
  bool cancelable;
  List<String> startedSwaps;

  int compareToOrder(Order other) {
    int order = other.createdAt.compareTo(createdAt);
    if (order == 0) order = base.compareTo(other.base);
    if (order == 0) order = rel.compareTo(other.rel);
    return order;
  }

  int compareToSwap(Swap other) {
    int order = 0;
    if (other.result.myInfo != null) {
      order = other.result.myInfo.startedAt.compareTo(createdAt);
      if (order == 0)
        order = createdAt.compareTo(other.result.myInfo.startedAt);
    }

    return order;
  }
}

enum OrderType { MAKER, TAKER }
