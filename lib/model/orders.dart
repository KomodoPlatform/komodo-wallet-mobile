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
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result.toJson(),
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
        makerOrders: new Map.from(json["maker_orders"]).map((k, v) => new MapEntry<String, MakerOrder>(k, MakerOrder.fromJson(v))),
        takerOrders: new Map.from(json["taker_orders"]).map((k, v) => new MapEntry<String, TakerOrder>(k, TakerOrder.fromJson(v))),
    );

    Map<String, dynamic> toJson() => {
        "maker_orders": new Map.from(makerOrders).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "taker_orders": new Map.from(takerOrders).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
    };
}

class MakerOrder {
    String base;
    int createdAt;
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
        this.matches,
        this.maxBaseVol,
        this.minBaseVol,
        this.price,
        this.rel,
        this.startedSwaps,
        this.uuid,
    });

    factory MakerOrder.fromJson(Map<String, dynamic> json) => new MakerOrder(
        base: json["base"],
        createdAt: json["created_at"],
        matches: new Map.from(json["matches"]).map((k, v) => new MapEntry<String, Match>(k, Match.fromJson(v))),
        maxBaseVol: json["max_base_vol"],
        minBaseVol: json["min_base_vol"],
        price: json["price"],
        rel: json["rel"],
        startedSwaps: new List<String>.from(json["started_swaps"].map((x) => x)),
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "base": base,
        "created_at": createdAt,
        "matches": new Map.from(matches).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "max_base_vol": maxBaseVol,
        "min_base_vol": minBaseVol,
        "price": price,
        "rel": rel,
        "started_swaps": new List<dynamic>.from(startedSwaps.map((x) => x)),
        "uuid": uuid,
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
        connect: Connect.fromJson(json["connect"]),
        connected: Connect.fromJson(json["connected"]),
        lastUpdated: json["last_updated"],
        request: json["request"] == null ? null : Request.fromJson(json["request"]),
        reserved: Request.fromJson(json["reserved"]),
    );

    Map<String, dynamic> toJson() => {
        "connect": connect.toJson(),
        "connected": connected.toJson(),
        "last_updated": lastUpdated,
        "request": request == null ? null : request.toJson(),
        "reserved": reserved.toJson(),
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
        destPubKey: json["dest_pub_key"],
        makerOrderUuid: json["maker_order_uuid"],
        method: json["method"],
        senderPubkey: json["sender_pubkey"],
        takerOrderUuid: json["taker_order_uuid"],
    );

    Map<String, dynamic> toJson() => {
        "dest_pub_key": destPubKey,
        "maker_order_uuid": makerOrderUuid,
        "method": method,
        "sender_pubkey": senderPubkey,
        "taker_order_uuid": takerOrderUuid,
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
        base: json["base"],
        baseAmount: json["base_amount"],
        destPubKey: json["dest_pub_key"],
        method: json["method"],
        rel: json["rel"],
        relAmount: json["rel_amount"],
        senderPubkey: json["sender_pubkey"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        makerOrderUuid: json["maker_order_uuid"] == null ? null : json["maker_order_uuid"],
        takerOrderUuid: json["taker_order_uuid"] == null ? null : json["taker_order_uuid"],
    );

    Map<String, dynamic> toJson() => {
        "action": action == null ? null : action,
        "base": base,
        "base_amount": baseAmount,
        "dest_pub_key": destPubKey,
        "method": method,
        "rel": rel,
        "rel_amount": relAmount,
        "sender_pubkey": senderPubkey,
        "uuid": uuid == null ? null : uuid,
        "maker_order_uuid": makerOrderUuid == null ? null : makerOrderUuid,
        "taker_order_uuid": takerOrderUuid == null ? null : takerOrderUuid,
    };
}

class TakerOrder {
    int createdAt;
    Map<String, Match> matches;
    Request request;

    TakerOrder({
        this.createdAt,
        this.matches,
        this.request,
    });

    factory TakerOrder.fromJson(Map<String, dynamic> json) => new TakerOrder(
        createdAt: json["created_at"],
        matches: new Map.from(json["matches"]).map((k, v) => new MapEntry<String, Match>(k, Match.fromJson(v))),
        request: Request.fromJson(json["request"]),
    );

    Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "matches": new Map.from(matches).map((k, v) => new MapEntry<String, dynamic>(k, v.toJson())),
        "request": request.toJson(),
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
