// To parse this JSON data, do
//
//     final configMm2 = configMm2FromJson(jsonString);

import 'dart:convert';

import 'coin_init.dart';

ConfigMm2 configMm2FromJson(String str) => ConfigMm2.fromJson(json.decode(str));

String configMm2ToJson(ConfigMm2 data) => json.encode(data.toJson());

class ConfigMm2 {
  ConfigMm2(
      {this.gui,
      this.netid,
      this.client,
      this.userhome,
      this.passphrase,
      this.rpcPassword,
      this.coins,
      this.dbdir,
      this.seednodes});

  factory ConfigMm2.fromJson(Map<String, dynamic> json) => ConfigMm2(
      gui: json['gui'],
      netid: json['netid'],
      client: json['client'],
      userhome: json['userhome'],
      passphrase: json['passphrase'],
      rpcPassword: json['rpc_password'],
      coins: List<CoinInit>.from(json['coins']
              .map<dynamic>((dynamic x) => CoinInit.fromJson(x))) ??
          <CoinInit>[],
      dbdir: json['dbdir'],
      seednodes: List<String>.from(json['seednodes'].map((dynamic x) => x)) ??
          <String>[]);

  String gui;
  int netid;
  int client;
  String userhome;
  String passphrase;
  String rpcPassword;
  List<CoinInit> coins;
  String dbdir;
  List<String> seednodes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'gui': gui,
        'netid': netid,
        'client': client,
        'userhome': userhome,
        'passphrase': passphrase,
        'rpc_password': rpcPassword,
        'coins':
            List<dynamic>.from(coins.map<dynamic>((dynamic x) => x.toJson())) ??
                <CoinInit>[],
        'dbdir': dbdir,
        'seednodes': seednodes == null
            ? null
            : List<dynamic>.from(seednodes.map<dynamic>((String x) => x))
      };
}
