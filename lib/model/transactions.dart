// To parse this JSON data, do
//
//     final transactions = transactionsFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

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

class Transaction {
  int blockHeight;
  String coin;
  int confirmations;
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
    this.confirmations,
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
        confirmations: json["confirmations"],
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
        "confirmations": confirmations,
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

  String getTimeFormat() {
    return DateFormat('dd MMM yyyy HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
  }
}

class FeeDetails {
  double amount;
  String coin;
  int gas;
  double gasPrice;
  double totalFee;

  FeeDetails({
    this.amount,
    this.coin,
    this.gas,
    this.gasPrice,
    this.totalFee,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) => new FeeDetails(
        amount: json["amount"] == null ? null : json["amount"].toDouble(),
        coin: json["coin"] == null ? null : json["coin"],
        gas: json["gas"] == null ? null : json["gas"],
        gasPrice:
            json["gas_price"] == null ? null : json["gas_price"].toDouble(),
        totalFee:
            json["total_fee"] == null ? null : json["total_fee"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount == null ? null : amount,
        "coin": coin == null ? null : coin,
        "gas": gas == null ? null : gas,
        "gas_price": gasPrice == null ? null : gasPrice,
        "total_fee": totalFee == null ? null : totalFee,
      };
}
