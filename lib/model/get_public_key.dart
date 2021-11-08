import 'dart:convert';

GetPublicKey getPublicKeyFromJson(String str) =>
    GetPublicKey.fromJson(json.decode(str));

String getPublicKeyToJson(GetPublicKey data) => json.encode(data.toJson());

class GetPublicKey {
  GetPublicKey({
    this.mmrpc = '2.0',
    this.userpass,
    this.method = 'get_public_key',
  });

  factory GetPublicKey.fromJson(Map<String, dynamic> json) => GetPublicKey(
        mmrpc: json['mmrpc'] ?? '',
        userpass: json['userpass'] ?? '',
        method: json['method'] ?? '',
      );

  String mmrpc;
  String userpass;
  String method;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mmrpc': mmrpc ?? '',
        'userpass': userpass ?? '',
        'method': method ?? '',
        'params': <dynamic, dynamic>{},
        'id': 0,
      };
}
