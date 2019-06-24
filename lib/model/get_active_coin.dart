// To parse this JSON data, do
//
//     final getActiveCoin = getActiveCoinFromJson(jsonString);

import 'dart:convert';

GetActiveCoin getActiveCoinFromJson(String str) =>
    GetActiveCoin.fromJson(json.decode(str));

String getActiveCoinToJson(GetActiveCoin data) {
  final dyn = data.toJson();
  if (data.swapContractAddress == null) {
    dyn.remove("swap_contract_address");
  }
  return json.encode(dyn);
}

class GetActiveCoin {
  String userpass;
  String method;
  String coin;
  List<Server> servers;
  bool txHistory;
  String swapContractAddress;

  GetActiveCoin(
      {this.userpass,
      this.method,
      this.coin,
      this.swapContractAddress,
      this.servers,
      this.txHistory});

  factory GetActiveCoin.fromJson(Map<String, dynamic> json) =>
      new GetActiveCoin(
        userpass: json["userpass"],
        method: json["method"],
        coin: json["coin"],
        txHistory: json["tx_history"],
        swapContractAddress: json["swap_contract_address"],
        servers: new List<Server>.from(
            json["servers"].map((x) => Server.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "userpass": userpass,
        "method": method,
        "coin": coin,
        "tx_history": txHistory,
        "swap_contract_address": swapContractAddress,
        "servers": new List<dynamic>.from(servers.map((x) => x.toJson())),
      };
}

class Server {
  String url;
  String protocol;
  bool disableCertVerification;

  Server({
    this.url,
    this.protocol,
    this.disableCertVerification,
  });

  factory Server.fromJson(Map<String, dynamic> json) => new Server(
        url: json["url"],
        protocol: json["protocol"] == null ? null : json["protocol"],
        disableCertVerification: json["disable_cert_verification"] == null
            ? null
            : json["disable_cert_verification"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "protocol": protocol == null ? null : protocol,
        "disable_cert_verification":
            disableCertVerification == null ? null : disableCertVerification,
      };
}
