import 'package:intl/intl.dart';

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
        blockHeight: json["block_height"] == null ? null : json["block_height"],
        coin: json["coin"] == null ? null : json["coin"],
        confirmations: json["confirmations"] == null ? null : json["confirmations"],
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
        "confirmations": confirmations == null ? null : confirmations,
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

  String getTimeFormat() {
    if (timestamp == 0) {
      return "unconfirmed";
    } else {
      return DateFormat('dd MMM yyyy HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
    }
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