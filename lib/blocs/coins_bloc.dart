import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/services/getprice_service.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:path_provider/path_provider.dart';

class CoinsBloc implements BlocBase {
  List<CoinBalance> coinBalance = <CoinBalance>[];

  // Streams to handle the list coin
  final StreamController<List<CoinBalance>> _coinsController =
      StreamController<List<CoinBalance>>.broadcast();

  Sink<List<CoinBalance>> get _inCoins => _coinsController.sink;
  Stream<List<CoinBalance>> get outCoins => _coinsController.stream;

  dynamic transactions;

  // Streams to handle the list coin
  final StreamController<dynamic> _transactionsController =
      StreamController<dynamic>.broadcast();

  Sink<dynamic> get _inTransactions => _transactionsController.sink;
  Stream<dynamic> get outTransactions => _transactionsController.stream;

  List<Coin> coinToActivate = <Coin>[];

  // Streams to handle the list coin to activate
  final StreamController<List<Coin>> _coinToActivateController =
      StreamController<List<Coin>>.broadcast();

  Sink<List<Coin>> get _inCoinToActivate => _coinToActivateController.sink;
  Stream<List<Coin>> get outCoinToActivate => _coinToActivateController.stream;

  CoinToActivate currentActiveCoin = CoinToActivate();

  // Streams to handle the list coin
  final StreamController<CoinToActivate> _currentActiveCoinController =
      StreamController<CoinToActivate>.broadcast();

  Sink<CoinToActivate> get _inCurrentActiveCoin =>
      _currentActiveCoinController.sink;
  Stream<CoinToActivate> get outcurrentActiveCoin =>
      _currentActiveCoinController.stream;

  bool closeViewSelectCoin = false;

  // Streams to handle the list coin
  final StreamController<bool> _closeViewSelectCoinController =
      StreamController<bool>.broadcast();

  Sink<bool> get _inCloseViewSelectCoin => _closeViewSelectCoinController.sink;
  Stream<bool> get outCloseViewSelectCoin =>
      _closeViewSelectCoinController.stream;

  Timer timer;
  Timer timer2;
  bool onActivateCoins = false;

  @override
  void dispose() {
    _coinsController.close();
    _transactionsController.close();
    _coinToActivateController.close();
    _currentActiveCoinController.close();
    _closeViewSelectCoinController.close();
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
    transactions = Transactions();
    _inTransactions.add(transactions);
  }

  void updateCoins(List<CoinBalance> coins) {
    coinBalance = coins;
    _inCoins.add(coinBalance);
  }

  void updateOneCoin(CoinBalance coin) {
    bool isExist = false;
    int currentIndex = 0;

    coinBalance.asMap().forEach((int index, CoinBalance coinBalance) {
      if (coinBalance.coin.abbr == coin.coin.abbr) {
        isExist = true;
        currentIndex = index;
      }
    });
    if (!isExist) {
      coinBalance.add(coin);
    } else {
        coinBalance.removeAt(currentIndex);
        coinBalance.add(coin);
    }
    coinBalance.sort((CoinBalance b, CoinBalance a) {
      if (a.balanceUSD != null && b.balanceUSD != null) {
        return a.balanceUSD.compareTo(b.balanceUSD);
      } else {
        return 0;
      }
    });
    _inCoins.add(coinBalance);
  }

  Future<void> updateTransactions(Coin coin, int limit, String fromId) async {
    try {
      final dynamic transactions =
          await mm2.getTransactions(coin, limit, fromId);
      if (transactions is Transactions) {
        if (fromId == null || fromId.isEmpty) {
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
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addMultiCoins(List<Coin> coins) async {
    onActivateCoins = true;
    final List<Coin> coinsReadJson = await readJsonCoin();
    final List<Future<dynamic>> listFutureActiveCoin = <Future<dynamic>>[];

    for (Coin coin in coins) {
      listFutureActiveCoin.add(_activeCoinFuture(coin));
    }

    await Future.wait<dynamic>(listFutureActiveCoin)
        .then((List<dynamic> onValue) {
          for (dynamic coinActivate in onValue) {
            if (coinActivate is Coin && coinActivate != null) {
              coinsReadJson.add(coinActivate);
            }
          }
        })
        .catchError((dynamic onError) {
          print(onError);
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
    await mm2.activeCoin(coin).then((ActiveCoin activeCoin) {
      coinToactivate = coin;
      currentCoinActivate(
          CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
    }).catchError((dynamic onError) {
      if (onError is ErrorString &&
          onError.error.contains('Coin ${coin.abbr} already initialized')) {
        coinToactivate = coin;
        currentCoinActivate(
            CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
      } else {
        print('Sorry, ${coin.abbr} not available.');
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Sorry, ${coin.abbr} not available.'));
      }
    }).timeout(const Duration(seconds: 30));

    return coinToactivate;
  }

  void currentCoinActivate(CoinToActivate coinToActivate) {
    currentActiveCoin = coinToActivate;
    _inCurrentActiveCoin.add(currentActiveCoin);
  }

  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final String path = await _localPath;
    return File('$path/coins_activate_default.json');
  }

  Future<File> writeJsonCoin(List<Coin> newCoins) async {
    final File file = await _localFile;

    final List<Coin> currentCoins = await readJsonCoin();

    for (Coin newCoin in newCoins) {
      if (currentCoins
          .every((Coin currentCoin) => currentCoin.abbr != newCoin.abbr)) {
        currentCoins.add(newCoin);
      }
    }
    return file.writeAsString(json.encode(currentCoins));
  }

  Future<void> deleteJsonCoin(Coin coin) async {
    final List<Coin> currentCoins = await readJsonCoin();
    currentCoins
        .removeWhere((Coin currentCoin) => currentCoin.abbr == coin.abbr);
    final File file = await _localFile;
    await file.writeAsString(json.encode(currentCoins));
  }

  Future<File> resetCoinDefault() async {
    final File file = await _localFile;
    return file.writeAsString(json.encode(await mm2.loadJsonCoinsDefault()));
  }

  Future<List<Coin>> readJsonCoin() async {
    try {
      final File file = await _localFile;
      final String contents = await file.readAsString();
      return coinFromJson(contents);
    } catch (e) {
      return <Coin>[];
    }
  }

  Future<List<Coin>> getAllNotActiveCoins() async {
    final List<Coin> allCoins =
        await mm2.loadJsonCoins(await mm2.loadElectrumServersAsset());
    final List<Coin> allCoinsActivate = await coinsBloc.readJsonCoin();
    final List<Coin> coinsNotActivated = <Coin>[];

    for (Coin coin in allCoins) {
      bool isAlreadyAdded = false;
      for (Coin coinActivate in allCoinsActivate) {
        if (coin.abbr == coinActivate.abbr) {
          isAlreadyAdded = true;
        }
      }
      if (!isAlreadyAdded) {
        coinsNotActivated.add(coin);
      }
    }

    return coinsNotActivated;
  }

  void addActivateCoin(Coin coin) {
    coinToActivate.add(coin);
    _inCoinToActivate.add(coinToActivate);
  }

  void removeActivateCoin(Coin coin) {
    coinToActivate.remove(coin);
    _inCoinToActivate.add(coinToActivate);
  }

  void resetActivateCoin() {
    coinToActivate.clear();
    _inCoinToActivate.add(coinToActivate);
  }

  void startCheckBalance() {
    timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mm2.ismm2Running) {
        _.cancel();
      } else {
        loadCoin();
      }
    });
    timer2 = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mm2.ismm2Running) {
        _.cancel();
      } else {
        if (!onActivateCoins) {
          swapHistoryBloc.updateSwaps(50, null);
        }
      }
    });
  }

  void stopCheckBalance() {
    if (timer != null) {
      timer.cancel();
    }
    if (timer2 != null) {
      timer2.cancel();
    }
  }

  Future<void> loadCoin() async {
    if (mm2.ismm2Running && !onActivateCoins) {
      final List<Coin> coins = await coinsBloc.readJsonCoin();
      final List<Future<dynamic>> getAllBalances = <Future<dynamic>>[];

      for (Coin coin in coins) {
        getAllBalances.add(_getBalanceForCoin(coin));
      }

      try {
        await Future.wait<dynamic>(getAllBalances)
            .then((List<dynamic> onValue) {
          for (dynamic balance in onValue) {
            if (balance is CoinBalance &&
                balance.balance.address.isNotEmpty) {
              updateOneCoin(balance);
            }
          }
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> activateCoinsSelected(List<Coin> coinToActivate) async {
    coinsBloc.addMultiCoins(coinToActivate).then((_) {
      coinsBloc.setCloseViewSelectCoin(true);
    });
  }

  Future<CoinBalance> _getBalanceForCoin(Coin coin) async {
    dynamic balance;
    try {
      balance = await mm2.getBalance(coin).timeout(const Duration(seconds: 15));
    } catch (e) {
      print(e);
      balance = null;
    }

    if (balance is ErrorString) {
      print(balance.error);
    }
    final double price = await getPriceObj
        .getPrice(coin.abbr, 'USD')
        .timeout(const Duration(seconds: 15), onTimeout: () => 0);

    dynamic coinBalance;
    if (balance is Balance && coin.abbr == balance.coin) {
      coinBalance = CoinBalance(coin, balance);
      if (coinBalance.balanceUSD == null &&
          double.parse(coinBalance.balance.getBalance()) > 0) {
        coinBalance.priceForOne = price;
      } else {
        coinBalance.priceForOne = 0.0;
      }
      coinBalance.balanceUSD = coinBalance.priceForOne *
          double.parse(coinBalance.balance.getBalance());
    } else if (balance is ErrorString) {
      coinBalance = CoinBalance(
          coin, Balance(address: '', balance: '0', coin: coin.abbr));
      coinBalance.priceForOne = price;
      coinBalance.balanceUSD = 0.0;
    }

    if (balance is Balance && balance.coin == 'KMD') {
      mm2.pubkey = balance.address;
    }
    return coinBalance;
  }

  Future<void> activateCoinKickStart() async {
    final List<Coin> coinsToSave = await readJsonCoin();
    final List<Coin> coinsAll = await getAllNotActiveCoins();

    try {
      await mm2.getCoinToKickStart().then((CoinToKickStart coinsToKickStart) {
        for (Coin coin in coinsAll) {
          for (String coinToKickStart in coinsToKickStart.result) {
            if (coin.abbr == coinToKickStart.toString()) {
              coinsToSave.add(coin);
            }
          }
        }
      });
      await writeJsonCoin(coinsToSave);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

CoinsBloc coinsBloc = CoinsBloc();

class CoinToActivate {
  CoinToActivate({this.coin, this.isActive, this.currentStatus});

  Coin coin;
  String currentStatus;
  bool isActive;
}
