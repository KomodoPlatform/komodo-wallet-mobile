import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

LinkedHashMap<String, Coin> _coins;
bool _coinsInvoked = false;

/// A cached list of coins.
/// Most fields are loaded from “coins_init_mm2.json”.
/// List of coins, their electrums and webs - are loaded from “coins_config.json”.
///
/// For ease of maintenance the “coins_init_mm2.json” should be an exact copy of
/// https://github.com/jl777/coins/blob/master/coins,
/// that way we can update it with a simple overwrite.
///
/// A coin can be absent from “coins_init_mm2.json” and fully defined in “coins_config.json”,
/// the “VOTE” coin is currently defined that way.
Future<LinkedHashMap<String, Coin>> get coins async {
  // Protect from loading coins multiple times from parallel green threads.
  if (_coinsInvoked) {
    while (_coins == null) await sleepMs(77);
    return _coins;
  }
  _coinsInvoked = true;

  Log('coin:29', 'Loading coins_init_mm2.json…');
  const ci = 'assets/coins_init_mm2.json';
  final cis = await rootBundle.loadString(ci, cache: false);
  final List<dynamic> cil = json.decode(cis);
  final Map<String, Map<String, dynamic>> cim = {};
  for (dynamic js in cil) cim[js['coin']] = Map<String, dynamic>.from(js);

  Log('coin:36', 'Loading coins_config.json…');
  const cc = 'assets/coins_config.json';
  final ccs = await rootBundle.loadString(cc, cache: false);
  final List<dynamic> ccl = json.decode(ccs);
  final coins = LinkedHashMap<String, Coin>.of({});
  for (dynamic js in ccl) {
    final String ticker = js['abbr'];
    final config = Map<String, dynamic>.of(js);
    Map<String, dynamic> init = cim[ticker];
    if (init == null) {
      Log('coin:46', 'Coin $ticker is not in “coins_init_mm2.json”');
      init = config;
    }
    coins[ticker] = Coin.fromJson(init, config);
  }

  return _coins = coins;
}

class Coin {
  Coin({this.type, this.abbr, this.swapContractAddress, this.serverList});

  /// Construct the coin from two JSON maps:
  /// [init] is from coins_init_mm2.json, an exact copy of https://github.com/jl777/coins/blob/master/coins;
  /// [config] is from coins_config.json, for fields that are missing from [init].
  Coin.fromJson(Map<String, dynamic> init, Map<String, dynamic> config) {
    init ??= <String, dynamic>{};
    config ??= <String, dynamic>{};

    type = config['type'] ?? '';
    name = config['name'] ?? init['fname'] ?? '';
    address = config['address'] ?? '';
    port = config['port'] ?? 0;
    proto = config['proto'] ?? '';
    txfee = init['txfee'] ?? 0;
    mm2 = init['mm2'] ?? 0;
    abbr = init['coin'] ?? config['abbr'] ?? '';
    coingeckoId = config['coingeckoId'] ?? '';
    swapContractAddress = config['swap_contract_address'] ?? '';
    colorCoin = config['colorCoin'] ?? '';
    serverList = List<String>.from(config['serverList']);
    explorerUrl = List<String>.from(config['explorerUrl']);
    requiredConfirmations = init['required_confirmations'];
    requiresNotarization = init['requires_notarization'] ?? false;
    addressFormat = init['address_format'];
  }

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

  /// NB: If the initial value is `null` then it might be updated from MM during the coin activation.
  int requiredConfirmations;
  bool requiresNotarization;
  Map<String, dynamic> addressFormat;

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
        'swap_contract_address': swapContractAddress ?? '',
        'colorCoin': colorCoin ?? '',
        'serverList':
            List<dynamic>.from(serverList.map<String>((dynamic x) => x)) ??
                <String>[],
        'explorerUrl':
            List<dynamic>.from(explorerUrl.map<String>((dynamic x) => x)) ??
                <String>[],
        'required_confirmations': requiredConfirmations,
        'requires_notarization': requiresNotarization,
        'address_format': addressFormat,
      };

  String getTxFeeSatoshi() {
    int txFeeRes = 0;
    if (txfee != null) {
      txFeeRes = txfee;
    }
    return (txFeeRes / 100000000).toString();
  }
}
