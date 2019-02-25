import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_active_coin.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'dart:io' show File, Platform, Process, ProcessResult;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/orderbook.dart';

String url = 'http://10.0.2.2:7783';
String userpass = "password";

MarketMakerService mm2 = MarketMakerService();

class MarketMakerService {
  List<Coin> coins = List<Coin>();
  bool activeCoinBool = true;

  MarketMakerService() {
    if (Platform.isAndroid) {
      url = 'http://10.0.2.2:7783';
    } else if (Platform.isIOS) {
      url = 'http://localhost:7783';
    }
  }

  Future<ProcessResult> runBin() async {
    ByteData resultmm2 = await rootBundle.load("assets/mm2");
    await writeData(resultmm2.buffer.asUint8List());

    ProcessResult resultLS = await Process.run('ls', [
      '-la',
      '/data/data/com.komodoplatform.komododex/files/'
    ]);

    // print(resultLS.stdout);
    // print(resultLS.stderr);

    ProcessResult resultChmod = await Process.run('chmod', [
      '+x',
      '/data/data/com.komodoplatform.komododex/files/mm2'
    ]);
    // print(resultChmod.stdout);
    // print(resultChmod.stderr);

    String coins = '[{\"coin\": \"PIZZA\",\"asset\": \"PIZZA\",\"txversion\":4,\"rpcport\":11608},{\"coin\": \"BEER\",\"txversion\":4,\"asset\": \"BEER\",\"rpcport\": 8923}]';
    String passphrase = "seventy cuddly simmering trillion armored grout unadorned scouts ranch skeptic parlor exhale";

    ProcessResult runmm2 = await Process.run('./data/data/com.komodoplatform.komododex/files/mm2', [
      '{\"gui\":\"MM2GUI\",\"netid\":9999,\"client\":1,\"userhome\":\"\/data/data/com.komodoplatform.komododex/files/\",\"passphrase\":\"$passphrase\",\"coins\":$coins}',
      '&'
    ]);
    print(runmm2.stdout);
    print(runmm2.stderr);

    return resultLS;
  }

  Future<File> get _localFile async {
    return File('/data/data/com.komodoplatform.komododex/files/mm2');
  }

  Future<File> writeData(List<int> data) async {
    final file = await _localFile;
    return file.writeAsBytes(data);
  }

  Future<Orderbook> getOrderbook(Coin coinBase, Coin coinRel) async {
    GetOrderbook getOrderbook = new GetOrderbook(
        userpass: userpass,
        method: 'orderbook',
        base: coinBase.abbr,
        rel: coinRel.abbr);
    final response = await http.post(url, body: json.encode(getOrderbook));
    print(response.body.toString());
    return orderbookFromJson(response.body);
  }

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
    print(response.body.toString());
    return balanceFromJson(response.body);
  }

  Future<List<Balance>> getAllBalances() async {
    List<Balance> balances = new List<Balance>();
    List<Future<Balance>> futureBalances = new List<Future<Balance>>();

    for (var coin in coins) {
      futureBalances.add(getBalance(coin));
    }
    balances = await Future.wait(futureBalances);
    return balances;
  }

  Future<dynamic> postBuy(
      Coin base, Coin rel, double relVolume, double price) async {
    GetBuy getBuy = new GetBuy(
        userpass: userpass,
        method: "buy",
        base: base.abbr,
        rel: rel.abbr,
        relvolume: relVolume,
        price: price);
    final response = await http.post(url, body: json.encode(getBuy));
    print(response.body.toString());
    try {
      return buyResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> activeCoin(Coin coin) async {
    GetActiveCoin getActiveCoin = new GetActiveCoin(
        userpass: userpass,
        method: "electrum",
        coin: coin.abbr,
        urls: coin.serverList);

    final response = await http.post(url, body: json.encode(getActiveCoin));
    print(response.body.toString());
    try {
      return activeCoinFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<String> loadElectrumServersAsset() async {
    return await rootBundle.loadString('assets/coins_config.json');
  }

  Future<List<CoinBalance>> loadCoins() async {
    List<CoinBalance> listCoinElectrum = new List<CoinBalance>();
    List<Future<dynamic>> futureActiveCoins = new List<Future<dynamic>>();

    if (this.coins.isEmpty) {
      this.activeCoinBool = false;
      await this.loadJsonCoins();
    }

    for (var coin in this.coins) {
      if (!coin.isActive) {
        futureActiveCoins.add(this.activeCoin(coin));
        coin.isActive = true;
      }
    }
    await Future.wait(futureActiveCoins);

    List<Balance> balances = await getAllBalances();

    for (var coin in this.coins) {
      for (var balance in balances) {
        if (coin.abbr == balance.coin)
          listCoinElectrum.add(CoinBalance(coin, balance));
      }
    }

    listCoinElectrum
        .sort((a, b) => a.balance.balance.compareTo(b.balance.balance));
    return listCoinElectrum.reversed.toList();
  }
}
