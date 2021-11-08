import 'dart:convert';

String publicKeyToJson(PublicKey data) => json.encode(data.toJson());

class PublicKey {
  PublicKey({
    this.mmrpc,
    this.result,
    this.id,
  });

  factory PublicKey.fromJson(Map<String, dynamic> json) => PublicKey(
        mmrpc: json['mmrpc'] ?? '',
        result: Result.fromJson(json['result']),
        id: json['id'] ?? '',
      );

  String mmrpc;
  Result result;
  int id;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson(),
      };
}

class Result {
  Result({this.publicKey});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        publicKey: json['public_key'] ?? '',
      );

  String publicKey;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'public_key': publicKey ?? '',
      };
}
