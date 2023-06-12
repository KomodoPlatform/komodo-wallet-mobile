import 'dart:convert';

String privKeyToJson(PrivKey data) => json.encode(data.toJson());

class PrivKey {
  PrivKey({
    this.result,
  });

  factory PrivKey.fromJson(Map<String, dynamic> json) => PrivKey(
        result: Result.fromJson(json['result']),
      );

  Result result;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'result': result.toJson(),
      };

  @override
  String toString() {
    return 'PrivKey{result: ${'*' * result.privKey.length}}';
  }
}

class Result {
  Result({this.coin, this.privKey});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        coin: json['coin'] ?? '',
        privKey: json['priv_key'] ?? '',
      );

  String coin;
  String privKey;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin ?? '',
        'priv_key': privKey ?? '',
      };
}
