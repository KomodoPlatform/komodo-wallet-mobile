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
