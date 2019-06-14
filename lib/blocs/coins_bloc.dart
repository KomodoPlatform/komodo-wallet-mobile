import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/services/getprice_service.dart';
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

  Transactions transactions = new Transactions();

  // Streams to handle the list coin
  StreamController<Transactions> _transactionsController =
      StreamController<Transactions>.broadcast();

  Sink<Transactions> get _inTransactions => _transactionsController.sink;
  Stream<Transactions> get outTransactions => _transactionsController.stream;

  List<Coin> coinToActivate = new List<Coin>();

  // Streams to handle the list coin to activate
  StreamController<List<Coin>> _coinToActivateController =
      StreamController<List<Coin>>.broadcast();

  Sink<List<Coin>> get _inCoinToActivate => _coinToActivateController.sink;
  Stream<List<Coin>> get outCoinToActivate => _coinToActivateController.stream;

  CoinToActivate currentActiveCoin = new CoinToActivate();

  // Streams to handle the list coin
  StreamController<CoinToActivate> _currentActiveCoinController =
      StreamController<CoinToActivate>.broadcast();

  Sink<CoinToActivate> get _inCurrentActiveCoin =>
      _currentActiveCoinController.sink;
  Stream<CoinToActivate> get outcurrentActiveCoin =>
      _currentActiveCoinController.stream;

  Coin failCoinActivate = new Coin();

  // Streams to handle the list coin
  StreamController<Coin> _failCoinActivateController =
      StreamController<Coin>.broadcast();

  Sink<Coin> get _inFailCoinActivate => _failCoinActivateController.sink;
  Stream<Coin> get outFailCoinActivate => _failCoinActivateController.stream;

  var timer;
  var timer2;

  @override
  void dispose() {
    _coinsController.close();
    _transactionsController.close();
    _coinToActivateController.close();
    _currentActiveCoinController.close();
    _failCoinActivateController.close();
  }

  void resetCoinBalance() {
    coinBalance.clear();
    _inCoins.add(coinBalance);
  }

  void resetTransactions() {
    transactions = new Transactions();
    _inTransactions.add(transactions);
  }

  void updateCoins(List<CoinBalance> coins) {
    coinBalance = coins;
    _inCoins.add(coinBalance);
  }

  Future<void> updateTransactions(Coin coin, int limit, String fromId) async {
    Transactions transactions = await mm2.getTransactions(coin, limit, fromId);

    if (fromId == null) {
      this.transactions = transactions;
    } else {
      this.transactions.result.fromId = transactions.result.fromId;
      this.transactions.result.limit = transactions.result.limit;
      this.transactions.result.skipped = transactions.result.skipped;
      this.transactions.result.total = transactions.result.total;
      this
          .transactions
          .result
          .transactions
          .addAll(transactions.result.transactions);
    }
    _inTransactions.add(this.transactions);
  }

  Future<void> addMultiCoins(List<Coin> coins, bool isSavedToLocal) async {
    List<Coin> coinsReadJson = await readJsonCoin();

    for (var coin in coins) {
      await mm2.activeCoin(coin).then((onValue) {
        if (onValue is ActiveCoin) {
          if (isSavedToLocal) coinsReadJson.add(coin);
          print(coin.abbr);
          currentCoinActivate(CoinToActivate(coin: coin, isActivate: true));
        } else if (onValue is ErrorString) {
          coinsReadJson.forEach((coinJson) {
            if (coinJson.abbr == coin.abbr && isSavedToLocal) {
              coinsReadJson.remove(coinJson);
            }
          });
          currentCoinActivate(CoinToActivate(coin: coin, isActivate: false));
          print('Sorry, coin not available ${coin.abbr}');
        }
      }).catchError((onError) {
        coinsReadJson.forEach((coinJson) {
          if (coinJson.abbr == coin.abbr && isSavedToLocal) {
            coinsReadJson.remove(coinJson);
          }
        });
        currentCoinActivate(CoinToActivate(coin: coin, isActivate: false));
        print('Sorry, coin not available ${coin.abbr}');
      });
    }
    if (isSavedToLocal) await writeJsonCoin(coinsReadJson);
    await loadCoin(true);
  }

  void currentCoinActivate(CoinToActivate coinToAtivate) {
    this.currentActiveCoin = coinToAtivate;
    _inCurrentActiveCoin.add(this.currentActiveCoin);
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
      return new List<Coin>();
    }
  }

  Future<List<Coin>> getAllNotActiveCoins() async {
    var allCoins =
        await mm2.loadJsonCoins(await mm2.loadElectrumServersAsset());
    var allCoinsActivate = await coinsBloc.readJsonCoin();
    List<Coin> coinsNotActivated = new List<Coin>();

    allCoins.forEach((coin) {
      bool isAlreadyAdded = false;
      allCoinsActivate.forEach((coinActivate) {
        if (coin.abbr == coinActivate.abbr) isAlreadyAdded = true;
      });
      if (!isAlreadyAdded) coinsNotActivated.add(coin);
    });
    return coinsNotActivated;
  }

  void addActivateCoin(Coin coin) {
    this.coinToActivate.add(coin);
    _inCoinToActivate.add(this.coinToActivate);
  }

  void removeActivateCoin(Coin coin) {
    this.coinToActivate.remove(coin);
    _inCoinToActivate.add(this.coinToActivate);
  }

  void resetActivateCoin() {
    this.coinToActivate.clear();
    _inCoinToActivate.add(this.coinToActivate);
  }

  void startCheckBalance() {
    timer = Timer.periodic(Duration(seconds: 45), (_) {
      if (!mm2.ismm2Running) {
        _.cancel();
      } else {
        loadCoin(true);
      }
    });
  }

  void stopCheckBalance() {
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();
  }

  Future<void> loadCoin(bool forceUpdate) async {
    List<Coin> coins = await coinsBloc.readJsonCoin();
    List<CoinBalance> listCoinElectrum = new List<CoinBalance>();
    List<dynamic> balances = await mm2.getAllBalances(forceUpdate);

    for (var coin in coins) {
      for (var balance in balances) {
        if (balance is Balance && coin.abbr == balance.coin) {
          var coinBalance = CoinBalance(coin, balance);
          if (forceUpdate || coinBalance.balanceUSD == null) {
            coinBalance.priceForOne =
                await getPriceObj.getPrice(coin.abbr, "USD");
            coinBalance.balanceUSD = coinBalance.priceForOne *
                double.parse(coinBalance.balance.balance);
          }
          listCoinElectrum.add(coinBalance);
        } else if (balance is ErrorString) {
          print(balance.error);
        }

        if (balance is Balance && balance.coin == "KMD") {
          mm2.pubkey = balance.address;
        }
      }
    }

    listCoinElectrum.sort((b, a) {
      if (a.balanceUSD != null) {
        return a.balanceUSD.compareTo(b.balanceUSD);
      }
    });
    if (listCoinElectrum.isNotEmpty) {
      updateCoins(listCoinElectrum);
    }
  }

  Future<void> activateCoinKickStart() async {
    List<Coin> coinsToSave = await readJsonCoin();
    List<Coin> coinsAll = await getAllNotActiveCoins();

    await mm2.getCoinToKickStart().then((coinsToKickStart) {
      coinsAll.forEach((coin) {
        coinsToKickStart.result.forEach((coinToKickStart) {
          if (coin.abbr == coinToKickStart.toString()) {
            coinsToSave.add(coin);
          }
        });
      });
    });

    await writeJsonCoin(coinsToSave);
  }
}

final coinsBloc = CoinsBloc();

class CoinToActivate {
  Coin coin;
  bool isActivate;

  CoinToActivate({this.coin, this.isActivate});
}
