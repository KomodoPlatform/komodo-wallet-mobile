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
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/getprice_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:komodo_dex/services/job_service.dart';

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

  bool _coinsLock = false;

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
      await deactivateCoins(<Coin>[coin]);
    }
  }

  Future<void> removeCoin(Coin coin) async {
    await removeCoinBalance(coin);
    final res = await MM.disableCoin(GetDisableCoin(coin: coin.abbr));
    removeCoinLocal(coin, res);
  }

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
      final dynamic transactions = await MM.getTransactions(mmSe.client,
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
      Log('coins_bloc:241', e);
      rethrow;
    }
  }

  Future<void> removeOneCoinFromLocal(Coin coinToRemove) async {
    await Db.coinInactive(coinToRemove);
  }

  /// Handle the coins user has picked for activation.
  /// Also used for coin activations during the application startup.
  Future<void> enableCoins(List<Coin> coins) async {
    while (_coinsLock) await sleepMs(77);
    _coinsLock = true;
    final List<Coin> coinsReadJson = <Coin>[];
    final List<Future<CoinToActivate>> listFutureActiveCoin =
        <Future<CoinToActivate>>[];

    for (Coin coin in coins) {
      listFutureActiveCoin.add(enableCoin(coin));
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
          Log('coins_bloc:274', onError);
          Log('coins_bloc:275', 'timeout2--------------');
        })
        .then((_) => _coinsLock = false)
        .then((_) async {
          _coinsLock = false;
          currentCoinActivate(CoinToActivate(currentStatus: 'Loading coins'));
          await loadCoin();
          currentCoinActivate(null);
        });
  }

  /// Activate a given coin.
  /// Used from UI and during the application startup.
  Future<CoinToActivate> enableCoin(Coin coin) async {
    currentCoinActivate(
        CoinToActivate(currentStatus: 'Activating ${coin.abbr} ...'));
    try {
      final ActiveCoin ac =
          await MM.enableCoin(coin).timeout(const Duration(seconds: 30));
      currentCoinActivate(
          CoinToActivate(currentStatus: '${coin.name} activated.'));
      if (ac.requiredConfirmations != coin.requiredConfirmations) {
        Log(
            'coins_bloc:297',
            'enableCoin, ${coin.abbr}, unexpected required_confirmations'
                ', requested: ${coin.requiredConfirmations}'
                ', received: ${ac.requiredConfirmations}');
        coin.requiredConfirmations ??= ac.requiredConfirmations;
      }
      if (ac.requiresNotarization != coin.requiresNotarization) {
        Log(
            'coins_bloc:305',
            'enableCoin, ${coin.abbr}, unexpected requires_notarization'
                ', requested: ${coin.requiresNotarization}'
                ', received: ${coin.requiresNotarization}');
      }
      await Db.coinActive(coin);
      return CoinToActivate(coin: coin, isActive: true);
    } on TimeoutException catch (te) {
      Log('coins_bloc:314', '${coin.abbr} enableCoin timeout, $te');
      currentCoinActivate(
          CoinToActivate(currentStatus: 'Sorry, ${coin.abbr} not available.'));
      await sleepMs(2000);
      currentCoinActivate(null);
      return CoinToActivate(coin: coin, isActive: false);
    } catch (ex) {
      if (ex.toString().contains('already initialized')) {
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Coin ${coin.abbr} already initialized'));
        return CoinToActivate(coin: coin, isActive: true);
      } else {
        Log('coins_bloc:326', '!enableCoin: $ex');
        currentCoinActivate(CoinToActivate(
            currentStatus: 'Sorry, ${coin.abbr} not available.'));
        return CoinToActivate(coin: coin, isActive: false);
      }
    }
  }

  void currentCoinActivate(CoinToActivate coinToActivate) {
    currentActiveCoin = coinToActivate;
    _inCurrentActiveCoin.add(currentActiveCoin);
  }

  Future<void> deactivateCoins(List<Coin> coinsToRemove) async {
    for (Coin coin in coinsToRemove) await Db.coinInactive(coin);
  }

  Future<void> resetCoinDefault() async {
    Log('coins_bloc:344', 'resetCoinDefault');
  }

  Future<List<Coin>> electrumCoins() async {
    final ret = <Coin>[];
    final known = await coins;
    for (String ticker in await Db.activeCoins) ret.add(known[ticker]);
    return ret;
  }

  Future<List<Coin>> getAllNotActiveCoins() async {
    final all = (await coins).values.toList();
    final active = await Db.activeCoins;
    final notActive = <Coin>[];

    for (Coin coin in all) {
      if (active.contains(coin.abbr)) continue;
      notActive.add(coin);
    }

    notActive.sort((Coin a, Coin b) =>
        a.swapContractAddress.compareTo(b.swapContractAddress));
    return notActive;
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
    jobService.install('checkBalance', 45, (j) async {
      if (!mmSe.running) return;
      await loadCoin();
    });
  }

  void stopCheckBalance() {
    jobService.suspend('checkBalance');
  }

  Future<void> loadCoin() async {
    if (mmSe.running && !_coinsLock && !mainBloc.isNetworkOffline) {
      _coinsLock = true;
      final List<Coin> coins = await coinsBloc.electrumCoins();
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
          Log('coins_bloc:415', e);
        }
      }

      _coinsLock = false;
    }
  }

  Future<void> activateCoinsSelected() async {
    final List<Coin> coins = <Coin>[];
    for (CoinToActivate coinToActivate in coinBeforeActivation) {
      if (!coinToActivate.isActive) continue;
      coins.add(coinToActivate.coin);
    }
    await coinsBloc.enableCoins(coins);
    coinsBloc.setCloseViewSelectCoin(true);
  }

  Future<CoinBalance> _getBalanceForCoin(Coin coin) async {
    Balance balance;
    try {
      balance = await MM
          .getBalance(GetBalance(coin: coin.abbr))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      Log('coins_bloc:440', e);
      balance = null;
    }

    final double price = await getPriceObj
        .getPrice(coin.abbr, coin.coingeckoId, 'USD')
        .timeout(const Duration(seconds: 5), onTimeout: () => 0.0);

    dynamic coinBalance;
    if (balance != null && coin.abbr == balance.coin) {
      coinBalance = CoinBalance(coin, balance);
      // Log(
      //     'coins_bloc:480', 'Balance: ' + coinBalance.balance.getBalance());
      // Log('coins_bloc:453',
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
          coin, Balance(address: '', balance: deci('0'), coin: coin.abbr));
      coinBalance.priceForOne = price.toString();
      coinBalance.balanceUSD = 0.0;
    }

    return coinBalance;
  }

  Future<void> activateCoinKickStart() async {
    final dynamic ctks = await MM.getCoinToKickStart(
        mmSe.client, BaseService(method: 'coins_needed_for_kick_start'));
    if (ctks is CoinToKickStart) {
      Log('coins_bloc:478', 'kick_start coins: ${ctks.result}');
      final known = await coins;
      for (String ticker in ctks.result) {
        final coin = known[ticker];
        if (coin == null) continue;
        await Db.coinActive(coin);
      }
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
