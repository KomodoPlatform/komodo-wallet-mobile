class Order {
  String base;
  String baseAmount;
  String rel;
  OrderType orderType;
  String relAmount;
  String uuid;
  int createdAt;

  Order({this.base, this.orderType, this.rel, this.relAmount, this.uuid, this.baseAmount, this.createdAt});
}

enum OrderType{
  MAKER,
  TAKER
}