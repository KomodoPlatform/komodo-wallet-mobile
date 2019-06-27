// To parse this JSON data, do
//
//     final transactions = transactionsFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/transaction_data.dart';

Transactions transactionsFromJson(String str) =>
    Transactions.fromJson(json.decode(str));

String transactionsToJson(Transactions data) => json.encode(data.toJson());

class Transactions {
  Result result;

  Transactions({
    this.result,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) => new Transactions(
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };
}

class Result {
  dynamic fromId;
  int currentBlock;
  SyncStatus syncStatus;
  int limit;
  int skipped;
  int total;
  List<Transaction> transactions;

  Result({
    this.fromId,
    this.currentBlock,
    this.syncStatus,
    this.limit,
    this.skipped,
    this.total,
    this.transactions,
  });

  factory Result.fromJson(Map<String, dynamic> json) => new Result(
        fromId: json["from_id"],
        limit: json["limit"],
        skipped: json["skipped"],
        total: json["total"],
        currentBlock:
            json["current_block"] == null ? null : json["current_block"],
        syncStatus: json["sync_status"] == null
            ? null
            : SyncStatus.fromJson(json["sync_status"]),
        transactions: new List<Transaction>.from(
            json["transactions"].map((x) => Transaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "from_id": fromId,
        "current_block": currentBlock == null ? null : currentBlock,
        "limit": limit,
        "skipped": skipped,
        "total": total,
        "sync_status": syncStatus == null ? null : syncStatus.toJson(),
        "transactions":
            new List<dynamic>.from(transactions.map((x) => x.toJson())),
      };
}

class SyncStatus {
    AdditionalInfo additionalInfo;
    String state;

    SyncStatus({
        this.additionalInfo,
        this.state,
    });

    factory SyncStatus.fromJson(Map<String, dynamic> json) => new SyncStatus(
        additionalInfo: json["additional_info"] == null ? null : AdditionalInfo.fromJson(json["additional_info"]),
        state: json["state"] == null ? null : json["state"],
    );

    Map<String, dynamic> toJson() => {
        "additional_info": additionalInfo == null ? null : additionalInfo.toJson(),
        "state": state == null ? null : state,
    };
}

class AdditionalInfo {
    int code;
    String message;
    int transactionsLeft;
    int blocksLeft;

    AdditionalInfo({
        this.code,
        this.message,
        this.transactionsLeft,
        this.blocksLeft,
    });

    factory AdditionalInfo.fromJson(Map<String, dynamic> json) => new AdditionalInfo(
        code: json["code"] == null ? null : json["code"],
        message: json["message"] == null ? null : json["message"],
        transactionsLeft: json["transactions_left"] == null ? null : json["transactions_left"],
        blocksLeft: json["blocks_left"] == null ? null : json["blocks_left"],
    );

    Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "message": message == null ? null : message,
        "transactions_left": transactionsLeft == null ? null : transactionsLeft,
        "blocks_left": blocksLeft == null ? null : blocksLeft,
    };
}

enum StateOfSync {
  NotEnabled,
  NotStarted,
  InProgress,
  Error,
  Finished
}