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
      WithdrawResponse(
        blockHeight: json['block_height'] ?? 0,
        coin: json['coin'] ?? '',
        feeDetails: FeeDetails.fromJson(json['fee_details']) ?? FeeDetails(),
        from: List<String>.from(json['from'].map<dynamic>((dynamic x) => x)) ??
            <String>[],
        myBalanceChange: json['my_balance_change'] ?? 0.0,
        receivedByMe: json['received_by_me'] ?? 0.0,
        spentByMe: json['spent_by_me'] ?? 0.0,
        to: List<String>.from(json['to'].map<dynamic>((dynamic x) => x)) ??
            <String>[],
        totalAmount: json['total_amount'] ?? 0.0,
        txHash: json['tx_hash'] ?? '',
        txHex: json['tx_hex'] ?? '',
      );

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_height': blockHeight ?? 0,
        'coin': coin ?? '',
        'fee_details': feeDetails == null ? null : feeDetails.toJson(),
        'from': List<dynamic>.from(from.map<dynamic>((dynamic x) => x)) ??
            <String>[],
        'my_balance_change': myBalanceChange ?? 0.0,
        'received_by_me': receivedByMe ?? 0.0,
        'spent_by_me': spentByMe ?? 0.0,
        'to':
            List<dynamic>.from(to.map<dynamic>((dynamic x) => x)) ?? <String>[],
        'total_amount': totalAmount ?? 0.0,
        'tx_hash': txHash ?? '',
        'tx_hex': txHex ?? '',
      };
}
