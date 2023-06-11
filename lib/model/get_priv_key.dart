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

  factory GetPrivKey.fromJson(Map<String, dynamic> json) {
    json = {
      'userpass':
          (json['userpass'] as String ?? json['userpass'] as dynamic) ?? '',
      'method': (json['method'] as String ?? json['method'] as dynamic) ?? '',
      'coin': (json['coin'] as String ?? json['coin'] as dynamic) ?? '',
    };
    return GetPrivKey(
      userpass: json['userpass'] as String,
      method: json['method'] as String,
      coin: json['coin'] as String,
    );
  }

  String userpass;
  String method;
  String coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
      };
}
