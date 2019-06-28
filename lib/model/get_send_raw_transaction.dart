// To parse this JSON data, do
//
//     final getSendRawTransaction = getSendRawTransactionFromJson(jsonString);

import 'dart:convert';

GetSendRawTransaction getSendRawTransactionFromJson(String str) => GetSendRawTransaction.fromJson(json.decode(str));

String getSendRawTransactionToJson(GetSendRawTransaction data) => json.encode(data.toJson());

class GetSendRawTransaction {
    String method;
    String coin;
    String txHex;
    String userpass;

    GetSendRawTransaction({
        this.method,
        this.coin,
        this.txHex,
        this.userpass,
    });

    factory GetSendRawTransaction.fromJson(Map<String, dynamic> json) => new GetSendRawTransaction(
        method: json["method"] == null ? null : json["method"],
        coin: json["coin"] == null ? null : json["coin"],
        txHex: json["tx_hex"] == null ? null : json["tx_hex"],
        userpass: json["userpass"] == null ? null : json["userpass"],
    );

    Map<String, dynamic> toJson() => {
        "method": method == null ? null : method,
        "coin": coin == null ? null : coin,
        "tx_hex": txHex == null ? null : txHex,
        "userpass": userpass == null ? null : userpass,
    };
}
