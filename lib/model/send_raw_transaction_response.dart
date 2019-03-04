// To parse this JSON data, do
//
//     final sendRawTransactionResponse = sendRawTransactionResponseFromJson(jsonString);

import 'dart:convert';

SendRawTransactionResponse sendRawTransactionResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return SendRawTransactionResponse.fromJson(jsonData);
}

String sendRawTransactionResponseToJson(SendRawTransactionResponse data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class SendRawTransactionResponse {
  String txHash;

  SendRawTransactionResponse({
    this.txHash,
  });

  factory SendRawTransactionResponse.fromJson(Map<String, dynamic> json) =>
      new SendRawTransactionResponse(
        txHash: json["tx_hash"],
      );

  Map<String, dynamic> toJson() => {
        "tx_hash": txHash,
      };
}
