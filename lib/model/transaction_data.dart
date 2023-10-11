import 'package:intl/intl.dart';
import '../utils/utils.dart';

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
    this.memo,
    this.to,
    this.totalAmount,
    this.txHash,
    this.txHex,
    this.transactionFee,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      blockHeight:
          int.tryParse(json['block_height']?.toString()) ?? 0, //toDouble()
      coin: json['coin'] ?? '',
      confirmations: json['confirmations'] ?? 0,
      feeDetails: json['fee_details'] == null
          ? null
          : FeeDetails.fromJson(json['fee_details']),
      from: List<String>.from(json['from'].map<dynamic>((dynamic x) => x)) ??
          <String>[],
      internalId: json['internal_id']?.toString() ?? '',
      transactionFee: json['transaction_fee']?.toString() ?? '',
      myBalanceChange: json['my_balance_change']?.toString() ?? 0.0,
      receivedByMe: json['received_by_me']?.toString() ?? 0.0,
      spentByMe: json['spent_by_me']?.toString() ?? 0.0,
      timestamp: json['timestamp'] ?? 0,
      memo: json['memo'] ?? '0',
      to: List<String>.from(json['to'].map<dynamic>((dynamic x) => x)) ??
          <String>[],
      totalAmount: json['total_amount']?.toString() ?? '',
      txHash: json['tx_hash'] ?? '',
      txHex: json['tx_hex'] ?? '',
    );
  }

  int blockHeight;
  String coin;
  int confirmations;
  FeeDetails feeDetails;
  List<String> from;
  String internalId;
  String myBalanceChange;
  String receivedByMe;
  String spentByMe;
  int timestamp;
  String memo;
  List<String> to;
  String totalAmount;
  String transactionFee;
  String txHash;
  String txHex;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_height': blockHeight ?? 0.0,
        'coin': coin ?? '',
        'confirmations': confirmations ?? 0,
        'fee_details': feeDetails?.toJson(),
        'from': List<dynamic>.from(from.map<dynamic>((dynamic x) => x)) ??
            <String>[],
        'internal_id': internalId ?? '',
        'transaction_fee': transactionFee ?? '',
        'my_balance_change': myBalanceChange ?? 0.0,
        'received_by_me': receivedByMe ?? 0.0,
        'spent_by_me': spentByMe ?? 0.0,
        'timestamp': timestamp ?? 0,
        'memo': memo ?? '',
        'to':
            List<dynamic>.from(to.map<dynamic>((dynamic x) => x)) ?? <String>[],
        'total_amount': totalAmount ?? '',
        'tx_hash': txHash ?? '',
        'tx_hex': txHex ?? '',
      };

  String getTimeFormat() {
    if (timestamp == 0 && confirmations == 0) {
      return 'unconfirmed';
    } else if (timestamp == 0 && confirmations > 0) {
      return 'confirmed';
    } else {
      return DateFormat('dd MMM yyyy HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
    }
  }

  List<String> getToAddress() {
    final List<String> toAddress = List.from(to);
    if (toAddress.length > 1) {
      toAddress.removeWhere((String toItem) => toItem == from[0]);
    }
    return toAddress;
  }
}

class FeeDetails {
  FeeDetails({
    this.amount,
    this.coin,
    this.gas,
    this.gasLimit,
    this.gasPrice,
    this.totalFee,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) {
    final FeeDetails feeDetails = FeeDetails(
      amount: json['amount'] ?? '', // UTXO
      coin: json['coin'] ?? '',
      gas: json['gas'] ?? 0,
      gasLimit: json['gas_limit'],
      gasPrice: json['gas_price'] ?? '',
      totalFee: json['total_fee']?.toString() ?? '', // ETH and ERC20 tokens
    );

    try {
      final minerFee =
          json['miner_fee'] == null ? null : double.tryParse(json['miner_fee']);

      final totalGasFee = json['total_gas_fee'] == null
          ? null
          : double.tryParse(json['total_gas_fee']);

      if (minerFee != null || totalGasFee != null) {
        final total = minerFee ?? 0.0 + totalGasFee ?? 0.0;
        // QRC20 tokens
        feeDetails.totalFee = cutTrailingZeros(formatPrice(total));
      }
    } catch (_) {}

    return feeDetails;
  }

  String amount;
  String coin;
  int gas;
  int gasLimit;
  dynamic gasPrice; // String for erc, int for qrc
  String totalFee;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount': amount ?? 0.0,
        'coin': coin ?? '',
        'gas': gas ?? 0,
        if (gasLimit != null) 'gas_limit': gasLimit,
        'gas_price': gasPrice ?? '',
        'total_fee': totalFee ?? '',
      };
}
