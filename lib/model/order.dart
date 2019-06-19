class Order {
  String base;
  String baseAmount;
  String rel;
  OrderType orderType;
  String relAmount;
  String uuid;
  int createdAt;
  bool cancelable;

  Order({this.base, this.orderType, this.rel, this.relAmount, this.uuid, this.baseAmount, this.createdAt, this.cancelable});

  int compareTo(Order other) {
    int order = other.createdAt.compareTo(createdAt);
    if (order == 0) order = createdAt.compareTo(other.createdAt);
    return order;
  }
}

enum OrderType{
  MAKER,
  TAKER
}