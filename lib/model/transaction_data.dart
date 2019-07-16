import 'package:intl/intl.dart';

class Transaction {
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

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        blockHeight: json['block_height'] ?? 0,
        coin: json['coin'] ?? '',
        confirmations: json['confirmations'] ?? 0,
        feeDetails: json['fee_details'] ?? FeeDetails(),
        from: json['from'] ?? <String>[],
        internalId: json['internal_id'] ?? '',
        myBalanceChange: json['my_balance_change'] ?? 0.0,
        receivedByMe: json['received_by_me'] ?? 0.0,
        spentByMe: json['spent_by_me'] ?? 0.0,
        timestamp: json['timestamp'] ?? 0,
        to: json['to'] ?? <String>[],
        totalAmount: json['total_amount'] ?? '',
        txHash: json['tx_hash'] ?? '',
        txHex: json['tx_hex'] ?? '',
      );

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_height': blockHeight ?? 0,
        'coin': coin ?? '',
        'confirmations': confirmations ?? 0,
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

  String getTimeFormat() {
    if (timestamp == 0) {
      return 'unconfirmed';
    } else {
      return DateFormat('dd MMM yyyy HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
    }
  }
}

class FeeDetails {
  FeeDetails({
    this.amount,
    this.coin,
    this.gas,
    this.gasPrice,
    this.totalFee,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) => FeeDetails(
        amount: json['amount'] ?? 0.0,
        coin: json['coin'] ?? '',
        gas: json['gas'] ?? 0,
        gasPrice: json['gas_price'] ?? 0.0,
        totalFee: json['total_fee'] ?? 0.0,
      );

  double amount;
  String coin;
  int gas;
  double gasPrice;
  double totalFee;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount': amount ?? 0.0,
        'coin': coin ?? '',
        'gas': gas ?? 0,
        'gas_price': gasPrice ?? 0.0,
        'total_fee': totalFee ?? 0.0,
      };
}
