// To parse this JSON data, do
//
//     final swap = swapFromJson(jsonString);

import 'dart:convert';

enum Status {
  ORDER_MATCHING,
  ORDER_MATCHED,
  SWAP_ONGOING,
  SWAP_SUCCESSFULL
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
    Result result;
    Status status;
    String pubkey;

    Swap({
        this.result,
        this.status,
        this.pubkey
    });

    factory Swap.fromJson(Map<String, dynamic> json) => new Swap(
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result.toJson(),
    };
}

class Result {
    List<EventElement> events;
    String type;
    String uuid;

    Result({
        this.events,
        this.type,
        this.uuid,
    });

    factory Result.fromJson(Map<String, dynamic> json) => new Result(
        events: new List<EventElement>.from(json["events"].map((x) => EventElement.fromJson(x))),
        type: json["type"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "events": new List<dynamic>.from(events.map((x) => x.toJson())),
        "type": type,
        "uuid": uuid,
    };
}

class EventElement {
    EventEvent event;
    int timestamp;

    EventElement({
        this.event,
        this.timestamp,
    });

    factory EventElement.fromJson(Map<String, dynamic> json) => new EventElement(
        event: EventEvent.fromJson(json["event"]),
        timestamp: json["timestamp"],
    );

    Map<String, dynamic> toJson() => {
        "event": event.toJson(),
        "timestamp": timestamp,
    };
}

class EventEvent {
    Data data;
    String type;

    EventEvent({
        this.data,
        this.type,
    });

    factory EventEvent.fromJson(Map<String, dynamic> json) => new EventEvent(
        data: Data.fromJson(json["data"]),
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "type": type,
    };
}

class Data {
    int lockDuration;
    String maker;
    int makerAmount;
    String makerCoin;
    int makerPaymentConfirmations;
    int makerPaymentWait;
    String myPersistentPub;
    int startedAt;
    int takerAmount;
    String takerCoin;
    int takerPaymentConfirmations;
    int takerPaymentLock;
    String uuid;

    Data({
        this.lockDuration,
        this.maker,
        this.makerAmount,
        this.makerCoin,
        this.makerPaymentConfirmations,
        this.makerPaymentWait,
        this.myPersistentPub,
        this.startedAt,
        this.takerAmount,
        this.takerCoin,
        this.takerPaymentConfirmations,
        this.takerPaymentLock,
        this.uuid,
    });

    factory Data.fromJson(Map<String, dynamic> json) => new Data(
        lockDuration: json["lock_duration"],
        maker: json["maker"],
        makerAmount: json["maker_amount"],
        makerCoin: json["maker_coin"],
        makerPaymentConfirmations: json["maker_payment_confirmations"],
        makerPaymentWait: json["maker_payment_wait"],
        myPersistentPub: json["my_persistent_pub"],
        startedAt: json["started_at"],
        takerAmount: json["taker_amount"],
        takerCoin: json["taker_coin"],
        takerPaymentConfirmations: json["taker_payment_confirmations"],
        takerPaymentLock: json["taker_payment_lock"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "lock_duration": lockDuration,
        "maker": maker,
        "maker_amount": makerAmount,
        "maker_coin": makerCoin,
        "maker_payment_confirmations": makerPaymentConfirmations,
        "maker_payment_wait": makerPaymentWait,
        "my_persistent_pub": myPersistentPub,
        "started_at": startedAt,
        "taker_amount": takerAmount,
        "taker_coin": takerCoin,
        "taker_payment_confirmations": takerPaymentConfirmations,
        "taker_payment_lock": takerPaymentLock,
        "uuid": uuid,
    };
}
