// To parse this JSON data, do
//
//     final batchRequest = batchRequestFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/get_active_coin.dart';

BatchRequest batchRequestFromJson(String str) =>
    BatchRequest.fromJson(json.decode(str));

String batchRequestToJson(BatchRequest data) =>
    json.encode(data.toJson());

class BatchRequest {
  BatchRequest({
    this.method = 'electrum',
    this.coin,
    this.servers,
    this.userpass,
    this.mm2 = 1,
  });

  factory BatchRequest.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['servers'];
    final servers = list.map((dynamic x) => Server.fromJson(x)).toList();

      return BatchRequest(
        method: json['method'] ?? '',
        coin: json['coin'] ?? '',
        servers: servers ?? '',
        userpass: json['userpass'] ?? '',
        mm2: json['mm2'] ?? '',
      );
  }

  String method;
  String coin;
  List<Server> servers;
  String userpass;
  int mm2;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        'coin': coin ?? '',
        'servers': servers ?? '',
        'userpass': userpass ?? '',
        'mm2': mm2 ?? '',
      };
}
