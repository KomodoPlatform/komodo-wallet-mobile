import 'dart:convert';

GetRecoverFundsOfSwap getRecoverFundsOfSwapFromJson(String str) => GetRecoverFundsOfSwap.fromJson(json.decode(str));

String getRecoverFundsOfSwapToJson(GetRecoverFundsOfSwap data) => json.encode(data.toJson());

class GetRecoverFundsOfSwap {
  GetRecoverFundsOfSwap({
    this.method = 'recover_funds_of_swap',
    this.params,
    this.userpass,
  });

  factory GetRecoverFundsOfSwap.fromJson(Map<String, dynamic> json) => GetRecoverFundsOfSwap(
        method: json['method'] ?? '',
        params: Params.fromJson(json['params']) ?? Params(),
        userpass: json['userpass'] ?? '',
      );

  String method;
  Params params;
  String userpass;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        'params': params ?? '',
        'userpass': userpass ?? '',
      };
}

class Params {
  Params({
    this.uuid,
  });

  factory Params.fromJson(Map<String, dynamic> json) => Params(
        uuid: json['uuid'] ?? '',
      );

  String uuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uuid': uuid ?? '',
      };
}