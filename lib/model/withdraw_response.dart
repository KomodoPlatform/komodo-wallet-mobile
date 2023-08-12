// To parse this JSON data, do
//
//     final withdrawResponse = withdrawResponseFromJson(jsonString);

import 'dart:convert';

import '../model/transaction_data.dart';

WithdrawResponse withdrawResponseFromJson(String str) {
  final Map<String, dynamic> json = jsonDecode(str);
  return WithdrawResponse.fromJson(json);
}

String withdrawResponseToJson(WithdrawResponse data) =>
    json.encode(data.toJson());

class WithdrawResponse {
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
    this.taskId,
  });

  factory WithdrawResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawResponse(
      blockHeight: json['block_height'] ?? 0,
      coin: json['coin'] ?? '',
      feeDetails: json['fee_details'] == null
          ? FeeDetails()
          : FeeDetails.fromJson(json['fee_details']),
      from: json['from'] == null
          ? <String>[]
          : List<String>.from(json['from'].map<dynamic>((dynamic x) => x)),
      myBalanceChange: json['my_balance_change'] ?? '',
      receivedByMe: json['received_by_me'] ?? '',
      spentByMe: json['spent_by_me'] ?? '',
      to: json['to'] == null
          ? <String>[]
          : List<String>.from(json['to'].map<dynamic>((dynamic x) => x)),
      totalAmount: json['total_amount'] ?? '',
      txHash: json['tx_hash'] ?? '',
      txHex: json['tx_hex'] ?? '',
      taskId: json['result'] == null ? null : json['result']['task_id'],
    );
  }

  int blockHeight;
  String coin;
  FeeDetails feeDetails;
  List<String> from;
  String myBalanceChange;
  String receivedByMe;
  String spentByMe;
  List<String> to;
  String totalAmount;
  String txHash;
  String txHex;
  int taskId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_height': blockHeight ?? 0,
        'coin': coin ?? '',
        'fee_details': feeDetails?.toJson(),
        'from': List<dynamic>.from(from.map<dynamic>((dynamic x) => x)) ??
            <String>[],
        'my_balance_change': myBalanceChange ?? '',
        'received_by_me': receivedByMe ?? '',
        'spent_by_me': spentByMe ?? '',
        'to':
            List<dynamic>.from(to.map<dynamic>((dynamic x) => x)) ?? <String>[],
        'total_amount': totalAmount ?? '',
        'tx_hash': txHash ?? '',
        'tx_hex': txHex ?? '',
      };
}
