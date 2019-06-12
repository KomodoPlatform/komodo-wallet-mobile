// To parse this JSON data, do
//
//     final recentSwaps = recentSwapsFromJson(jsonString);

import 'dart:convert';

RecentSwaps recentSwapsFromJson(String str) =>
    RecentSwaps.fromJson(json.decode(str));

String recentSwapsToJson(RecentSwaps data) => json.encode(data.toJson());

class RecentSwaps {
  Result result;

  RecentSwaps({
    this.result,
  });

  factory RecentSwaps.fromJson(Map<String, dynamic> json) => new RecentSwaps(
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };
}

class Result {
  dynamic fromUuid;
  int limit;
  int skipped;
  List<ResultSwap> swaps;
  int total;

  Result({
    this.fromUuid,
    this.limit,
    this.skipped,
    this.swaps,
    this.total,
  });

  factory Result.fromJson(Map<String, dynamic> json) => new Result(
        fromUuid: json["from_uuid"],
        limit: json["limit"],
        skipped: json["skipped"],
        swaps: new List<ResultSwap>.from(
            json["swaps"].map((x) => ResultSwap.fromJson(x))),
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "from_uuid": fromUuid,
        "limit": limit,
        "skipped": skipped,
        "swaps": new List<dynamic>.from(swaps.map((x) => x.toJson())),
        "total": total,
      };
}

class ResultSwap {
  List<String> errorEvents;
  List<EventElement> events;
  List<String> successEvents;
  String type;
  String uuid;
  MyInfo myInfo;

  ResultSwap({
    this.errorEvents,
    this.events,
    this.successEvents,
    this.type,
    this.uuid,
    this.myInfo,
  });

  factory ResultSwap.fromJson(Map<String, dynamic> json) => new ResultSwap(
        errorEvents: new List<String>.from(json["error_events"].map((x) => x)),
        events: new List<EventElement>.from(
            json["events"].map((x) => EventElement.fromJson(x))),
        successEvents:
            new List<String>.from(json["success_events"].map((x) => x)),
        myInfo: MyInfo.fromJson(json["my_info"]),
        type: json["type"],
        uuid: json["uuid"],
      );

  Map<String, dynamic> toJson() => {
        "error_events": new List<dynamic>.from(errorEvents.map((x) => x)),
        "events": new List<dynamic>.from(events.map((x) => x.toJson())),
        "success_events": new List<dynamic>.from(successEvents.map((x) => x)),
        "my_info": myInfo.toJson(),
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
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
        "type": type,
      };
}

class Data {
  int lockDuration;
  String maker;
  String makerAmount;
  String makerCoin;
  int makerCoinStartBlock;
  int makerPaymentConfirmations;
  int makerPaymentWait;
  String myPersistentPub;
  int startedAt;
  String takerAmount;
  String takerCoin;
  int takerCoinStartBlock;
  int takerPaymentConfirmations;
  int takerPaymentLock;
  String uuid;
  int makerPaymentLocktime;
  String makerPubkey;
  String secretHash;
  int blockHeight;
  String coin;
  FeeDetails feeDetails;
  List<String> from;
  String internalId;
  double myBalanceChange;
  double receivedByMe;
  double spentByMe;
  int timestamp;
  List<String> to;
  double totalAmount;
  String txHash;
  String txHex;
  String secret;
  Transaction transaction;

  Data({
    this.lockDuration,
    this.maker,
    this.makerAmount,
    this.makerCoin,
    this.makerCoinStartBlock,
    this.makerPaymentConfirmations,
    this.makerPaymentWait,
    this.myPersistentPub,
    this.startedAt,
    this.takerAmount,
    this.takerCoin,
    this.takerCoinStartBlock,
    this.takerPaymentConfirmations,
    this.takerPaymentLock,
    this.uuid,
    this.makerPaymentLocktime,
    this.makerPubkey,
    this.secretHash,
    this.blockHeight,
    this.coin,
    this.feeDetails,
    this.from,
    this.internalId,
    this.myBalanceChange,
    this.receivedByMe,
    this.spentByMe,
    this.timestamp,
    this.to,
    this.totalAmount,
    this.txHash,
    this.txHex,
    this.secret,
    this.transaction,
  });

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
        lockDuration:
            json["lock_duration"] == null ? null : json["lock_duration"],
        maker: json["maker"] == null ? null : json["maker"],
        makerAmount: json["maker_amount"] == null ? null : json["maker_amount"],
        makerCoin: json["maker_coin"] == null ? null : json["maker_coin"],
        makerCoinStartBlock: json["maker_coin_start_block"] == null
            ? null
            : json["maker_coin_start_block"],
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
        takerCoinStartBlock: json["taker_coin_start_block"] == null
            ? null
            : json["taker_coin_start_block"],
        takerPaymentConfirmations: json["taker_payment_confirmations"] == null
            ? null
            : json["taker_payment_confirmations"],
        takerPaymentLock: json["taker_payment_lock"] == null
            ? null
            : json["taker_payment_lock"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        makerPaymentLocktime: json["maker_payment_locktime"] == null
            ? null
            : json["maker_payment_locktime"],
        makerPubkey: json["maker_pubkey"] == null ? null : json["maker_pubkey"],
        secretHash: json["secret_hash"] == null ? null : json["secret_hash"],
        blockHeight: json["block_height"] == null ? null : json["block_height"],
        coin: json["coin"] == null ? null : json["coin"],
        feeDetails: json["fee_details"] == null
            ? null
            : FeeDetails.fromJson(json["fee_details"]),
        from: json["from"] == null
            ? null
            : new List<String>.from(json["from"].map((x) => x)),
        internalId: json["internal_id"] == null ? null : json["internal_id"],
        myBalanceChange: json["my_balance_change"] == null
            ? null
            : json["my_balance_change"].toDouble(),
        receivedByMe: json["received_by_me"] == null
            ? null
            : json["received_by_me"].toDouble(),
        spentByMe:
            json["spent_by_me"] == null ? null : json["spent_by_me"].toDouble(),
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        to: json["to"] == null
            ? null
            : new List<String>.from(json["to"].map((x) => x)),
        totalAmount: json["total_amount"] == null
            ? null
            : json["total_amount"].toDouble(),
        txHash: json["tx_hash"] == null ? null : json["tx_hash"],
        txHex: json["tx_hex"] == null ? null : json["tx_hex"],
        secret: json["secret"] == null ? null : json["secret"],
        transaction: json["transaction"] == null
            ? null
            : Transaction.fromJson(json["transaction"]),
      );

  Map<String, dynamic> toJson() => {
        "lock_duration": lockDuration == null ? null : lockDuration,
        "maker": maker == null ? null : maker,
        "maker_amount": makerAmount == null ? null : makerAmount,
        "maker_coin": makerCoin == null ? null : makerCoin,
        "maker_coin_start_block":
            makerCoinStartBlock == null ? null : makerCoinStartBlock,
        "maker_payment_confirmations": makerPaymentConfirmations == null
            ? null
            : makerPaymentConfirmations,
        "maker_payment_wait":
            makerPaymentWait == null ? null : makerPaymentWait,
        "my_persistent_pub": myPersistentPub == null ? null : myPersistentPub,
        "started_at": startedAt == null ? null : startedAt,
        "taker_amount": takerAmount == null ? null : takerAmount,
        "taker_coin": takerCoin == null ? null : takerCoin,
        "taker_coin_start_block":
            takerCoinStartBlock == null ? null : takerCoinStartBlock,
        "taker_payment_confirmations": takerPaymentConfirmations == null
            ? null
            : takerPaymentConfirmations,
        "taker_payment_lock":
            takerPaymentLock == null ? null : takerPaymentLock,
        "uuid": uuid == null ? null : uuid,
        "maker_payment_locktime":
            makerPaymentLocktime == null ? null : makerPaymentLocktime,
        "maker_pubkey": makerPubkey == null ? null : makerPubkey,
        "secret_hash": secretHash == null ? null : secretHash,
        "block_height": blockHeight == null ? null : blockHeight,
        "coin": coin == null ? null : coin,
        "fee_details": feeDetails == null ? null : feeDetails.toJson(),
        "from":
            from == null ? null : new List<dynamic>.from(from.map((x) => x)),
        "internal_id": internalId == null ? null : internalId,
        "my_balance_change": myBalanceChange == null ? null : myBalanceChange,
        "received_by_me": receivedByMe == null ? null : receivedByMe,
        "spent_by_me": spentByMe == null ? null : spentByMe,
        "timestamp": timestamp == null ? null : timestamp,
        "to": to == null ? null : new List<dynamic>.from(to.map((x) => x)),
        "total_amount": totalAmount == null ? null : totalAmount,
        "tx_hash": txHash == null ? null : txHash,
        "tx_hex": txHex == null ? null : txHex,
        "secret": secret == null ? null : secret,
        "transaction": transaction == null ? null : transaction.toJson(),
      };
}

class FeeDetails {
  double amount;

  FeeDetails({
    this.amount,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) => new FeeDetails(
        amount: json["amount"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
      };
}

class Transaction {
  int blockHeight;
  String coin;
  FeeDetails feeDetails;
  List<String> from;
  String internalId;
  double myBalanceChange;
  double receivedByMe;
  double spentByMe;
  int timestamp;
  List<String> to;
  double totalAmount;
  String txHash;
  String txHex;

  Transaction({
    this.blockHeight,
    this.coin,
    this.feeDetails,
    this.from,
    this.internalId,
    this.myBalanceChange,
    this.receivedByMe,
    this.spentByMe,
    this.timestamp,
    this.to,
    this.totalAmount,
    this.txHash,
    this.txHex,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => new Transaction(
        blockHeight: json["block_height"],
        coin: json["coin"],
        feeDetails: FeeDetails.fromJson(json["fee_details"]),
        from: new List<String>.from(json["from"].map((x) => x)),
        internalId: json["internal_id"],
        myBalanceChange: json["my_balance_change"].toDouble(),
        receivedByMe: json["received_by_me"].toDouble(),
        spentByMe: json["spent_by_me"].toDouble(),
        timestamp: json["timestamp"],
        to: new List<String>.from(json["to"].map((x) => x)),
        totalAmount: json["total_amount"].toDouble(),
        txHash: json["tx_hash"],
        txHex: json["tx_hex"],
      );

  Map<String, dynamic> toJson() => {
        "block_height": blockHeight,
        "coin": coin,
        "fee_details": feeDetails.toJson(),
        "from": new List<dynamic>.from(from.map((x) => x)),
        "internal_id": internalId,
        "my_balance_change": myBalanceChange,
        "received_by_me": receivedByMe,
        "spent_by_me": spentByMe,
        "timestamp": timestamp,
        "to": new List<dynamic>.from(to.map((x) => x)),
        "total_amount": totalAmount,
        "tx_hash": txHash,
        "tx_hex": txHex,
      };
}

class MyInfo {
  String myAmount;
  String myCoin;
  String otherAmount;
  String otherCoin;
  int startedAt;

  MyInfo({
    this.myAmount,
    this.myCoin,
    this.otherAmount,
    this.otherCoin,
    this.startedAt,
  });

  factory MyInfo.fromJson(Map<String, dynamic> json) => new MyInfo(
        myAmount: json["my_amount"],
        myCoin: json["my_coin"],
        otherAmount: json["other_amount"],
        otherCoin: json["other_coin"],
        startedAt: json["started_at"],
      );

  Map<String, dynamic> toJson() => {
        "my_amount": myAmount,
        "my_coin": myCoin,
        "other_amount": otherAmount,
        "other_coin": otherCoin,
        "started_at": startedAt,
      };
}
