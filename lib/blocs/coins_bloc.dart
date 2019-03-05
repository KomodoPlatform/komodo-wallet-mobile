import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:path_provider/path_provider.dart';

class CoinsBloc implements BlocBase {
  List<CoinBalance> coinBalance = new List<CoinBalance>();

  // Streams to handle the list coin
  StreamController<List<CoinBalance>> _coinsController =
      StreamController<List<CoinBalance>>.broadcast();

  Sink<List<CoinBalance>> get _inCoins => _coinsController.sink;
  Stream<List<CoinBalance>> get outCoins => _coinsController.stream;

  var timer;

  @override
  void dispose() {
    _coinsController.close();
  }

  void resetCoinBalance() {
    coinBalance.clear();
    _inCoins.add(coinBalance);
  }

  void updateCoins(List<CoinBalance> coins) {
    coinBalance = coins;
    _inCoins.add(coinBalance);
  }

  void updateOneCoin(CoinBalance coin) async {
    coin.balance = await mm2.getBalance(coin.coin);
    coinBalance.forEach((coinBalance) {
      if (coin.coin.abbr == coinBalance.coin.abbr) {
        this.coinBalance.remove(coinBalance);
        this.coinBalance.add(coin);
        _inCoins.add(this.coinBalance);
      }
    });
  }

  Future<void> updateBalanceForEachCoin(bool forceUpdate) async {
    if (mm2.mm2Ready)
      await mm2.loadCoin(forceUpdate);
  }

  void addCoin(Coin coin) async {
    print('Adding coin ${coin.abbr}');
    List<Coin> coins = await readJsonCoin();
    coins.add(coin);
    await writeJsonCoin(coins);
    await mm2.activeCoin(coin);
    Balance balance = await mm2.getBalance(coin);
    this.coinBalance.add(CoinBalance(coin, balance));
    _inCoins.add(this.coinBalance);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/coins_activate_default.json');
  }

  Future<File> writeJsonCoin(List<Coin> coins) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(coins));
  }

  Future<List<Coin>> readJsonCoin() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return listCoinFromJson(contents);
    } catch (e) {
      // If encountering an error, return 0
      print("ERROR FILE");
      print(e);
      return new List<Coin>();
    }
  }

  void startCheckBalance() {
    timer = Timer.periodic(Duration(seconds: 60), (_) {
      updateBalanceForEachCoin(true);
    });
  }

  void stopCheckBalance() {
    if (timer != null)
      timer.cancel();
  }

}

final coinsBloc = CoinsBloc();
