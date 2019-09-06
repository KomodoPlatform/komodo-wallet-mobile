// To parse this JSON data, do
//
//     final disableCoin = disableCoinFromJson(jsonString);

import 'dart:convert';

DisableCoin disableCoinFromJson(String str) =>
    DisableCoin.fromJson(json.decode(str));

String disableCoinToJson(DisableCoin data) => json.encode(data.toJson());

class DisableCoin {
  DisableCoin({
    this.result,
  });

  factory DisableCoin.fromJson(Map<String, dynamic> json) => DisableCoin(
        result: Result.fromJson(json['result']),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson(),
      };
}

class Result {
  Result({
    this.cancelledOrders,
    this.coin,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        cancelledOrders:
            List<String>.from(json['cancelled_orders'].map((dynamic x) => x)),
        coin: json['coin'],
      );

  List<String> cancelledOrders;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cancelled_orders':
            List<dynamic>.from(cancelledOrders.map<dynamic>((String x) => x)),
        'coin': coin,
      };
}
