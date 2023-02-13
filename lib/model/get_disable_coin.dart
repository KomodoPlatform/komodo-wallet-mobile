// To parse this JSON data, do
//
//     final getDisableCoin = getDisableCoinFromJson(jsonString);

class GetDisableCoin {
  GetDisableCoin({
    this.userpass,
    this.method = 'disable_coin',
    this.coin,
  });

  factory GetDisableCoin.fromJson(Map<String, dynamic> json) => GetDisableCoin(
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
