// To parse this JSON data, do
//
//     final orders = ordersFromJson(jsonString);

import 'dart:convert';

Orders ordersFromJson(String str) => Orders.fromJson(json.decode(str));

String ordersToJson(Orders data) => json.encode(data.toJson());

class Orders {
    Result result;

    Orders({
        this.result,
    });

    factory Orders.fromJson(Map<String, dynamic> json) => new Orders(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? null : result.toJson(),
    };
}

class Result {
    Map<String, MakerOrder> makerOrders;
    Map<String, TakerOrder> takerOrders;

    Result({
        this.makerOrders,
        this.takerOrders,
    });

    factory Result.fromJson(Map<String, dynamic> json) => new Result(
        makerOrders: json["maker_orders"] == null ? null : new Map.from(json["maker_orders"]).map((k, v) => new MapEntry<String, MakerOrder>(k, MakerOrder.fromJson(v))),
        takerOrders: json["taker_orders"] == null ? null : new Map.from(json["taker_orders"]).map((k, v) => new MapEntry<String, TakerOrder>(k, TakerOrder.fromJson(v))),
    );

    Map<String, dynamic> toJson() => {
        "maker_orders": makerOrders == null ? null : new Map.from(makerOrders).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "taker_orders": takerOrders == null ? null : new Map.from(takerOrders).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
    };
}

class MakerOrder {
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

    factory MakerOrder.fromJson(Map<String, dynamic> json) => new MakerOrder(
        base: json["base"] == null ? null : json["base"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        availableAmount: json["available_amount"] == null ? null : json["available_amount"],
        cancellable: json["cancellable"] == null ? null : json["cancellable"],
        matches: json["matches"] == null ? null : new Map.from(json["matches"]).map((k, v) => new MapEntry<String, Match>(k, Match.fromJson(v))),
        maxBaseVol: json["max_base_vol"] == null ? null : json["max_base_vol"],
        minBaseVol: json["min_base_vol"] == null ? null : json["min_base_vol"],
        price: json["price"] == null ? null : json["price"],
        rel: json["rel"] == null ? null : json["rel"],
        startedSwaps: json["started_swaps"] == null ? null : new List<String>.from(json["started_swaps"].map((x) => x)),
        uuid: json["uuid"] == null ? null : json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "base": base == null ? null : base,
        "created_at": createdAt == null ? null : createdAt,
        "available_amount": availableAmount == null ? null : availableAmount,
        "cancellable": cancellable == null ? null : cancellable,
        "matches": matches == null ? null : new Map.from(matches).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "max_base_vol": maxBaseVol == null ? null : maxBaseVol,
        "min_base_vol": minBaseVol == null ? null : minBaseVol,
        "price": price == null ? null : price,
        "rel": rel == null ? null : rel,
        "started_swaps": startedSwaps == null ? null : new List<dynamic>.from(startedSwaps.map((x) => x)),
        "uuid": uuid == null ? null : uuid,
    };
}

class Match {
    Connect connect;
    Connect connected;
    int lastUpdated;
    Request request;
    Request reserved;

    Match({
        this.connect,
        this.connected,
        this.lastUpdated,
        this.request,
        this.reserved,
    });

    factory Match.fromJson(Map<String, dynamic> json) => new Match(
        connect: json["connect"] == null ? null : Connect.fromJson(json["connect"]),
        connected: json["connected"] == null ? null : Connect.fromJson(json["connected"]),
        lastUpdated: json["last_updated"] == null ? null : json["last_updated"],
        request: json["request"] == null ? null : Request.fromJson(json["request"]),
        reserved: json["reserved"] == null ? null : Request.fromJson(json["reserved"]),
    );

    Map<String, dynamic> toJson() => {
        "connect": connect == null ? null : connect.toJson(),
        "connected": connected == null ? null : connected.toJson(),
        "last_updated": lastUpdated == null ? null : lastUpdated,
        "request": request == null ? null : request.toJson(),
        "reserved": reserved == null ? null : reserved.toJson(),
    };
}

class Connect {
    String destPubKey;
    String makerOrderUuid;
    String method;
    String senderPubkey;
    String takerOrderUuid;

    Connect({
        this.destPubKey,
        this.makerOrderUuid,
        this.method,
        this.senderPubkey,
        this.takerOrderUuid,
    });

    factory Connect.fromJson(Map<String, dynamic> json) => new Connect(
        destPubKey: json["dest_pub_key"] == null ? null : json["dest_pub_key"],
        makerOrderUuid: json["maker_order_uuid"] == null ? null : json["maker_order_uuid"],
        method: json["method"] == null ? null : json["method"],
        senderPubkey: json["sender_pubkey"] == null ? null : json["sender_pubkey"],
        takerOrderUuid: json["taker_order_uuid"] == null ? null : json["taker_order_uuid"],
    );

    Map<String, dynamic> toJson() => {
        "dest_pub_key": destPubKey == null ? null : destPubKey,
        "maker_order_uuid": makerOrderUuid == null ? null : makerOrderUuid,
        "method": method == null ? null : method,
        "sender_pubkey": senderPubkey == null ? null : senderPubkey,
        "taker_order_uuid": takerOrderUuid == null ? null : takerOrderUuid,
    };
}


class Request {
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

    factory Request.fromJson(Map<String, dynamic> json) => new Request(
        action: json["action"] == null ? null : json["action"],
        base: json["base"] == null ? null : json["base"],
        baseAmount: json["base_amount"] == null ? null : json["base_amount"],
        destPubKey: json["dest_pub_key"] == null ? null : json["dest_pub_key"],
        method: json["method"] == null ? null : json["method"],
        rel: json["rel"] == null ? null : json["rel"],
        relAmount: json["rel_amount"] == null ? null : json["rel_amount"],
        senderPubkey: json["sender_pubkey"] == null ? null : json["sender_pubkey"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        makerOrderUuid: json["maker_order_uuid"] == null ? null : json["maker_order_uuid"],
        takerOrderUuid: json["taker_order_uuid"] == null ? null : json["taker_order_uuid"],
    );

    Map<String, dynamic> toJson() => {
        "action": action == null ? null : action,
        "base": base == null ? null : base,
        "base_amount": baseAmount == null ? null : baseAmount,
        "dest_pub_key": destPubKey == null ? null : destPubKey,
        "method": method == null ? null : method,
        "rel": rel == null ? null : rel,
        "rel_amount": relAmount == null ? null : relAmount,
        "sender_pubkey": senderPubkey == null ? null : senderPubkey,
        "uuid": uuid == null ? null : uuid,
        "maker_order_uuid": makerOrderUuid == null ? null : makerOrderUuid,
        "taker_order_uuid": takerOrderUuid == null ? null : takerOrderUuid,
    };
}

class TakerOrder {
    int createdAt;
    bool cancellable;
    Map<String, Match> matches;
    Request request;

    TakerOrder({
        this.createdAt,
        this.cancellable,
        this.matches,
        this.request,
    });

    factory TakerOrder.fromJson(Map<String, dynamic> json) => new TakerOrder(
        createdAt: json["created_at"] == null ? null : json["created_at"],
        cancellable: json["cancellable"] == null ? null : json["cancellable"],
        matches: json["matches"] == null ? null : new Map.from(json["matches"]).map((k, v) => new MapEntry<String, Match>(k, Match.fromJson(v))),
        request: json["request"] == null ? null : Request.fromJson(json["request"]),
    );

    Map<String, dynamic> toJson() => {
        "created_at": createdAt == null ? null : createdAt,
        "cancellable": cancellable == null ? null : cancellable,
        "matches": matches == null ? null : new Map.from(matches).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "request": request == null ? null : request.toJson(),
    };
}

class EnumValues<T> {
    Map<String, T> map;
    Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        if (reverseMap == null) {
            reverseMap = map.map((k, v) => new MapEntry(v, k));
        }
        return reverseMap;
    }
}
