// To parse this JSON data, do
//
//     final getEnabledCoin = getEnabledCoinFromJson(jsonString);

import 'dart:convert';

GetEnabledCoin getEnabledCoinFromJson(String str) => GetEnabledCoin.fromJson(json.decode(str));

String getEnabledCoinToJson(GetEnabledCoin data) {
  final dyn = data.toJson();
  if (data.swapContractAddress == null) {
    dyn.remove("swap_contract_address");
  }

  print(dyn.toString());
  return json.encode(dyn);
}
class GetEnabledCoin {
    String userpass;
    String method;
    String coin;
    List<String> urls;
    String swapContractAddress;
      bool txHistory;


    GetEnabledCoin({
        this.userpass,
        this.method,
        this.coin,
        this.urls,
        this.txHistory,
        this.swapContractAddress,
    });

    factory GetEnabledCoin.fromJson(Map<String, dynamic> json) => new GetEnabledCoin(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        coin: json["coin"] == null ? null : json["coin"],
        txHistory: json["tx_history"],
        urls: json["urls"] == null ? null : new List<String>.from(json["urls"].map((x) => x)),
        swapContractAddress: json["swap_contract_address"] == null ? null : json["swap_contract_address"],
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "coin": coin == null ? null : coin,
        "tx_history": txHistory == null ? null : txHistory,
        "urls": urls == null ? null : new List<dynamic>.from(urls.map((x) => x)),
        "swap_contract_address": swapContractAddress == null ? null : swapContractAddress,
    };
}
