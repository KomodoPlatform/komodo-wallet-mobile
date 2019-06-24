import 'dart:convert';

GetEnabledCoin getEnabledCoinFromJson(String str) {
  final jsonData = json.decode(str);
  return GetEnabledCoin.fromJson(jsonData);
}

String getEnabledCoinToJson(GetEnabledCoin data) {
  final dyn = data.toJson();
  if (data.swap_contract_address == null) {
    dyn.remove("swap_contract_address");
  }

  print(dyn.toString());
  return json.encode(dyn);
}

class GetEnabledCoin {
  String userpass;
  String method;
  String coin;
  String swap_contract_address;
  List<String> urls;
  bool tx_history;

  GetEnabledCoin(
      {this.userpass,
      this.method,
      this.coin,
      this.swap_contract_address,
      this.urls,
      this.tx_history});

  factory GetEnabledCoin.fromJson(Map<String, dynamic> json) =>
      new GetEnabledCoin(
        userpass: json["userpass"],
        method: json["method"],
        coin: json["coin"],
        tx_history: json["tx_history"],
        swap_contract_address: json["swap_contract_address"],
        urls: new List<String>.from(json["urls"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "coin": coin,
        "tx_history": tx_history,
        "swap_contract_address": swap_contract_address,
        "urls": new List<dynamic>.from(urls.map((x) => x)),
      };
}