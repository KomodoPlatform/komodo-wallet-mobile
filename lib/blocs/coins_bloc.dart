import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/services/api_providers.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/getprice_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

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

  void removeCoins(List<Coin> coins) {
    coins.forEach(removeCoin);
    _inCoins.add(coinBalance);
  }

  Future<void> removeCoinBalance(Coin coin) async {
    coinBalance.removeWhere((CoinBalance item) => coin.abbr == item.coin.abbr);
  }

  Future<void> removeCoinLocal(Coin coin, dynamic disableCoinRes) async {
    if (disableCoinRes is DisableCoin) {
      coinBalance
          .removeWhere((CoinBalance item) => coin.abbr == item.coin.abbr);
      updateCoins(coinBalance);
      await removeJsonCoin(<Coin>[coin]);
    }
  }

  Future<void> removeCoin(Coin coin) async =>
      await removeCoinBalance(coin).then<dynamic>((_) => ApiProvider()
          .disableCoin(MMService().client, GetDisableCoin(coin: coin.abbr))
          .then<dynamic>((dynamic res) => removeCoinLocal(coin, res)));

  void updateOneCoin(CoinBalance coin) {
    bool exists = false;
    int currentIndex = 0;

    coinBalance.asMap().forEach((int index, CoinBalance coinBalance) {
      if (coinBalance.coin.abbr == coin.coin.abbr) {
        exists = true;
        currentIndex = index;
      }
    });
    if (!exists) {
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
      final dynamic transactions = await ApiProvider().getTransactions(
          MMService().client,
          GetTxHistory(coin: coin.abbr, limit: limit, fromId: fromId));

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
      Log.println('coins_bloc:242', e);
      rethrow;
    }
  }

  Future<void> removeOneCoinFromLocal(Coin coinToRemove) async =>
      await DBProvider.db.deleteCoinActivate(CoinEletrum.SAVED, coinToRemove);

  Future<void> updateMultiCoinsFromLocal(List<Coin> coinsToUpdate) async {
    final List<Future<dynamic>> updateAllCoinFuture = <Future<dynamic>>[];
    for (Coin coin in coinsToUpdate) {
      updateAllCoinFuture
          .add(DBProvider.db.updateCoinActivate(CoinEletrum.SAVED, coin));
    }
    await Future.wait<dynamic>(updateAllCoinFuture);
  }

  Future<void> addMultiCoins(List<Coin> coins) async {
    onActivateCoins = true;
    final List<Coin> coinsReadJson = <Coin>[];
    final List<Future<CoinToActivate>> listFutureActiveCoin =
        <Future<CoinToActivate>>[];

    for (Coin coin in coins) {
      listFutureActiveCoin.add(_activeCoinFuture(coin));
    }

    await Future.wait<CoinToActivate>(listFutureActiveCoin)
        .then((List<CoinToActivate> onValue) async {
          for (CoinToActivate coinActivate in onValue) {
            if (coinActivate.isActive) {
              coinsReadJson.add(coinActivate.coin);
            } else {
              await removeOneCoinFromLocal(coinActivate.coin);
            }
          }
        })
        .catchError((dynamic onError) {
          Log.println('coins_bloc:280', onError);
          Log.println('coins_bloc:281', 'timeout2--------------');
        })
        .then((_) async => await updateMultiCoinsFromLocal(coinsReadJson))
        .then((_) => onActivateCoins = false)
        .then((_) async {
          onActivateCoins = false;
          currentCoinActivate(CoinToActivate(currentStatus: 'Loading coins'));
          await loadCoin();
          currentCoinActivate(null);
        });
  }

  Future<CoinToActivate> _activeCoinFuture(Coin coin) async {
    currentCoinActivate(
        CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
    Log.println('coins_bloc:296', coin.abbr);
    return await ApiProvider()
        .activeCoin(MMService().client, coin)
        .then((dynamic activeCoin) {
      if (activeCoin is ActiveCoin) {
        currentCoinActivate(
            CoinToActivate(currentStatus: '${coin.name} activated.'));
        return CoinToActivate(coin: coin, isActive: true);
      } else if (activeCoin is ErrorString &&
          activeCoin.error.contains('already initialized')) {
        Log.println('coins_bloc:306', 'ERROR: ' + activeCoin.error.toString());
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Coin ${coin.abbr} already initialized'));
        return CoinToActivate(coin: coin, isActive: true);
      } else {
        if (activeCoin is ErrorString) {
          Log.println(
              'coins_bloc:312', 'ERROR: ' + activeCoin.error.toString());
        }
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Sorry, ${coin.abbr} not available.'));
        return CoinToActivate(coin: coin, isActive: false);
      }
    }).timeout(const Duration(seconds: 30), onTimeout: () async {
      Log.println('coins_bloc:320', 'Sorry, ${coin.abbr} not available.');
      currentCoinActivate(
          CoinToActivate(currentStatus: 'Sorry, ${coin.abbr} not available.'));
      await Future<dynamic>.delayed(const Duration(seconds: 2))
          .then((dynamic _) {
        currentCoinActivate(null);
      });
      return CoinToActivate(coin: coin, isActive: false);
    });
  }

  void currentCoinActivate(CoinToActivate coinToActivate) {
    currentActiveCoin = coinToActivate;
    _inCurrentActiveCoin.add(currentActiveCoin);
  }

  Future<void> writeJsonCoin(List<Coin> newCoins) async {
    final List<Future<dynamic>> savedCoinFutures = <Future<dynamic>>[];
    for (Coin coin in newCoins) {
      savedCoinFutures
          .add(DBProvider.db.saveCoinActivate(CoinEletrum.SAVED, coin));
    }
    await Future.wait<dynamic>(savedCoinFutures);
  }

  Future<void> removeJsonCoin(List<Coin> coinsToRemove) async {
    final List<Future<dynamic>> removeCoinFutures = <Future<dynamic>>[];
    for (Coin coin in coinsToRemove) {
      removeCoinFutures
          .add(DBProvider.db.deleteCoinActivate(CoinEletrum.SAVED, coin));
    }
    await Future.wait<dynamic>(removeCoinFutures);
  }

  Future<void> resetCoinDefault() async =>
      await DBProvider.db.initCoinsActivateDefault(CoinEletrum.SAVED);

  Future<List<Coin>> readJsonCoin() async =>
      await DBProvider.db.getAllCoinElectrum(CoinEletrum.SAVED);

  Future<List<Coin>> getAllNotActiveCoins() async {
    final List<Coin> allCoins =
        await DBProvider.db.getAllCoinElectrum(CoinEletrum.CONFIG);
    final List<Coin> allCoinsActivate =
        await DBProvider.db.getAllCoinElectrum(CoinEletrum.SAVED);
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
      if (!MMService().ismm2Running) {
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
    if (MMService().ismm2Running &&
        !onActivateCoins &&
        !mainBloc.isNetworkOffline) {
      onActivateCoins = true;
      final List<Coin> coins = await coinsBloc.readJsonCoin();
      final List<Future<dynamic>> getAllBalances = <Future<dynamic>>[];

      if (coins.isEmpty) {
        resetCoinBalance();
      } else {
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
          Log.println('coins_bloc:437', e);
        }
      }

      onActivateCoins = false;
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
    Balance balance;
    try {
      balance = await ApiProvider()
          .getBalance(GetBalance(coin: coin.abbr))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      Log.println('coins_bloc:464', e);
      balance = null;
    }

    final double price = await getPriceObj
        .getPrice(coin.abbr, coin.coingeckoId, 'USD')
        .timeout(const Duration(seconds: 5), onTimeout: () => 0.0);

    dynamic coinBalance;
    if (balance != null && coin.abbr == balance.coin) {
      coinBalance = CoinBalance(coin, balance);
      // Log.println(
      //     'coins_bloc:480', 'Balance: ' + coinBalance.balance.getBalance());
      // Log.println('coins_bloc:477',
      //     'RealBalance: ' + coinBalance.balance.getRealBalance());
      if (coinBalance.balanceUSD == null &&
          double.parse(coinBalance.balance.getBalance()) > 0) {
        coinBalance.priceForOne = price.toString();
      } else {
        coinBalance.priceForOne = '0';
      }
      coinBalance.balanceUSD = (Decimal.parse(coinBalance.priceForOne) *
              Decimal.parse(coinBalance.balance.getBalance()))
          .toDouble();
    } else {
      coinBalance = CoinBalance(
          coin, Balance(address: '', balance: '0', coin: coin.abbr));
      coinBalance.priceForOne = price.toString();
      coinBalance.balanceUSD = 0.0;
    }

    if (balance != null && balance.coin == 'KMD') {
      MMService().pubkey = balance.address;
    }
    return coinBalance;
  }

  Future<void> activateCoinKickStart() async {
    final List<Coin> coinsToSave = await readJsonCoin();
    final List<Coin> coinsAll = await getAllNotActiveCoins();

    try {
      await ApiProvider()
          .getCoinToKickStart(MMService().client,
              BaseService(method: 'coins_needed_for_kick_start'))
          .then((dynamic coinsToKickStart) {
        if (coinsToKickStart is CoinToKickStart) {
          for (Coin coin in coinsAll) {
            for (String coinToKickStart in coinsToKickStart.result) {
              if (coin.abbr == coinToKickStart.toString()) {
                coinsToSave.add(coin);
              }
            }
          }
        }
      });
      await writeJsonCoin(coinsToSave);
    } catch (e) {
      Log.println('coins_bloc:522', e);
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
