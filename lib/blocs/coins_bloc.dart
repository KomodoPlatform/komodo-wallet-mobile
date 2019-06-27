import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/coin_init.dart';
import 'package:komodo_dex/model/error_code.dart';
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

  dynamic transactions;

  // Streams to handle the list coin
  StreamController<dynamic> _transactionsController =
      StreamController<dynamic>.broadcast();

  Sink<dynamic> get _inTransactions => _transactionsController.sink;
  Stream<dynamic> get outTransactions => _transactionsController.stream;

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

  bool closeViewSelectCoin = false;

  // Streams to handle the list coin
  StreamController<bool> _closeViewSelectCoinController =
      StreamController<bool>.broadcast();

  Sink<bool> get _inCloseViewSelectCoin => _closeViewSelectCoinController.sink;
  Stream<bool> get outCloseViewSelectCoin =>
      _closeViewSelectCoinController.stream;

  var timer;
  var timer2;
  bool onActivateCoins = false;

  @override
  void dispose() {
    _coinsController.close();
    _transactionsController.close();
    _coinToActivateController.close();
    _currentActiveCoinController.close();
    _failCoinActivateController.close();
  }

  void setCloseViewSelectCoin(bool closeViewSelectCoin) {
    this.closeViewSelectCoin = closeViewSelectCoin;
    _inCloseViewSelectCoin.add(this.closeViewSelectCoin);
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

  void updateOneCoin(CoinBalance coin) {
    bool isExist = false;
    int currentIndex = 0;

    this.coinBalance.asMap().forEach((index, coinBalance) {
      if (coinBalance.coin.abbr == coin.coin.abbr) {
        isExist = true;
        currentIndex = index;
      }
    });
    if (!isExist) {
      this.coinBalance.add(coin);
    } else {
      if (double.parse(coin.balance.getBalance()) > 0) {
        this.coinBalance.removeAt(currentIndex);
        this.coinBalance.add(coin);
      }
    }
    this.coinBalance.sort((b, a) {
      if (a.balanceUSD != null) {
        return a.balanceUSD.compareTo(b.balanceUSD);
      }
    });
    _inCoins.add(this.coinBalance);
  }

  Future<void> updateTransactions(Coin coin, int limit, String fromId) async {
    dynamic transactions = await mm2.getTransactions(coin, limit, fromId);

    if (transactions is Transactions) {
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
    } else if (transactions is ErrorCode) {
      _inTransactions.add(transactions);
      return transactions;
    }
  }

  Future<void> addMultiCoins(List<Coin> coins) async {
    onActivateCoins = true;
    List<Coin> coinsReadJson = await readJsonCoin();
    List<Future> listFutureActiveCoin = new List<Future>();

    coins.forEach((coin) => listFutureActiveCoin.add(_activeCoinFuture(coin)));

    await Future.wait(listFutureActiveCoin)
        .then((onValue) {
          onValue.forEach((coinActivate) {
            if (coinActivate is Coin && coinActivate != null) {
              coinsReadJson.add(coinActivate);
            }
          });
        })
        .then((_) async => await writeJsonCoin(coinsReadJson))
        .then((_) => onActivateCoins = false)
        .then((_) async {
          onActivateCoins = false;
          currentCoinActivate(null);
          await loadCoin();
        });
  }

  Future<Coin> _activeCoinFuture(Coin coin) async {
    Coin coinToactivate;
    await mm2.activeCoin(coin).catchError((onError) {
      print(onError.error);
      if (onError is ErrorString &&
          onError.error.contains("Coin ${coin.abbr} already initialized")) {
        coinToactivate = coin;
        currentCoinActivate(
            CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
      } else {
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Sorry, ${coin.abbr} not available.'));
      }
    }).then((activeCoin) {
      coinToactivate = coin;
      currentCoinActivate(
          CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
    }).timeout(Duration(seconds: 30));

    return coinToactivate;
  }

  void currentCoinActivate(CoinToActivate coinToActivate) {
    this.currentActiveCoin = coinToActivate;
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

  Future<File> writeJsonCoin(List<Coin> newCoins) async {
    final file = await _localFile;

    List<Coin> currentCoins = await readJsonCoin();

    newCoins.forEach((newCoin) {
      if (currentCoins
          .every((currentCoin) => currentCoin.abbr != newCoin.abbr)) {
        currentCoins.add(newCoin);
      }
    });
    return file.writeAsString(json.encode(currentCoins));
  }

  Future<void> deleteJsonCoin(Coin coin) async {
    List<Coin> currentCoins = await readJsonCoin();
    currentCoins.removeWhere((currentCoin) => currentCoin.abbr == coin.abbr);
    final file = await _localFile;
    await file.writeAsString(json.encode(currentCoins));
  }

  Future<File> resetCoinDefault() async {
    final file = await _localFile;
    return file.writeAsString(json.encode(await mm2.loadJsonCoinsDefault()));
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
        loadCoin();
      }
    });
  }

  void stopCheckBalance() {
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();
  }

  Future<void> loadCoin() async {
    if (mm2.ismm2Running && !onActivateCoins) {
      List<Coin> coins = await coinsBloc.readJsonCoin();
      List<Future> getAllBalances = new List<Future>();

      coins.forEach((coin) {
        getAllBalances.add(_getBalanceForCoin(coin));
      });
      await Future.wait(getAllBalances).then((onValue) {
        onValue.forEach((balance) {
          if (balance is CoinBalance) {
            updateOneCoin(balance);
          }
        });
      });
    }
  }

  Future<void> activateCoinsSelected(List<Coin> coinToActivate) async {
    coinsBloc.addMultiCoins(coinToActivate).then((_) {
      coinsBloc.setCloseViewSelectCoin(true);
    });
  }

  Future<CoinBalance> _getBalanceForCoin(Coin coin) async {
    dynamic balance = await mm2.getBalance(coin).timeout(Duration(seconds: 15));
    if (balance is ErrorString) {
      print(balance.error);
    }
    double price = await getPriceObj
        .getPrice(coin.abbr, "USD")
        .timeout(Duration(seconds: 15), onTimeout: () => 0);

    var coinBalance;
    if (balance is Balance && coin.abbr == balance.coin) {
      coinBalance = CoinBalance(coin, balance);
      if (coinBalance.balanceUSD == null &&
          double.parse(coinBalance.balance.getBalance()) > 0) {
        coinBalance.priceForOne = price;
      } else {
        coinBalance.priceForOne = 0.0;
      }
      coinBalance.balanceUSD =
          coinBalance.priceForOne * double.parse(coinBalance.balance.getBalance());
    } else if (balance is ErrorString) {
      coinBalance = CoinBalance(
          coin, new Balance(address: "", balance: "1.0", coin: coin.abbr));
      coinBalance.priceForOne = price;
      coinBalance.balanceUSD =
          coinBalance.priceForOne * double.parse(coinBalance.balance.getBalance());
      print("-------------------" + balance.error);
    }

    if (balance is Balance && balance.coin == "KMD") {
      mm2.pubkey = balance.address;
    }
    return coinBalance;
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
  String currentStatus;
  bool isActive;

  CoinToActivate({this.coin, this.isActive, this.currentStatus});
}
