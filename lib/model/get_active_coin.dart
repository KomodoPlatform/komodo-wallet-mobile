// To parse this JSON data, do
//
//     final getActiveCoin = getActiveCoinFromJson(jsonString);

import 'dart:convert';

GetActiveCoin getActiveCoinFromJson(String str) {
  final jsonData = json.decode(str);
  return GetActiveCoin.fromJson(jsonData);
}

String getActiveCoinToJson(GetActiveCoin data) {
  final dyn = data.toJson();
  if (data.swap_contract_address == null) {
    dyn.remove("swap_contract_address");
  }

  print(dyn.toString());
  return json.encode(dyn);
}

class GetActiveCoin {
  String userpass;
  String method;
  String coin;
  String swap_contract_address;
  List<String> urls;
  bool tx_history;

  GetActiveCoin(
      {this.userpass,
      this.method,
      this.coin,
      this.swap_contract_address,
      this.urls,
      this.tx_history});

  factory GetActiveCoin.fromJson(Map<String, dynamic> json) =>
      new GetActiveCoin(
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
