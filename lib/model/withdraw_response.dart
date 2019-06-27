// To parse this JSON data, do
//
//     final withdrawResponse = withdrawResponseFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/transaction_data.dart';

WithdrawResponse withdrawResponseFromJson(String str) =>
    WithdrawResponse.fromJson(json.decode(str));

String withdrawResponseToJson(WithdrawResponse data) =>
    json.encode(data.toJson());

class WithdrawResponse {
    int blockHeight;
    String coin;
    FeeDetails feeDetails;
    List<String> from;
    double myBalanceChange;
    double receivedByMe;
    double spentByMe;
    List<String> to;
    double totalAmount;
    String txHash;
    String txHex;

    WithdrawResponse({
        this.blockHeight,
        this.coin,
        this.feeDetails,
        this.from,
        this.myBalanceChange,
        this.receivedByMe,
        this.spentByMe,
        this.to,
        this.totalAmount,
        this.txHash,
        this.txHex,
    });

    factory WithdrawResponse.fromJson(Map<String, dynamic> json) => new WithdrawResponse(
        blockHeight: json["block_height"] == null ? null : json["block_height"],
        coin: json["coin"] == null ? null : json["coin"],
        feeDetails: json["fee_details"] == null ? null : FeeDetails.fromJson(json["fee_details"]),
        from: json["from"] == null ? null : new List<String>.from(json["from"].map((x) => x)),
        myBalanceChange: json["my_balance_change"] == null ? null : json["my_balance_change"].toDouble(),
        receivedByMe: json["received_by_me"] == null ? null : json["received_by_me"].toDouble(),
        spentByMe: json["spent_by_me"] == null ? null : json["spent_by_me"].toDouble(),
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
        "my_balance_change": myBalanceChange == null ? null : myBalanceChange,
        "received_by_me": receivedByMe == null ? null : receivedByMe,
        "spent_by_me": spentByMe == null ? null : spentByMe,
        "to": to == null ? null : new List<dynamic>.from(to.map((x) => x)),
        "total_amount": totalAmount == null ? null : totalAmount,
        "tx_hash": txHash == null ? null : txHash,
        "tx_hex": txHex == null ? null : txHex,
    };
}
