// To parse this JSON data, do
//
//     final swap = swapFromJson(jsonString);

import 'dart:convert';

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
  Result result;
  Status status;
  Uuid uuid;

  Swap({this.result, this.status, this.uuid});

  factory Swap.fromJson(Map<String, dynamic> json) => new Swap(
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };

  int compareTo(Swap other) {
    int order = other.uuid.timeStart.compareTo(uuid.timeStart);
    if (order == 0) order = uuid.timeStart.compareTo(other.uuid.timeStart);
    return order;
  }
}

class Result {
  List<String> errorEvents;
  List<EventElement> events;
  List<String> successEvents;
  String type;
  String uuid;

  Result({
    this.errorEvents,
    this.events,
    this.successEvents,
    this.type,
    this.uuid,
  });

  factory Result.fromJson(Map<String, dynamic> json) => new Result(
        errorEvents: new List<String>.from(json["error_events"].map((x) => x)),
        events: new List<EventElement>.from(
            json["events"].map((x) => EventElement.fromJson(x))),
        successEvents:
            new List<String>.from(json["success_events"].map((x) => x)),
        type: json["type"],
        uuid: json["uuid"],
      );

  Map<String, dynamic> toJson() => {
        "error_events": new List<dynamic>.from(errorEvents.map((x) => x)),
        "events": new List<dynamic>.from(events.map((x) => x.toJson())),
        "success_events": new List<dynamic>.from(successEvents.map((x) => x)),
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
  dynamic data;
  String type;

  EventEvent({
    this.data,
    this.type,
  });

  factory EventEvent.fromJson(Map<String, dynamic> json) => new EventEvent(
        data: json["data"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "type": type,
      };
}

class DatumClass {
  int amount;
  dynamic feeDetails;
  String from;
  String to;
  String txHash;
  String txHex;

  DatumClass({
    this.amount,
    this.feeDetails,
    this.from,
    this.to,
    this.txHash,
    this.txHex,
  });

  factory DatumClass.fromJson(Map<String, dynamic> json) => new DatumClass(
        amount: json["amount"],
        feeDetails: json["fee_details"],
        from: json["from"],
        to: json["to"],
        txHash: json["tx_hash"],
        txHex: json["tx_hex"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "fee_details": feeDetails,
        "from": from,
        "to": to,
        "tx_hash": txHash,
        "tx_hex": txHex,
      };
}

class DataClass {
  int lockDuration;
  String maker;
  String makerAmount;
  String makerCoin;
  int makerPaymentConfirmations;
  int makerPaymentWait;
  String myPersistentPub;
  int startedAt;
  String takerAmount;
  String takerCoin;
  int takerPaymentConfirmations;
  int takerPaymentLock;
  String uuid;
  int amount;
  dynamic feeDetails;
  String from;
  String to;
  String txHash;
  String txHex;

  DataClass({
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
    this.amount,
    this.feeDetails,
    this.from,
    this.to,
    this.txHash,
    this.txHex,
  });

  factory DataClass.fromJson(Map<String, dynamic> json) => new DataClass(
        lockDuration:
            json["lock_duration"] == null ? null : json["lock_duration"],
        maker: json["maker"] == null ? null : json["maker"],
        makerAmount: json["maker_amount"] == null ? null : json["maker_amount"],
        makerCoin: json["maker_coin"] == null ? null : json["maker_coin"],
        makerPaymentConfirmations: json["maker_payment_confirmations"] == null
            ? null
            : json["maker_payment_confirmations"],
        makerPaymentWait: json["maker_payment_wait"] == null
            ? null
            : json["maker_payment_wait"],
        myPersistentPub: json["my_persistent_pub"] == null
            ? null
            : json["my_persistent_pub"],
        startedAt: json["started_at"] == null ? null : json["started_at"],
        takerAmount: json["taker_amount"] == null ? null : json["taker_amount"],
        takerCoin: json["taker_coin"] == null ? null : json["taker_coin"],
        takerPaymentConfirmations: json["taker_payment_confirmations"] == null
            ? null
            : json["taker_payment_confirmations"],
        takerPaymentLock: json["taker_payment_lock"] == null
            ? null
            : json["taker_payment_lock"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        amount: json["amount"] == null ? null : json["amount"],
        feeDetails: json["fee_details"],
        from: json["from"] == null ? null : json["from"],
        to: json["to"] == null ? null : json["to"],
        txHash: json["tx_hash"] == null ? null : json["tx_hash"],
        txHex: json["tx_hex"] == null ? null : json["tx_hex"],
      );

  Map<String, dynamic> toJson() => {
        "lock_duration": lockDuration == null ? null : lockDuration,
        "maker": maker == null ? null : maker,
        "maker_amount": makerAmount == null ? null : makerAmount,
        "maker_coin": makerCoin == null ? null : makerCoin,
        "maker_payment_confirmations": makerPaymentConfirmations == null
            ? null
            : makerPaymentConfirmations,
        "maker_payment_wait":
            makerPaymentWait == null ? null : makerPaymentWait,
        "my_persistent_pub": myPersistentPub == null ? null : myPersistentPub,
        "started_at": startedAt == null ? null : startedAt,
        "taker_amount": takerAmount == null ? null : takerAmount,
        "taker_coin": takerCoin == null ? null : takerCoin,
        "taker_payment_confirmations": takerPaymentConfirmations == null
            ? null
            : takerPaymentConfirmations,
        "taker_payment_lock":
            takerPaymentLock == null ? null : takerPaymentLock,
        "uuid": uuid == null ? null : uuid,
        "amount": amount == null ? null : amount,
        "fee_details": feeDetails,
        "from": from == null ? null : from,
        "to": to == null ? null : to,
        "tx_hash": txHash == null ? null : txHash,
        "tx_hex": txHex == null ? null : txHex,
      };
}
