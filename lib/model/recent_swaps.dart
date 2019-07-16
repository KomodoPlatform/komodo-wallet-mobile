// To parse this JSON data, do
//
//     final recentSwaps = recentSwapsFromJson(jsonString);

import 'dart:convert';

RecentSwaps recentSwapsFromJson(String str) =>
    RecentSwaps.fromJson(json.decode(str));

String recentSwapsToJson(RecentSwaps data) => json.encode(data.toJson());

class RecentSwaps {
  RecentSwaps({
    this.result,
  });

  factory RecentSwaps.fromJson(Map<String, dynamic> json) => RecentSwaps(
        result: json['result'] ?? Result(),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result ?? Result(),
      };
}

class Result {
  Result({
    this.fromUuid,
    this.limit,
    this.skipped,
    this.swaps,
    this.total,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        fromUuid: json['from_uuid'] ?? '',
        limit: json['limit'] ?? 0,
        skipped: json['skipped'] ?? 0,
        swaps: json['swaps'] ?? <ResultSwap>[],
        total: json['total'] ?? 0,
      );

  String fromUuid;
  int limit;
  int skipped;
  List<ResultSwap> swaps;
  int total;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from_uuid': fromUuid ?? '',
        'limit': limit ?? 0,
        'skipped': skipped ?? 0,
        'swaps': swaps ?? <ResultSwap>[],
        'total': total ?? 0,
      };
}

class ResultSwap {
  ResultSwap({
    this.errorEvents,
    this.events,
    this.myInfo,
    this.successEvents,
    this.type,
    this.uuid,
  });

  factory ResultSwap.fromJson(Map<String, dynamic> json) => ResultSwap(
        errorEvents: json['error_events'] ?? <String>[],
        events: json['events'] ?? <EventElement>[],
        myInfo: json['my_info'] ?? MyInfo(),
        successEvents: json['success_events'] ?? <String>[],
        type: json['type'] ?? '',
        uuid: json['uuid'] ?? '',
      );

  List<String> errorEvents;
  List<EventElement> events;
  MyInfo myInfo;
  List<String> successEvents;
  String type;
  String uuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'error_events': errorEvents ?? <String>[],
        'events': events ?? <EventElement>[],
        'my_info': myInfo ?? MyInfo(),
        'success_events': successEvents ?? <String>[],
        'type': type ?? '',
        'uuid': uuid ?? '',
      };
}

class EventElement {
  EventElement({
    this.event,
    this.timestamp,
  });

  factory EventElement.fromJson(Map<String, dynamic> json) => EventElement(
        event: json['event'] ?? EventEvent(),
        timestamp: json['timestamp'] ?? 0,
      );

  EventEvent event;
  int timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'event': event ?? EventEvent(),
        'timestamp': timestamp ?? 0,
      };
}

class EventEvent {
  EventEvent({
    this.data,
    this.type,
  });

  factory EventEvent.fromJson(Map<String, dynamic> json) => EventEvent(
        data: json['data'] ?? Data(),
        type: json['type'] ?? '',
      );

  Data data;
  String type;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data ?? Data(),
        'type': type ?? '',
      };
}

class Data {
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        lockDuration: json['lock_duration'] ?? 0,
        makerAmount: json['maker_amount'] ?? '',
        makerCoin: json['maker_coin'] ?? '',
        makerCoinStartBlock: json['maker_coin_start_block'] ?? 0,
        makerPaymentConfirmations: json['maker_payment_confirmations'] ?? 0,
        makerPaymentLock: json['maker_payment_lock'] ?? 0,
        myPersistentPub: json['my_persistent_pub'] ?? '',
        secret: json['secret'] ?? '',
        startedAt: json['started_at'] ?? 0,
        taker: json['taker'] ?? '',
        takerAmount: json['taker_amount'] ?? '',
        takerCoin: json['taker_coin'] ?? '',
        takerCoinStartBlock: json['taker_coin_start_block'] ?? 0,
        takerPaymentConfirmations: json['taker_payment_confirmations'] ?? 0,
        uuid: json['uuid'] ?? '',
        takerPaymentLocktime: json['taker_payment_locktime'] ?? 0,
        takerPubkey: json['taker_pubkey'] ?? '',
        blockHeight: json['block_height'] ?? 0,
        coin: json['coin'] ?? '',
        feeDetails: json['fee_details'] ?? FeeDetails(),
        from: json['from'] ?? <String>[],
        internalId: json['internal_id'] ?? '',
        myBalanceChange: json['my_balance_change'] ?? 0.0,
        receivedByMe: json['received_by_me'] ?? 0.0,
        spentByMe: json['spent_by_me'] ?? 0.0,
        timestamp: json['timestamp'] ?? 0,
        to: json['to'] ?? <String>[],
        totalAmount: json['total_amount'] ?? 0.0,
        txHash: json['tx_hash'] ?? '',
        txHex: json['tx_hex'] ?? '',
        maker: json['maker'] ?? '',
        makerPaymentWait: json['maker_payment_wait'] ?? 0,
        takerPaymentLock: json['taker_payment_lock'] ?? 0,
        makerPaymentLocktime: json['maker_payment_locktime'] ?? 0,
        makerPubkey: json['maker_pubkey'] ?? '',
        secretHash: json['secret_hash'] ?? '',
        transaction: json['transaction'] ?? Transaction(),
      );

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'lock_duration': lockDuration ?? 0,
        'maker_amount': makerAmount ?? '',
        'maker_coin': makerCoin ?? '',
        'maker_coin_start_block': makerCoinStartBlock ?? 0,
        'maker_payment_confirmations': makerPaymentConfirmations ?? 0,
        'maker_payment_lock': makerPaymentLock ?? 0,
        'my_persistent_pub': myPersistentPub ?? '',
        'secret': secret ?? '',
        'started_at': startedAt ?? 0,
        'taker': taker ?? '',
        'taker_amount': takerAmount ?? '',
        'taker_coin': takerCoin ?? '',
        'taker_coin_start_block': takerCoinStartBlock ?? 0,
        'taker_payment_confirmations': takerPaymentConfirmations ?? 0,
        'uuid': uuid ?? '',
        'taker_payment_locktime': takerPaymentLocktime ?? 0,
        'taker_pubkey': takerPubkey ?? '',
        'block_height': blockHeight ?? 0,
        'coin': coin ?? '',
        'fee_details': feeDetails ?? FeeDetails(),
        'from': from ?? <String>[],
        'internal_id': internalId ?? '',
        'my_balance_change': myBalanceChange ?? 0.0,
        'received_by_me': receivedByMe ?? 0.0,
        'spent_by_me': spentByMe ?? 0.0,
        'timestamp': timestamp ?? 0,
        'to': to ?? <String>[],
        'total_amount': totalAmount ?? 0.0,
        'tx_hash': txHash ?? '',
        'tx_hex': txHex ?? '',
        'maker': maker ?? '',
        'maker_payment_wait': makerPaymentWait ?? 0,
        'taker_payment_lock': takerPaymentLock ?? 0,
        'maker_payment_locktime': makerPaymentLocktime ?? 0,
        'maker_pubkey': makerPubkey ?? '',
        'secret_hash': secretHash ?? '',
        'transaction': transaction ?? Transaction(),
      };
}

class FeeDetails {
  FeeDetails({
    this.amount,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) => FeeDetails(
        amount: json['amount'] ?? 0.0,
      );

  double amount;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount': amount ?? 0.0,
      };
}

class Transaction {
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

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        blockHeight: json['block_height'] ?? 0,
        coin: json['coin'] ?? '',
        feeDetails: json['fee_details'] ?? FeeDetails(),
        from: json['from'] ?? <String>[],
        internalId: json['internal_id'] ?? '',
        myBalanceChange: json['my_balance_change'] ?? 0.0,
        receivedByMe: json['received_by_me'] ?? 0.0,
        spentByMe: json['spent_by_me'] ?? 0.0,
        timestamp: json['timestamp'] ?? 0,
        to: json['to'] ?? <String>[],
        totalAmount: json['total_amount'] ?? 0.0,
        txHash: json['tx_hash'] ?? '',
        txHex: json['tx_hex'] ?? '',
      );

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_height': blockHeight ?? 0,
        'coin': coin ?? '',
        'fee_details': feeDetails ?? FeeDetails(),
        'from': from ?? <String>[],
        'internal_id': internalId ?? '',
        'my_balance_change': myBalanceChange ?? 0.0,
        'received_by_me': receivedByMe ?? 0.0,
        'spent_by_me': spentByMe ?? 0.0,
        'timestamp': timestamp ?? 0,
        'to': to ?? <String>[],
        'total_amount': totalAmount ?? 0.0,
        'tx_hash': txHash ?? '',
        'tx_hex': txHex ?? '',
      };
}

class MyInfo {
  MyInfo({
    this.myAmount,
    this.myCoin,
    this.otherAmount,
    this.otherCoin,
    this.startedAt,
  });

  factory MyInfo.fromJson(Map<String, dynamic> json) => MyInfo(
        myAmount: json['my_amount'] ?? '',
        myCoin: json['my_coin'] ?? '',
        otherAmount: json['other_amount'] ?? '',
        otherCoin: json['other_coin'] ?? '',
        startedAt: json['started_at'] ?? 0,
      );

  String myAmount;
  String myCoin;
  String otherAmount;
  String otherCoin;
  int startedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'my_amount': myAmount ?? '',
        'my_coin': myCoin ?? '',
        'other_amount': otherAmount ?? '',
        'other_coin': otherCoin ?? '',
        'started_at': startedAt ?? 0,
      };
}
