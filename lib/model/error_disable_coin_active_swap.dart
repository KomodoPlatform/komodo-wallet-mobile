// To parse this JSON data, do
//
//     final errorDisableCoinActiveSwap = errorDisableCoinActiveSwapFromJson(jsonString);

import 'dart:convert';

ErrorDisableCoinActiveSwap errorDisableCoinActiveSwapFromJson(String str) =>
    ErrorDisableCoinActiveSwap.fromJson(json.decode(str));

String errorDisableCoinActiveSwapToJson(ErrorDisableCoinActiveSwap data) =>
    json.encode(data.toJson());

class ErrorDisableCoinActiveSwap {
  ErrorDisableCoinActiveSwap({
    this.error,
    this.swaps,
  });

  factory ErrorDisableCoinActiveSwap.fromJson(Map<String, dynamic> json) =>
      ErrorDisableCoinActiveSwap(
        error: json['error'],
        swaps: List<String>.from(json['swaps'].map((dynamic x) => x)),
      );

  String error;
  List<String> swaps;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'error': error,
        'swaps': List<dynamic>.from(swaps.map<dynamic>((String x) => x)),
      };
}
