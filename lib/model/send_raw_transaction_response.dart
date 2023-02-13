// To parse this JSON data, do
//
//     final sendRawTransactionResponse = sendRawTransactionResponseFromJson(jsonString);

import 'dart:convert';

SendRawTransactionResponse sendRawTransactionResponseFromJson(String str) =>
    SendRawTransactionResponse.fromJson(json.decode(str));

String sendRawTransactionResponseToJson(SendRawTransactionResponse data) =>
    json.encode(data.toJson());

class SendRawTransactionResponse {
  SendRawTransactionResponse({
    this.txHash,
  });

  factory SendRawTransactionResponse.fromJson(Map<String, dynamic> json) =>
      SendRawTransactionResponse(txHash: json['tx_hash'] ?? '');

  String? txHash;

  Map<String, dynamic> toJson() => <String, dynamic>{'tx_hash': txHash ?? ''};
}
