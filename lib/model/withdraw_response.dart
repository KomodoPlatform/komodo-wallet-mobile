// To parse this JSON data, do
//
//     final withdrawResponse = withdrawResponseFromJson(jsonString);

import 'dart:convert';

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

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) =>
      new WithdrawResponse(
        blockHeight: json["block_height"],
        coin: json["coin"],
        feeDetails: FeeDetails.fromJson(json["fee_details"]),
        from: new List<String>.from(json["from"].map((x) => x)),
        myBalanceChange: json["my_balance_change"].toDouble(),
        receivedByMe: json["received_by_me"].toDouble(),
        spentByMe: json["spent_by_me"].toDouble(),
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
        "my_balance_change": myBalanceChange,
        "received_by_me": receivedByMe,
        "spent_by_me": spentByMe,
        "to": new List<dynamic>.from(to.map((x) => x)),
        "total_amount": totalAmount,
        "tx_hash": txHash,
        "tx_hex": txHex,
      };
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
