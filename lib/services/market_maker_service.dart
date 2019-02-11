import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_active_coin.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show rootBundle;

String url = 'http://10.0.2.2:7783';
String userpass =
    "80c55cfc36648f2541c3ca95e163ee9da904987e28c33a69fd735032f0523058";

class MarketMakerService {
  static final MarketMakerService _singleton = new MarketMakerService._internal();
  List<Coin> coins = List<Coin>();
  bool activeCoinBool = true;

  factory MarketMakerService() {
    if (Platform.isAndroid) {
      url = 'http://10.0.2.2:7783';
    } else if (Platform.isIOS) {
      url = 'http://localhost:7783';
    }
    return _singleton;
  }

  MarketMakerService._internal();

  Future<List<Coin>> loadJsonCoins() async {
    String jsonString = await this.loadElectrumServersAsset();
    Iterable l = json.decode(jsonString);
    List<Coin> coins = l.map((model) => Coin.fromJson(model)).toList();
    this.coins = coins;
    return coins;
  }

  Future<Balance> getBalance(Coin coin) async {
    GetBalance getBalance = new GetBalance(
        userpass: userpass, method: "my_balance", coin: coin.abbr);
    final response = await http.post(url, body: json.encode(getBalance));
    return balanceFromJson(response.body);
  }

  Future<dynamic> activeCoin(Coin coin) async {
    GetActiveCoin getActiveCoin = new GetActiveCoin(
        userpass: userpass,
        method: "electrum",
        coin: coin.abbr,
        urls: coin.serverList);

    final response = await http.post(url, body: json.encode(getActiveCoin));
    print("coin" + coin.name + " result:" + response.body);
    try {
      return activeCoinFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<String> loadElectrumServersAsset() async {
    return await rootBundle.loadString('assets/electrum_servers.json');
  }

  Future<List<CoinBalance>> loadCoins() async {
    List<CoinBalance> listCoinElectrum = new List<CoinBalance>();
    if (this.coins.isEmpty) {
      this.activeCoinBool = false;
      await this.loadJsonCoins();
    }

    for (var coin in this.coins) {
      if (!coin.isActive) {
        await this.activeCoin(coin);
        coin.isActive = true;
      }
      
      Balance balance = await this.getBalance(coin);
      listCoinElectrum.add(CoinBalance(coin, balance));
    }

    listCoinElectrum
        .sort((a, b) => a.balance.balance.compareTo(b.balance.balance));
    return listCoinElectrum.reversed.toList();
  }
}
