import 'dart:convert';

String getMaxTakerVolumeToJson(GetMaxTakerVolume data) =>
    json.encode(data.toJson());

class GetMaxTakerVolume {
  GetMaxTakerVolume({
    this.userpass,
    this.method = 'max_taker_vol',
    this.coin,
  });

  factory GetMaxTakerVolume.fromJson(Map<String, dynamic> json) {
    return GetMaxTakerVolume(
      userpass: json['userpass'] ?? '',
      method: json['method'] ?? '',
      coin: json['coin'],
    );
  }

  String? userpass;
  String method;
  String? coin;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'coin': coin ?? '',
      };
}
