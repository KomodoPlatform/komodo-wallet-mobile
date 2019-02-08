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
  return json.encode(dyn);
}

class GetActiveCoin {
  String userpass;
  String method;
  String coin;
  List<String> urls;

  GetActiveCoin({
    this.userpass,
    this.method,
    this.coin,
    this.urls,
  });

  factory GetActiveCoin.fromJson(Map<String, dynamic> json) => new GetActiveCoin(
    userpass: json["userpass"],
    method: json["method"],
    coin: json["coin"],
    urls: new List<String>.from(json["urls"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "userpass": userpass,
    "method": method,
    "coin": coin,
    "urls": new List<dynamic>.from(urls.map((x) => x)),
  };
}
