import '../model/swap.dart';
import '../utils/utils.dart';

class Order {
  Order(
      {this.base,
      this.orderType,
      this.rel,
      this.startedSwaps,
      this.relAmount,
      this.uuid,
      this.baseAmount,
      this.minVolume,
      this.createdAt,
      this.cancelable});

  String base;
  String baseAmount;
  double minVolume;
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
    order = extractStartedAtFromSwap(other.result).compareTo(createdAt);
    if (order == 0)
      order = createdAt.compareTo(extractStartedAtFromSwap(other.result));

    return order;
  }
}

enum OrderType { MAKER, TAKER }
