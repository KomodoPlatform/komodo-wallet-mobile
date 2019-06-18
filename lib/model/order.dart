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
}

enum OrderType{
  MAKER,
  TAKER
}