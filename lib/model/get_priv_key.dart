import 'dart:convert';

GetPrivKey getPrivKeyFromJson(String str) =>
    GetPrivKey.fromJson(json.decode(str));

String getPrivKeyToJson(GetPrivKey data) => json.encode(data.toJson());

class GetPrivKey {
  GetPrivKey({
    this.userpass,
    this.method = 'show_priv_key',
    this.coin,
  });

  factory GetPrivKey.fromJson(Map<String, dynamic> json) => GetPrivKey(
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
        coin: json['coin'] ?? '',
      );

  String? userpass;
  String method;
  String? coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
      };
}
