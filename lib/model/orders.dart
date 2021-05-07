// To parse this JSON data, do
//
//     final orders = ordersFromJson(jsonString);

import 'dart:convert';

Orders ordersFromJson(String str) => Orders.fromJson(json.decode(str));

String ordersToJson(Orders data) => json.encode(data.toJson());

class Orders {
  Orders({
    this.result,
  });

  factory Orders.fromJson(Map<String, dynamic> json) => Orders(
        result: Result.fromJson(json['result']) ?? Result(),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson() ?? '',
      };
}

class Result {
  Result({
    this.makerOrders,
    this.takerOrders,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        makerOrders: Map<dynamic, dynamic>.from(json['maker_orders']).map(
                (dynamic k, dynamic v) =>
                    MapEntry<String, MakerOrder>(k, MakerOrder.fromJson(v))) ??
            <String, MakerOrder>{},
        takerOrders: Map<dynamic, dynamic>.from(json['taker_orders']).map(
                (dynamic k, dynamic v) =>
                    MapEntry<String, TakerOrder>(k, TakerOrder.fromJson(v))) ??
            <String, TakerOrder>{},
      );

  Map<String, MakerOrder> makerOrders;
  Map<String, TakerOrder> takerOrders;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'maker_orders': Map<dynamic, dynamic>.from(makerOrders)
                .map<dynamic, dynamic>((dynamic k, dynamic v) =>
                    MapEntry<String, dynamic>(k, v.toJson())) ??
            <String, MakerOrder>{},
        'taker_orders': Map<dynamic, dynamic>.from(takerOrders)
                .map<dynamic, dynamic>((dynamic k, dynamic v) =>
                    MapEntry<String, dynamic>(k, v.toJson())) ??
            <String, TakerOrder>{},
      };
}

class MakerOrder {
  MakerOrder({
    this.base,
    this.createdAt,
    this.availableAmount,
    this.cancellable,
    this.matches,
    this.maxBaseVol,
    this.minBaseVol,
    this.price,
    this.rel,
    this.startedSwaps,
    this.uuid,
  });

  factory MakerOrder.fromJson(Map<String, dynamic> json) => MakerOrder(
        base: json['base'] ?? '',
        createdAt: json['created_at'] ?? 0,
        availableAmount: json['available_amount'] ?? '',
        cancellable: json['cancellable'] ?? false,
        matches: Map<String, dynamic>.from(json['matches']).map(
                (dynamic k, dynamic v) =>
                    MapEntry<String, Match>(k, Match.fromJson(v))) ??
            <String, Match>{},
        maxBaseVol: json['max_base_vol'] ?? '',
        minBaseVol: json['min_base_vol'] ?? '',
        price: json['price'] ?? '',
        rel: json['rel'] ?? '',
        startedSwaps: List<String>.from(
                json['started_swaps'].map<dynamic>((dynamic x) => x)) ??
            <String>[],
        uuid: json['uuid'] ?? '',
      );

  String base;
  int createdAt;
  String availableAmount;
  bool cancellable;
  Map<String, Match> matches;
  String maxBaseVol;
  String minBaseVol;
  String price;
  String rel;
  List<String> startedSwaps;
  String uuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'base': base ?? '',
        'created_at': createdAt ?? 0,
        'available_amount': availableAmount ?? '',
        'cancellable': cancellable ?? false,
        'matches': Map<dynamic, dynamic>.from(matches).map<dynamic, dynamic>(
                (dynamic k, dynamic v) =>
                    MapEntry<String, dynamic>(k, v.toJson())) ??
            <String, Match>{},
        'max_base_vol': maxBaseVol ?? '',
        'min_base_vol': minBaseVol ?? '',
        'price': price ?? '',
        'rel': rel ?? '',
        'started_swaps':
            List<dynamic>.from(startedSwaps.map<dynamic>((dynamic x) => x)) ??
                <String>[],
        'uuid': uuid ?? '',
      };
}

// AG: The name clashes with regular expressions `Match`, should rename.
class Match {
  Match({
    this.connect,
    this.connected,
    this.lastUpdated,
    this.request,
    this.reserved,
  });

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        connect:
            json['connect'] == null ? null : Connect.fromJson(json['connect']),
        connected: json['connected'] == null
            ? null
            : Connect.fromJson(json['connected']),
        lastUpdated: json['last_updated'] ?? 0,
        request:
            json['request'] == null ? null : Request.fromJson(json['request']),
        reserved: json['reserved'] == null
            ? null
            : Request.fromJson(json['reserved']),
      );

  Connect connect;
  Connect connected;
  int lastUpdated;
  Request request;
  Request reserved;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'connect': connect == null ? null : connect.toJson(),
        'connected': connected == null ? null : connected.toJson(),
        'last_updated': lastUpdated ?? 0,
        'request': request == null ? null : request.toJson(),
        'reserved': reserved == null ? null : reserved.toJson(),
      };
}

class Connect {
  Connect({
    this.destPubKey,
    this.makerOrderUuid,
    this.method,
    this.senderPubkey,
    this.takerOrderUuid,
  });

  factory Connect.fromJson(Map<String, dynamic> json) => Connect(
        destPubKey: json['dest_pub_key'] ?? '',
        makerOrderUuid: json['maker_order_uuid'] ?? '',
        method: json['method'] ?? '',
        senderPubkey: json['sender_pubkey'] ?? '',
        takerOrderUuid: json['taker_order_uuid'] ?? '',
      );

  String destPubKey;
  String makerOrderUuid;
  String method;
  String senderPubkey;
  String takerOrderUuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dest_pub_key': destPubKey ?? '',
        'maker_order_uuid': makerOrderUuid ?? '',
        'method': method ?? '',
        'sender_pubkey': senderPubkey ?? '',
        'taker_order_uuid': takerOrderUuid ?? '',
      };
}

class Request {
  Request({
    this.action,
    this.base,
    this.baseAmount,
    this.destPubKey,
    this.method,
    this.rel,
    this.relAmount,
    this.senderPubkey,
    this.uuid,
    this.makerOrderUuid,
    this.takerOrderUuid,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
        action: json['action'] ?? '',
        base: json['base'] ?? '',
        baseAmount: json['base_amount'] ?? '',
        destPubKey: json['dest_pub_key'] ?? '',
        method: json['method'] ?? '',
        rel: json['rel'] ?? '',
        relAmount: json['rel_amount'] ?? '',
        senderPubkey: json['sender_pubkey'] ?? '',
        uuid: json['uuid'] ?? '',
        makerOrderUuid: json['maker_order_uuid'] ?? '',
        takerOrderUuid: json['taker_order_uuid'] ?? '',
      );

  String action;
  String base;
  String baseAmount;
  String destPubKey;
  String method;
  String rel;
  String relAmount;
  String senderPubkey;
  String uuid;
  String makerOrderUuid;
  String takerOrderUuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'action': action ?? '',
        'base': base ?? '',
        'base_amount': baseAmount ?? '',
        'dest_pub_key': destPubKey ?? '',
        'method': method ?? '',
        'rel': rel ?? '',
        'rel_amount': relAmount ?? '',
        'sender_pubkey': senderPubkey ?? '',
        'uuid': uuid ?? '',
        'maker_order_uuid': makerOrderUuid ?? '',
        'taker_order_uuid': takerOrderUuid ?? '',
      };
}

class TakerOrder {
  TakerOrder({
    this.createdAt,
    this.cancellable,
    this.matches,
    this.request,
  });

  factory TakerOrder.fromJson(Map<String, dynamic> json) => TakerOrder(
        createdAt: json['created_at'] ?? 0,
        cancellable: json['cancellable'] ?? false,
        matches: json['matches'] == null
            ? null
            : Map<dynamic, dynamic>.from(json['matches']).map(
                (dynamic k, dynamic v) =>
                    MapEntry<String, Match>(k, Match.fromJson(v))),
        request: Request.fromJson(json['request']) ?? Request(),
      );

  int createdAt;
  bool cancellable;
  Map<String, Match> matches;
  Request request;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'created_at': createdAt ?? 0,
        'cancellable': cancellable ?? false,
        'matches': matches == null
            ? null
            : Map<dynamic, dynamic>.from(matches).map<dynamic, dynamic>(
                (dynamic k, dynamic v) =>
                    MapEntry<String, dynamic>(k, v.toJson())),
        'request': request.toJson() ?? Request(),
      };
}

class EnumValues<T> {
  EnumValues(this.map);

  Map<String, T> map;
  Map<T, String> reverseMap;

  Map<T, String> get reverse {
    reverseMap ??= map.map((String k, T v) => MapEntry<dynamic, dynamic>(v, k));
    return reverseMap;
  }
}
