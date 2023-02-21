import 'dart:convert';

String getTradePreimageToJson(GetTradePreimage data) =>
    json.encode(data.toJson());

class GetTradePreimage {
  GetTradePreimage({
    this.userpass,
    this.method = 'trade_preimage',
    this.base,
    this.rel,
    this.swapMethod,
    this.volume,
    this.price,
    this.max,
  });

  factory GetTradePreimage.fromJson(Map<String, dynamic>? json) {
    return GetTradePreimage(
      userpass: json?['userpass'] ?? '',
      method: json?['method'] ?? '',
      base: json?['base'] ?? '',
      rel: json?['rel'] ?? '',
      swapMethod: json?['swap_method'] ?? '',
      volume: json?['volume'] ?? '',
      price: json?['price'] ?? '',
      max: json?['max'] ?? false,
    );
  }

  String? userpass;
  String method;
  String? base;
  String? rel;
  String? swapMethod; // 'buy', 'sell' or 'setprice'
  String? volume;
  String? price;
  bool? max;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'base': base,
        'rel': rel,
        'swap_method': swapMethod,
        'volume': volume,
        'price': price,
        if (max != null) 'max': max,
      };
}
