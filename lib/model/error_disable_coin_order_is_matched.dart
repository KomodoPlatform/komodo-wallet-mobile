// To parse this JSON data, do
//
//     final errorDisableCoinOrderIsMatched = errorDisableCoinOrderIsMatchedFromJson(jsonString);

import 'dart:convert';

ErrorDisableCoinOrderIsMatched errorDisableCoinOrderIsMatchedFromJson(String str) => ErrorDisableCoinOrderIsMatched.fromJson(json.decode(str));

String errorDisableCoinOrderIsMatchedToJson(ErrorDisableCoinOrderIsMatched data) => json.encode(data.toJson());

class ErrorDisableCoinOrderIsMatched {

    ErrorDisableCoinOrderIsMatched({
        this.error,
        this.orders,
    });

    factory ErrorDisableCoinOrderIsMatched.fromJson(Map<String, dynamic> json) => ErrorDisableCoinOrderIsMatched(
        error: json['error'],
        orders: OrdersString.fromJson(json['orders']),
    );

    String error;
    OrdersString orders;


    Map<String, dynamic> toJson() => <String, dynamic>{
        'error': error,
        'orders': orders.toJson(),
    };
}

class OrdersString {
    OrdersString({
        this.matching,
        this.cancelled,
    });

    factory OrdersString.fromJson(Map<String, dynamic> json) => OrdersString(
        matching: List<String>.from(json['matching'].map((dynamic x) => x)),
        cancelled: List<String>.from(json['cancelled'].map((dynamic x) => x)),
    );

    List<String> matching;
    List<String> cancelled;


    Map<String, dynamic> toJson() => <String, dynamic>{
        'matching': List<dynamic>.from(matching.map<dynamic>((String x) => x)),
        'cancelled': List<dynamic>.from(cancelled.map<dynamic>((String x) => x)),
    };
}
