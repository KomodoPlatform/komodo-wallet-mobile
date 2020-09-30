import 'dart:async';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/cex_provider.dart';
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
import 'package:komodo_dex/services/get_erc_transactions.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/db/database.dart';
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

  Coin getCoinByAbbr(String abbr) {
    return getBalanceByAbbr(abbr)?.coin;
  }

  CoinBalance getBalanceByAbbr(String abbr) {
    return coinBalance.firstWhere(
        (CoinBalance balance) => balance.coin.abbr == abbr,
        orElse: () => null);
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
      dynamic transactions;
      if (coin.type == 'erc') {
        transactions = await getErcTransactions.getTransactions(
            coin: coin, fromId: fromId);
      } else {
        transactions = await MM.getTransactions(mmSe.client,
            GetTxHistory(coin: coin.abbr, limit: limit, fromId: fromId));
      }

      if (transactions is Transactions) {
        transactions.camouflageIfNeeded();

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
      Log('coins_bloc:244', e);
      rethrow;
    }
  }

  /// Handle the coins user has picked for activation.
  /// Also used for coin activations during the application startup.
  Future<void> enableCoins(List<Coin> coins) async {
    while (_coinsLock) await sleepMs(77);
    _coinsLock = true;

    // Using a batch request to speed up the coin activation.
    // NB: In the future we want to use a non-blocking API instead
    // in order for the UI not to stuck if an activation of a particular coin is delayed.
    // cf. https://github.com/KomodoPlatform/atomicDEX-API/issues/638
    final List<Map<String, dynamic>> batch = [];
    for (Coin coin in coins) {
      batch.add(json.decode(MM.enableCoinImpl(coin)));
    }
    final replies = await MM.batch(batch);
    if (replies.length != batch.length) {
      throw Exception(
          'Unexpected number of replies: ${replies.length} != ${batch.length}');
    }
    for (int ix = 0; ix < coins.length; ++ix) {
      final coin = coins[ix];
      final Map<String, dynamic> ans = replies[ix];
      final err = ErrorString.fromJson(ans);
      if (err.error.isNotEmpty) {
        Log('coins_bloc:273', 'Error activating ${coin.abbr}: ${err.error}');
        continue;
      }
      final acc = ActiveCoin.fromJson(ans);
      if (acc.result != 'success') {
        Log('coins_bloc:278', '!success: $ans');
        continue;
      }
      await Db.coinActive(coin);
      final bal = Balance(
          address: acc.address,
          balance: deci(acc.balance),
          lockedBySwaps: deci(acc.lockedBySwaps),
          coin: acc.coin);
      bal.camouflageIfNeeded();
      final cb = CoinBalance(coin, bal);
      // TODO(AG): Load previous USD balance from database
      cb.balanceUSD = 0;
      updateOneCoin(cb);
    }

    currentCoinActivate(null);
    _coinsLock = false;
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
            'coins_bloc:308',
            'enableCoin, ${coin.abbr}, unexpected required_confirmations'
                ', requested: ${coin.requiredConfirmations}'
                ', received: ${ac.requiredConfirmations}');
        coin.requiredConfirmations ??= ac.requiredConfirmations;
      }
      if (ac.requiresNotarization != coin.requiresNotarization) {
        Log(
            'coins_bloc:316',
            'enableCoin, ${coin.abbr}, unexpected requires_notarization'
                ', requested: ${coin.requiresNotarization}'
                ', received: ${coin.requiresNotarization}');
      }
      await Db.coinActive(coin);
      return CoinToActivate(coin: coin, isActive: true);
    } on TimeoutException catch (te) {
      Log('coins_bloc:325', '${coin.abbr} enableCoin timeout, $te');
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
        Log('coins_bloc:337', '!enableCoin: $ex');
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
    for (Coin coin in coinsToRemove) await Db.coinInactive(coin.abbr);
  }

  Future<void> resetCoinDefault() async {
    Log('coins_bloc:355', 'resetCoinDefault');
  }

  Future<List<Coin>> electrumCoins() async {
    final ret = <Coin>[];
    final known = await coins;
    final List<String> deactivate = [];
    for (String ticker in await Db.activeCoins) {
      final coin = known[ticker];
      if (coin == null) {
        deactivate.add(ticker);
        continue;
      }
      ret.add(coin);
    }
    for (final String ticker in deactivate) {
      Log('coins_bloc:371', '$ticker is unknown, removing from active coins');
      await Db.coinInactive(ticker);
    }
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
      await updateCoinBalances();
    });
  }

  void stopCheckBalance() {
    jobService.suspend('checkBalance');
  }

  Future<void> updateCoinBalances() async {
    if (!mmSe.running || mainBloc.isNetworkOffline) return;

    final List<Coin> coins = await coinsBloc.electrumCoins();
    if (coins.isEmpty) {
      resetCoinBalance();
      return;
    }

    while (_coinsLock) await sleepMs(77);
    _coinsLock = true;

    await cexPrices.updatePrices(coins);

    // NB: Loading balances sequentially in order to better reuse HTTP file descriptors
    for (Coin coin in coins) {
      try {
        final CoinBalance balance = await _getBalanceForCoin(coin);
        if (balance.balance.address != null &&
            balance.balance.address.isNotEmpty) {
          updateOneCoin(balance);
        }
      } catch (ex) {
        Log('coins_bloc:434', 'Error updating ${coin.abbr} balance: $ex');
      }
    }

    _coinsLock = false;
  }

  Future<void> activateCoinsSelected() async {
    final List<Coin> coins = <Coin>[];
    for (CoinToActivate coinToActivate in coinBeforeActivation) {
      if (!coinToActivate.isActive) continue;
      coins.add(coinToActivate.coin);
    }
    await coinsBloc.enableCoins(coins);
    updateCoinBalances();

    coinsBloc.setCloseViewSelectCoin(true);
  }

  Future<CoinBalance> _getBalanceForCoin(Coin coin) async {
    Balance balance;
    try {
      balance = await MM
          .getBalance(GetBalance(coin: coin.abbr))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      Log('coins_bloc:458', e);
      balance = null;
    }

    final double price = cexPrices.getUsdPrice(coin.abbr);

    dynamic coinBalance;
    if (balance != null && coin.abbr == balance.coin) {
      coinBalance = CoinBalance(coin, balance);
      coinBalance.priceForOne = price.toString();
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
      Log('coins_bloc:496', 'kick_start coins: ${ctks.result}');
      final known = await coins;
      for (String ticker in ctks.result) {
        final coin = known[ticker];
        if (coin == null) continue;
        await Db.coinActive(coin);
      }
    }
  }

  List<CoinBalance> sortCoins(List<CoinBalance> unsorted) {
    final List<CoinBalance> _sorted = List.from(unsorted);
    _sorted.sort((a, b) {
      if (a.balanceUSD < b.balanceUSD) return 1;
      if (a.balanceUSD > b.balanceUSD) return -1;

      if (a.balance.balance < b.balance.balance) return 1;
      if (a.balance.balance > b.balance.balance) return -1;

      return a.coin.name.compareTo(b.coin.name);
    });

    return _sorted;
  }

  Future<dynamic> getLatestTransaction(Coin coin) async {
    const int limit = 1;
    const String fromId = null;
    try {
      dynamic transactions;
      if (coin.type == 'erc') {
        transactions = await getErcTransactions.getTransactions(
            coin: coin, fromId: fromId);
      } else {
        transactions = await MM.getTransactions(mmSe.client,
            GetTxHistory(coin: coin.abbr, limit: limit, fromId: fromId));
      }

      if (transactions is Transactions) {
        transactions.camouflageIfNeeded();

        return transactions;
      } else if (transactions is ErrorCode) {
        return transactions;
      }
    } catch (e) {
      Log('coins_bloc:545', e);
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
