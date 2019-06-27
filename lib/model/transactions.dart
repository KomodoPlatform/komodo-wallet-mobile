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
  int limit;
  int skipped;
  int total;
  List<Transaction> transactions;

  Result({
    this.fromId,
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
        transactions: new List<Transaction>.from(
            json["transactions"].map((x) => Transaction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "from_id": fromId,
        "limit": limit,
        "skipped": skipped,
        "total": total,
        "transactions":
            new List<dynamic>.from(transactions.map((x) => x.toJson())),
      };
}
