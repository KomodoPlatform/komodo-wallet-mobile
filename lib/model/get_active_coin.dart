// To parse this JSON data, do
//
//     final getActiveCoin = getActiveCoinFromJson(jsonString);

import 'dart:convert';

GetActiveCoin getActiveCoinFromJson(String str) => GetActiveCoin.fromJson(json.decode(str));

String getActiveCoinToJson(GetActiveCoin data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
class GetActiveCoin {
    String userpass;
    String method;
    String coin;
    List<Server> servers;
      bool txHistory;


    GetActiveCoin({
        this.userpass,
        this.method,
        this.coin,
        this.servers,
      this.txHistory
    });

    factory GetActiveCoin.fromJson(Map<String, dynamic> json) => new GetActiveCoin(
        userpass: json["userpass"] == null ? null : json["userpass"],
        method: json["method"] == null ? null : json["method"],
        coin: json["coin"] == null ? null : json["coin"],
        txHistory: json["tx_history"] == null ? null : json["tx_history"],
        servers: json["servers"] == null ? null : new List<Server>.from(json["servers"].map((x) => Server.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "userpass": userpass == null ? null : userpass,
        "method": method == null ? null : method,
        "coin": coin == null ? null : coin,
        "tx_history": txHistory == null ? null : txHistory,
        "servers": servers == null ? null : new List<dynamic>.from(servers.map((x) => x.toJson())),
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
        url: json["url"] == null ? null : json["url"],
        protocol: json["protocol"] == null ? null : json["protocol"],
        disableCertVerification: json["disable_cert_verification"] == null ? null : json["disable_cert_verification"],
    );

    Map<String, dynamic> toJson() => {
        "url": url == null ? null : url,
        "protocol": protocol == null ? null : protocol,
        "disable_cert_verification": disableCertVerification == null ? null : disableCertVerification,
    };
}