import 'dart:convert';
import '../utils/utils.dart';
import 'package:rational/rational.dart';

String getTradePreimage2ToJson(GetTradePreimage2 data) =>
    json.encode(data.toJson());

class GetTradePreimage2 {
  GetTradePreimage2({
    this.userpass,
    this.method = 'trade_preimage',
    this.mmrpc = '2.0',
    this.base,
    this.rel,
    this.swapMethod,
    this.volume,
    this.price,
    this.max,
  });

  factory GetTradePreimage2.fromJson(Map<String, dynamic> json) {
    return GetTradePreimage2(
      userpass: json['userpass'] ?? '',
      method: json['method'] ?? '',
      mmrpc: json['mmrpc'] ?? '',
      base: json['params']['base'] ?? '',
      rel: json['params']['rel'] ?? '',
      swapMethod: json['params']['swap_method'] ?? '',
      volume: json['params']['volume'] == null
          ? null
          : fract2rat(json['params']['volume']),
      price: json['params']['price'] == null
          ? null
          : fract2rat(json['params']['price']),
      max: json['params']['max'] ?? false,
    );
  }

  String? userpass;
  String method;
  String mmrpc;
  String? base;
  String? rel;
  String? swapMethod; // 'buy', 'sell' or 'setprice'
  Rational? volume;
  Rational? price;
  bool? max;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'userpass': userpass ?? '',
      'method': method ?? '',
      'mmrpc': mmrpc ?? '',
      'params': {
        'base': base,
        'rel': rel,
        'swap_method': swapMethod,
        if (volume != null)
          'volume': {
            'numer': volume!.numerator.toString(),
            'denom': volume!.denominator.toString(),
          },
        if (price != null)
          'price': {
            'numer': price!.numerator.toString(),
            'denom': price!.denominator.toString(),
          },
        if (max != null) 'max': max,
      },
    };

    return json;
  }
}
