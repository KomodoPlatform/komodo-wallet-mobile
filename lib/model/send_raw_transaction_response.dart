// To parse this JSON data, do
//
//     final sendRawTransactionResponse = sendRawTransactionResponseFromJson(jsonString);

import 'dart:convert';

SendRawTransactionResponse sendRawTransactionResponseFromJson(String str) => SendRawTransactionResponse.fromJson(json.decode(str));

String sendRawTransactionResponseToJson(SendRawTransactionResponse data) => json.encode(data.toJson());

class SendRawTransactionResponse {
    String txHash;

    SendRawTransactionResponse({
        this.txHash,
    });

    factory SendRawTransactionResponse.fromJson(Map<String, dynamic> json) => new SendRawTransactionResponse(
        txHash: json["tx_hash"] == null ? null : json["tx_hash"],
    );

    Map<String, dynamic> toJson() => {
        "tx_hash": txHash == null ? null : txHash,
    };
}
