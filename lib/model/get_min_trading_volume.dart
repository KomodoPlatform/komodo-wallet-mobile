import 'dart:convert';

String getMinTradingVolumeToJson(GetMinTradingVolume data) =>
    json.encode(data.toJson());

class GetMinTradingVolume {
  GetMinTradingVolume({
    this.userpass,
    this.method = 'min_trading_vol',
    this.coin,
  });

  factory GetMinTradingVolume.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return GetMinTradingVolume(
      userpass: json['userpass'] ?? '',
      method: json['method'] ?? '',
      coin: json['coin'],
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
