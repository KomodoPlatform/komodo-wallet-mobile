// To parse this JSON data, do
//
//     final swap = swapFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/uuid.dart';

enum Status {
  ORDER_MATCHING,
  ORDER_MATCHED,
  SWAP_ONGOING,
  SWAP_SUCCESSFUL,
  TIME_OUT
}

Swap swapFromJson(String str) {
  final jsonData = json.decode(str);
  return Swap.fromJson(jsonData);
}

String swapToJson(Swap data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Swap {
  ResultSwap result;
  Status status;

  Swap({this.result, this.status});

  factory Swap.fromJson(Map<String, dynamic> json) => new Swap(
        result: ResultSwap.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };


  int compareToSwap(Swap other) {
    int order = other.result.myInfo.startedAt.compareTo(result.myInfo.startedAt);
    if (order == 0) order = result.myInfo.startedAt.compareTo(other.result.myInfo.startedAt);
    return order;
  }

  int compareToOrder(Order other) {
    int order = other.createdAt.compareTo(result.myInfo.startedAt);
    if (order == 0) order = result.myInfo.startedAt.compareTo(other.createdAt);
    return order;
  }

}