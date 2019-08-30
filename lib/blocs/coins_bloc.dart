import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
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

  bool isAllSmartChainActive = false;

  final StreamController<bool> _isAllSmartChainActiveController =
      StreamController<bool>.broadcast();

  Sink<bool> get _inIsAllSmartChainActive =>
      _isAllSmartChainActiveController.sink;
  Stream<bool> get outIsAllSmartChainActive =>
      _isAllSmartChainActiveController.stream;

  bool isERCActive = false;

  final StreamController<bool> _isERCActiveController =
      StreamController<bool>.broadcast();

  Sink<bool> get _inIsERCActive => _isERCActiveController.sink;
  Stream<bool> get outIsERCActive => _isERCActiveController.stream;

  bool isutxoActive = false;

  final StreamController<bool> _isutxoActiveController =
      StreamController<bool>.broadcast();

  Sink<bool> get _inIsutxoActive => _isutxoActiveController.sink;
  Stream<bool> get outIsutxoActive => _isutxoActiveController.stream;

  List<CoinToActivate> coinBeforeActivation = <CoinToActivate>[];

  // Streams to handle the list coin to activate
  final StreamController<List<CoinToActivate>> _coinBeforeActivationController =
      StreamController<List<CoinToActivate>>.broadcast();

  Sink<List<CoinToActivate>> get _inCoinBeforeActivation =>
      _coinBeforeActivationController.sink;
  Stream<List<CoinToActivate>> get outCoinBeforeActivation =>
      _coinBeforeActivationController.stream;

  Timer timer;
  bool onActivateCoins = false;

  @override
  void dispose() {
    _coinsController.close();
    _transactionsController.close();
    _currentActiveCoinController.close();
    _closeViewSelectCoinController.close();
    _isAllSmartChainActiveController.close();
    _coinBeforeActivationController.close();
    _isutxoActiveController.close();
  }

  Future<void> initCoinBeforeActivation() async {
    final List<CoinToActivate> coinBeforeActivation = <CoinToActivate>[];

    for (Coin coin in await getAllNotActiveCoins()) {
      coinBeforeActivation.add(CoinToActivate(coin: coin, isActive: false));
    }
    this.coinBeforeActivation = coinBeforeActivation;
    _inCoinBeforeActivation.add(this.coinBeforeActivation);
  }

  void setCoinBeforeActivation(Coin coin, bool isActive) {
    coinBeforeActivation
        .removeWhere((CoinToActivate item) => item.coin.abbr == coin.abbr);
    coinBeforeActivation.add(CoinToActivate(coin: coin, isActive: isActive));
    // coinBeforeActivation.sort((CoinToActivate a, CoinToActivate b) =>
    //     a.coin.swapContractAddress.compareTo(b.coin.swapContractAddress));

    _inCoinBeforeActivation.add(coinBeforeActivation);
  }

  void setIsutxoActive(bool isutxoActive) {
    this.isutxoActive = isutxoActive;
    _inIsutxoActive.add(this.isutxoActive);
  }
  
  void setIsERCActive(bool isERCActive) {
    this.isERCActive = isERCActive;
    _inIsERCActive.add(this.isERCActive);
  }

  void setIsAllSmartChainActive(bool isAllSmartChainActive) {
    this.isAllSmartChainActive = isAllSmartChainActive;
    _inIsAllSmartChainActive.add(this.isAllSmartChainActive);
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
          await MarketMakerService().getTransactions(coin, limit, fromId);
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
              print('coinActivate--------------' + coinActivate.abbr);
              coinsReadJson.add(coinActivate);
            }
          }
        })
        .catchError((dynamic onError) {
          print(onError);
          print('timeout2--------------');
        })
        .then((_) async {
          await writeJsonCoin(coinsReadJson);
        })
        .then((_) => onActivateCoins = false)
        .then((_) async {
          onActivateCoins = false;
          currentCoinActivate(null);
          await loadCoin();
        });
  }

  Future<Coin> _activeCoinFuture(Coin coin) async {
    Coin coinToactivate;

    currentCoinActivate(
        CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
    await MarketMakerService().activeCoin(coin).then((ActiveCoin activeCoin) {
      coinToactivate = coin;
      currentCoinActivate(
          CoinToActivate(currentStatus: '${coin.name} activated.'));
    }).catchError((dynamic onError) async {
      coinToactivate = null;

      if (onError is ErrorString &&
          onError.error.contains('Coin ${coin.abbr} already initialized')) {
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Coin ${coin.abbr} already initialized'));
      } else {
        print('Sorry, ${coin.abbr} not available.');
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Sorry, ${coin.abbr} not available.'));
      }
      await Future<dynamic>.delayed(const Duration(seconds: 2))
          .then((dynamic _) {
        currentCoinActivate(null);
      });
    }).timeout(const Duration(seconds: 10), onTimeout: () async {
      coinToactivate = null;
      print('Sorry, ${coin.abbr} not available.');
      currentCoinActivate(
          CoinToActivate(currentStatus: 'Sorry, ${coin.abbr} not available.'));
      await Future<dynamic>.delayed(const Duration(seconds: 2))
          .then((dynamic _) {
        currentCoinActivate(null);
      });
    });

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
    return file.writeAsString(
        json.encode(await MarketMakerService().loadJsonCoinsDefault()));
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
    final List<Coin> allCoins = await MarketMakerService()
        .loadJsonCoins(await MarketMakerService().loadElectrumServersAsset());
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

    coinsNotActivated.sort((Coin a, Coin b) =>
        a.swapContractAddress.compareTo(b.swapContractAddress));
    return coinsNotActivated;
  }

  Future<List<Coin>> getAllNotActiveCoinsWithFilter(String query) async {
    List<Coin> coinsActivate = await getAllNotActiveCoins();
    coinsActivate = coinsActivate
        .where((Coin item) =>
            item.abbr.toLowerCase().contains(query.toLowerCase()) ||
            item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return coinsActivate;
  }

  void startCheckBalance() {
    timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!MarketMakerService().ismm2Running) {
        _.cancel();
      } else {
        loadCoin();
      }
    });
  }

  void stopCheckBalance() {
    if (timer != null) {
      timer.cancel();
    }
  }

  Future<void> loadCoin() async {
    if (MarketMakerService().ismm2Running && !onActivateCoins) {
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
                balance.balance.address != null &&
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

  Future<void> activateCoinsSelected() async {
    final List<Coin> coins = <Coin>[];
    for (CoinToActivate coinToActivate in coinBeforeActivation) {
      if (coinToActivate.isActive) {
        coins.add(coinToActivate.coin);
      }
    }
    coinsBloc.addMultiCoins(coins).then((_) {
      coinsBloc.setCloseViewSelectCoin(true);
    });
  }

  Future<CoinBalance> _getBalanceForCoin(Coin coin) async {
    dynamic balance;
    try {
      balance = await MarketMakerService()
          .getBalance(coin)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print(e);
      balance = null;
    }

    if (balance is ErrorString) {
      print(balance.error);
    }
    final double price = await getPriceObj
        .getPrice(coin.abbr, coin.coingeckoId, 'USD')
        .timeout(const Duration(seconds: 15), onTimeout: () => 0.0);

    dynamic coinBalance;
    if (balance is Balance && coin.abbr == balance.coin) {
      coinBalance = CoinBalance(coin, balance);
      if (coinBalance.balanceUSD == null &&
          double.parse(coinBalance.balance.getBalance()) > 0) {
        coinBalance.priceForOne = price.toString();
      } else {
        coinBalance.priceForOne = '0';
      }
      coinBalance.balanceUSD = (Decimal.parse(coinBalance.priceForOne) *
              Decimal.parse(coinBalance.balance.getBalance()))
          .toDouble();
    } else if (balance is ErrorString) {
      coinBalance = CoinBalance(
          coin, Balance(address: '', balance: '0', coin: coin.abbr));
      coinBalance.priceForOne = price.toString();
      coinBalance.balanceUSD = 0.0;
    }

    if (balance is Balance && balance.coin == 'KMD') {
      MarketMakerService().pubkey = balance.address;
    }
    return coinBalance;
  }

  Future<void> activateCoinKickStart() async {
    final List<Coin> coinsToSave = await readJsonCoin();
    final List<Coin> coinsAll = await getAllNotActiveCoins();

    try {
      await MarketMakerService()
          .getCoinToKickStart()
          .then((CoinToKickStart coinsToKickStart) {
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
