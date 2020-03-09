class MmElectrum {
  MmElectrum(
      {this.userpass,
      this.method = 'electrum',
      this.coin,
      this.servers,
      this.txHistory});

  factory MmElectrum.fromJson(Map<String, dynamic> json) => MmElectrum(
      userpass: json['userpass'] ?? '',
      method: json['method'] ?? '',
      coin: json['coin'] ?? '',
      txHistory: json['tx_history'] ?? false,
      servers: List<Server>.from(json['servers']
              .map<dynamic>((dynamic x) => Server.fromJson(x))) ??
          <Server>[]);
  String userpass;
  String method;
  String coin;
  List<Server> servers;
  bool txHistory;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
        'tx_history': txHistory ?? false,
        'servers': List<dynamic>.from(
                servers.map<dynamic>((dynamic x) => x.toJson())) ??
            <Server>[]
      };
}

class Server {
  Server({
    this.url,
    this.protocol,
    this.disableCertVerification,
  });

  factory Server.fromJson(Map<String, dynamic> json) => Server(
        url: json['url'] ?? '',
        protocol: json['protocol'] ?? '',
        disableCertVerification: json['disable_cert_verification'] ?? false,
      );

  String url;
  String protocol;
  bool disableCertVerification;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url ?? '',
        'protocol': protocol ?? '',
        'disable_cert_verification': disableCertVerification ?? false,
      };
}
