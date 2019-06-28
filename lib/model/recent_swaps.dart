// To parse this JSON data, do
//
//     final recentSwaps = recentSwapsFromJson(jsonString);

import 'dart:convert';

RecentSwaps recentSwapsFromJson(String str) => RecentSwaps.fromJson(json.decode(str));

String recentSwapsToJson(RecentSwaps data) => json.encode(data.toJson());

class RecentSwaps {
    Result result;

    RecentSwaps({
        this.result,
    });

    factory RecentSwaps.fromJson(Map<String, dynamic> json) => new RecentSwaps(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "result": result == null ? null : result.toJson(),
    };
}

class Result {
    String fromUuid;
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
        fromUuid: json["from_uuid"] == null ? null : json["from_uuid"],
        limit: json["limit"] == null ? null : json["limit"],
        skipped: json["skipped"] == null ? null : json["skipped"],
        swaps: json["swaps"] == null ? null : new List<ResultSwap>.from(json["swaps"].map((x) => ResultSwap.fromJson(x))),
        total: json["total"] == null ? null : json["total"],
    );

    Map<String, dynamic> toJson() => {
        "from_uuid": fromUuid == null ? null : fromUuid,
        "limit": limit == null ? null : limit,
        "skipped": skipped == null ? null : skipped,
        "swaps": swaps == null ? null : new List<dynamic>.from(swaps.map((x) => x.toJson())),
        "total": total == null ? null : total,
    };
}

class ResultSwap {
    List<String> errorEvents;
    List<EventElement> events;
    MyInfo myInfo;
    List<String> successEvents;
    String type;
    String uuid;

    ResultSwap({
        this.errorEvents,
        this.events,
        this.myInfo,
        this.successEvents,
        this.type,
        this.uuid,
    });

    factory ResultSwap.fromJson(Map<String, dynamic> json) => new ResultSwap(
        errorEvents: json["error_events"] == null ? null : new List<String>.from(json["error_events"].map((x) => x)),
        events: json["events"] == null ? null : new List<EventElement>.from(json["events"].map((x) => EventElement.fromJson(x))),
        myInfo: json["my_info"] == null ? null : MyInfo.fromJson(json["my_info"]),
        successEvents: json["success_events"] == null ? null : new List<String>.from(json["success_events"].map((x) => x)),
        type: json["type"] == null ? null : json["type"],
        uuid: json["uuid"] == null ? null : json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "error_events": errorEvents == null ? null : new List<dynamic>.from(errorEvents.map((x) => x)),
        "events": events == null ? null : new List<dynamic>.from(events.map((x) => x.toJson())),
        "my_info": myInfo == null ? null : myInfo.toJson(),
        "success_events": successEvents == null ? null : new List<dynamic>.from(successEvents.map((x) => x)),
        "type": type == null ? null : type,
        "uuid": uuid == null ? null : uuid,
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
        event: json["event"] == null ? null : EventEvent.fromJson(json["event"]),
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
    );

    Map<String, dynamic> toJson() => {
        "event": event == null ? null : event.toJson(),
        "timestamp": timestamp == null ? null : timestamp,
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
        type: json["type"] == null ? null : json["type"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? null : data.toJson(),
        "type": type == null ? null : type,
    };
}

class Data {
    int lockDuration;
    String makerAmount;
    String makerCoin;
    int makerCoinStartBlock;
    int makerPaymentConfirmations;
    int makerPaymentLock;
    String myPersistentPub;
    String secret;
    int startedAt;
    String taker;
    String takerAmount;
    String takerCoin;
    int takerCoinStartBlock;
    int takerPaymentConfirmations;
    String uuid;
    int takerPaymentLocktime;
    String takerPubkey;
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
    String maker;
    int makerPaymentWait;
    int takerPaymentLock;
    int makerPaymentLocktime;
    String makerPubkey;
    String secretHash;
    Transaction transaction;

    Data({
        this.lockDuration,
        this.makerAmount,
        this.makerCoin,
        this.makerCoinStartBlock,
        this.makerPaymentConfirmations,
        this.makerPaymentLock,
        this.myPersistentPub,
        this.secret,
        this.startedAt,
        this.taker,
        this.takerAmount,
        this.takerCoin,
        this.takerCoinStartBlock,
        this.takerPaymentConfirmations,
        this.uuid,
        this.takerPaymentLocktime,
        this.takerPubkey,
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
        this.maker,
        this.makerPaymentWait,
        this.takerPaymentLock,
        this.makerPaymentLocktime,
        this.makerPubkey,
        this.secretHash,
        this.transaction,
    });

    factory Data.fromJson(Map<String, dynamic> json) => new Data(
        lockDuration: json["lock_duration"] == null ? null : json["lock_duration"],
        makerAmount: json["maker_amount"] == null ? null : json["maker_amount"],
        makerCoin: json["maker_coin"] == null ? null : json["maker_coin"],
        makerCoinStartBlock: json["maker_coin_start_block"] == null ? null : json["maker_coin_start_block"],
        makerPaymentConfirmations: json["maker_payment_confirmations"] == null ? null : json["maker_payment_confirmations"],
        makerPaymentLock: json["maker_payment_lock"] == null ? null : json["maker_payment_lock"],
        myPersistentPub: json["my_persistent_pub"] == null ? null : json["my_persistent_pub"],
        secret: json["secret"] == null ? null : json["secret"],
        startedAt: json["started_at"] == null ? null : json["started_at"],
        taker: json["taker"] == null ? null : json["taker"],
        takerAmount: json["taker_amount"] == null ? null : json["taker_amount"],
        takerCoin: json["taker_coin"] == null ? null : json["taker_coin"],
        takerCoinStartBlock: json["taker_coin_start_block"] == null ? null : json["taker_coin_start_block"],
        takerPaymentConfirmations: json["taker_payment_confirmations"] == null ? null : json["taker_payment_confirmations"],
        uuid: json["uuid"] == null ? null : json["uuid"],
        takerPaymentLocktime: json["taker_payment_locktime"] == null ? null : json["taker_payment_locktime"],
        takerPubkey: json["taker_pubkey"] == null ? null : json["taker_pubkey"],
        blockHeight: json["block_height"] == null ? null : json["block_height"],
        coin: json["coin"] == null ? null : json["coin"],
        feeDetails: json["fee_details"] == null ? null : FeeDetails.fromJson(json["fee_details"]),
        from: json["from"] == null ? null : new List<String>.from(json["from"].map((x) => x)),
        internalId: json["internal_id"] == null ? null : json["internal_id"],
        myBalanceChange: json["my_balance_change"] == null ? null : json["my_balance_change"].toDouble(),
        receivedByMe: json["received_by_me"] == null ? null : json["received_by_me"].toDouble(),
        spentByMe: json["spent_by_me"] == null ? null : json["spent_by_me"].toDouble(),
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        to: json["to"] == null ? null : new List<String>.from(json["to"].map((x) => x)),
        totalAmount: json["total_amount"] == null ? null : json["total_amount"].toDouble(),
        txHash: json["tx_hash"] == null ? null : json["tx_hash"],
        txHex: json["tx_hex"] == null ? null : json["tx_hex"],
        maker: json["maker"] == null ? null : json["maker"],
        makerPaymentWait: json["maker_payment_wait"] == null ? null : json["maker_payment_wait"],
        takerPaymentLock: json["taker_payment_lock"] == null ? null : json["taker_payment_lock"],
        makerPaymentLocktime: json["maker_payment_locktime"] == null ? null : json["maker_payment_locktime"],
        makerPubkey: json["maker_pubkey"] == null ? null : json["maker_pubkey"],
        secretHash: json["secret_hash"] == null ? null : json["secret_hash"],
        transaction: json["transaction"] == null ? null : Transaction.fromJson(json["transaction"]),
    );

    Map<String, dynamic> toJson() => {
        "lock_duration": lockDuration == null ? null : lockDuration,
        "maker_amount": makerAmount == null ? null : makerAmount,
        "maker_coin": makerCoin == null ? null : makerCoin,
        "maker_coin_start_block": makerCoinStartBlock == null ? null : makerCoinStartBlock,
        "maker_payment_confirmations": makerPaymentConfirmations == null ? null : makerPaymentConfirmations,
        "maker_payment_lock": makerPaymentLock == null ? null : makerPaymentLock,
        "my_persistent_pub": myPersistentPub == null ? null : myPersistentPub,
        "secret": secret == null ? null : secret,
        "started_at": startedAt == null ? null : startedAt,
        "taker": taker == null ? null : taker,
        "taker_amount": takerAmount == null ? null : takerAmount,
        "taker_coin": takerCoin == null ? null : takerCoin,
        "taker_coin_start_block": takerCoinStartBlock == null ? null : takerCoinStartBlock,
        "taker_payment_confirmations": takerPaymentConfirmations == null ? null : takerPaymentConfirmations,
        "uuid": uuid == null ? null : uuid,
        "taker_payment_locktime": takerPaymentLocktime == null ? null : takerPaymentLocktime,
        "taker_pubkey": takerPubkey == null ? null : takerPubkey,
        "block_height": blockHeight == null ? null : blockHeight,
        "coin": coin == null ? null : coin,
        "fee_details": feeDetails == null ? null : feeDetails.toJson(),
        "from": from == null ? null : new List<dynamic>.from(from.map((x) => x)),
        "internal_id": internalId == null ? null : internalId,
        "my_balance_change": myBalanceChange == null ? null : myBalanceChange,
        "received_by_me": receivedByMe == null ? null : receivedByMe,
        "spent_by_me": spentByMe == null ? null : spentByMe,
        "timestamp": timestamp == null ? null : timestamp,
        "to": to == null ? null : new List<dynamic>.from(to.map((x) => x)),
        "total_amount": totalAmount == null ? null : totalAmount,
        "tx_hash": txHash == null ? null : txHash,
        "tx_hex": txHex == null ? null : txHex,
        "maker": maker == null ? null : maker,
        "maker_payment_wait": makerPaymentWait == null ? null : makerPaymentWait,
        "taker_payment_lock": takerPaymentLock == null ? null : takerPaymentLock,
        "maker_payment_locktime": makerPaymentLocktime == null ? null : makerPaymentLocktime,
        "maker_pubkey": makerPubkey == null ? null : makerPubkey,
        "secret_hash": secretHash == null ? null : secretHash,
        "transaction": transaction == null ? null : transaction.toJson(),
    };
}

class FeeDetails {
    double amount;

    FeeDetails({
        this.amount,
    });

    factory FeeDetails.fromJson(Map<String, dynamic> json) => new FeeDetails(
        amount: json["amount"] == null ? null : json["amount"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "amount": amount == null ? null : amount,
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
        blockHeight: json["block_height"] == null ? null : json["block_height"],
        coin: json["coin"] == null ? null : json["coin"],
        feeDetails: json["fee_details"] == null ? null : FeeDetails.fromJson(json["fee_details"]),
        from: json["from"] == null ? null : new List<String>.from(json["from"].map((x) => x)),
        internalId: json["internal_id"] == null ? null : json["internal_id"],
        myBalanceChange: json["my_balance_change"] == null ? null : json["my_balance_change"].toDouble(),
        receivedByMe: json["received_by_me"] == null ? null : json["received_by_me"].toDouble(),
        spentByMe: json["spent_by_me"] == null ? null : json["spent_by_me"].toDouble(),
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        to: json["to"] == null ? null : new List<String>.from(json["to"].map((x) => x)),
        totalAmount: json["total_amount"] == null ? null : json["total_amount"].toDouble(),
        txHash: json["tx_hash"] == null ? null : json["tx_hash"],
        txHex: json["tx_hex"] == null ? null : json["tx_hex"],
    );

    Map<String, dynamic> toJson() => {
        "block_height": blockHeight == null ? null : blockHeight,
        "coin": coin == null ? null : coin,
        "fee_details": feeDetails == null ? null : feeDetails.toJson(),
        "from": from == null ? null : new List<dynamic>.from(from.map((x) => x)),
        "internal_id": internalId == null ? null : internalId,
        "my_balance_change": myBalanceChange == null ? null : myBalanceChange,
        "received_by_me": receivedByMe == null ? null : receivedByMe,
        "spent_by_me": spentByMe == null ? null : spentByMe,
        "timestamp": timestamp == null ? null : timestamp,
        "to": to == null ? null : new List<dynamic>.from(to.map((x) => x)),
        "total_amount": totalAmount == null ? null : totalAmount,
        "tx_hash": txHash == null ? null : txHash,
        "tx_hex": txHex == null ? null : txHex,
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
        myAmount: json["my_amount"] == null ? null : json["my_amount"],
        myCoin: json["my_coin"] == null ? null : json["my_coin"],
        otherAmount: json["other_amount"] == null ? null : json["other_amount"],
        otherCoin: json["other_coin"] == null ? null : json["other_coin"],
        startedAt: json["started_at"] == null ? null : json["started_at"],
    );

    Map<String, dynamic> toJson() => {
        "my_amount": myAmount == null ? null : myAmount,
        "my_coin": myCoin == null ? null : myCoin,
        "other_amount": otherAmount == null ? null : otherAmount,
        "other_coin": otherCoin == null ? null : otherCoin,
        "started_at": startedAt == null ? null : startedAt,
    };
}
