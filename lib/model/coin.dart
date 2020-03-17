// To parse this JSON data, do
//
//     final coin = coinFromJson(jsonString);

import 'dart:convert';

List<Coin> coinFromJson(String str) =>
    List<Coin>.from(json.decode(str).map((dynamic x) => Coin.fromJson(x)));

String coinToJson(List<Coin> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((dynamic x) => x.toJson())));

// NB: This is a custom format used in coins_config.json
// 
// https://github.com/jl777/coins/blob/master/coins corresponds to coins_init_mm2.json
// and is handled elsewhere.

class Coin {
  Coin({
    this.name,
    this.address,
    this.port,
    this.proto,
    this.txfee,
    this.priceUsd,
    this.mm2,
    this.abbr,
    this.coingeckoId,
    this.swapContractAddress,
    this.colorCoin,
    this.serverList,
    this.explorerUrl,
    this.type,
    this.requiredConfirmations
  });

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
      type: json['type'] ?? '',
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        port: json['port'] ?? 0,
        proto: json['proto'] ?? '',
        txfee: json['txfee'] ?? 0,
        priceUsd: json['priceUSD'] ?? 0.0,
        mm2: json['mm2'] ?? 0,
        abbr: json['abbr'] ?? '',
        coingeckoId: json['coingeckoId'] ?? '',
        swapContractAddress: json['swap_contract_address'] ?? '',
        colorCoin: json['colorCoin'] ?? '',
        serverList: List<String>.from(json['serverList'].map((dynamic x) => x)) ?? <String>[],
        explorerUrl: List<String>.from(json['explorerUrl'].map((dynamic x) => x)) ?? <String>[],
        requiredConfirmations: json['required_confirmations']
      );

  String type; // 'other', 'erc' or 'smartChain'
  String name;
  String address;
  int port;
  String proto;
  int txfee;
  double priceUsd;
  int mm2;
  /// Aka "coin", "ticker".
  String abbr;
  String coingeckoId;
  String colorCoin;
  List<String> serverList;
  List<String> explorerUrl;
  String swapContractAddress;
  int requiredConfirmations;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type ?? '',
        'name': name ?? '',
        'address': address ?? '',
        'port': port ?? 0,
        'proto': proto ?? '',
        'txfee': txfee ?? 0,
        'priceUSD': priceUsd ?? 0.0,
        'mm2': mm2 ?? 0,
        'abbr': abbr ?? '',
        'coingeckoId': coingeckoId ?? '',
        'swap_contract_address':
            swapContractAddress ?? '',
        'colorCoin': colorCoin ?? '',
        'serverList': List<dynamic>.from(serverList.map<String>((dynamic x) => x)) ?? <String>[],
        'explorerUrl': List<dynamic>.from(explorerUrl.map<String>((dynamic x) => x)) ?? <String>[],
        'required_confirmations': requiredConfirmations
      };

  String getTxFeeSatoshi() {
    int txFeeRes = 0;
    if (txfee != null) {
      txFeeRes = txfee;
    }
    return (txFeeRes / 100000000).toString();
  }
}
