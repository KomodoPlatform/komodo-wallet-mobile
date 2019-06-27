import 'dart:convert';

GetEnabledCoin getEnabledCoinFromJson(String str) {
  final jsonData = json.decode(str);
  return GetEnabledCoin.fromJson(jsonData);
}

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
  String swapContractAddress;
  List<String> urls;
  bool txHistory;

  GetEnabledCoin(
      {this.userpass,
      this.method,
      this.coin,
      this.swapContractAddress,
      this.urls,
      this.txHistory});

  factory GetEnabledCoin.fromJson(Map<String, dynamic> json) =>
      new GetEnabledCoin(
        userpass: json["userpass"],
        method: json["method"],
        coin: json["coin"],
        txHistory: json["tx_history"],
        swapContractAddress: json["swap_contract_address"],
        urls: new List<String>.from(json["urls"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "coin": coin,
        "tx_history": txHistory,
        "swap_contract_address": swapContractAddress,
        "urls": new List<dynamic>.from(urls.map((x) => x)),
      };
}