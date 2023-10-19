import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_api.dart';
import 'package:komodo_dex/packages/z_coin_activation/bloc/z_coin_activation_repository.dart';
import 'package:komodo_dex/model/wallet.dart';

import '../app_config/app_config.dart';
import '../blocs/main_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../model/active_coin.dart';
import '../model/balance.dart';
import '../model/base_service.dart';
import '../model/cex_provider.dart';
import '../model/coin.dart';
import '../model/coin_balance.dart';
import '../model/coin_to_kick_start.dart';
import '../model/coin_type.dart';
import '../model/disable_coin.dart';
import '../model/error_code.dart';
import '../model/error_string.dart';
import '../model/get_balance.dart';
import '../model/get_disable_coin.dart';
import '../model/get_tx_history.dart';
import '../model/order_book_provider.dart';
import '../model/transaction_data.dart';
import '../model/transactions.dart';
import '../services/db/database.dart';
import '../services/get_erc_transactions.dart';
import '../services/job_service.dart';
import '../services/mm.dart';
import '../services/mm_service.dart';
import '../utils/log.dart';
import '../utils/utils.dart';
import '../widgets/bloc_provider.dart';

class CoinsBloc implements BlocBase {
  CoinsBloc() {
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mmSe.running) return;

      _saveWalletSnapshot();
    });

    // final ZCoinActivationBloc zCoinActivationBloc =
    //     BlocProvider.of<ZCoinActivationBloc>(appStateKey.currentContext);

    jobService.install(
        'retryActivatingSuspended',
        Duration(minutes: 1).inSeconds.toDouble(),
        (j) => retryActivatingSuspendedCoins());
  }

  final _zCoinRepository = ZCoinActivationRepository(ZCoinActivationApi());

  LinkedHashMap<String, Coin> _knownCoins;

  LinkedHashMap<String, Coin> get knownCoins => _knownCoins;

  List<CoinBalance> coinBalance = <CoinBalance>[];
  List<String> coinsWithLessThan10kVol = [];

  // Streams to handle the list coin
  final StreamController<List<CoinBalance>> _coinsController =
      StreamController<List<CoinBalance>>.broadcast();

  Sink<List<CoinBalance>> get _inCoins => _coinsController.sink;
  Stream<List<CoinBalance>> get outCoins => _coinsController.stream;

  dynamic transactions;

  Transactions get transactionsOrNull =>
      transactions is Transactions ? transactions : null;

  // Streams to handle the list coin
  final StreamController<dynamic> _transactionsController =
      StreamController<dynamic>.broadcast();

  Sink<dynamic> get _inTransactions => _transactionsController.sink;
  Stream<dynamic> get outTransactions => _transactionsController.stream;

  // currentActiveCoin == null, when all coins
  // queued for activation are activated
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

  List<CoinToActivate> coinBeforeActivation = <CoinToActivate>[];

  // Streams to handle the list coin to activate
  final StreamController<List<CoinToActivate>> _coinBeforeActivationController =
      StreamController<List<CoinToActivate>>.broadcast();

  Sink<List<CoinToActivate>> get _inCoinBeforeActivation =>
      _coinBeforeActivationController.sink;
  Stream<List<CoinToActivate>> get outCoinBeforeActivation =>
      _coinBeforeActivationController.stream;

  bool _coinsLock = false;

  Set<Coin> get _suspendedCoins {
    final Set<Coin> suspendedCoins = {};

    for (CoinBalance balance in coinBalance) {
      if (balance.coin.suspended)
        suspendedCoins.add(getKnownCoinByAbbr(balance.coin.abbr));
    }

    return suspendedCoins;
  }

  bool _isRetryActivatingRunning = false;

  @override
  void dispose() {
    _coinsController.close();
    _transactionsController.close();
    _currentActiveCoinController.close();
    _closeViewSelectCoinController.close();
    _coinBeforeActivationController.close();
  }

  Coin getCoinByAbbr(String abbr) {
    return getBalanceByAbbr(abbr)?.coin;
  }

  Coin getKnownCoinByAbbr(String abbr) {
    return (knownCoins?.containsKey(abbr) ?? false) ? knownCoins[abbr] : null;
  }

  CoinBalance getBalanceByAbbr(String abbr) {
    return coinBalance.firstWhere(
        (CoinBalance balance) => balance.coin.abbr == abbr,
        orElse: () => null);
  }

  bool isCoinActive(String coin) {
    final CoinBalance balance = coinBalance.firstWhere(
        (CoinBalance bal) => bal.coin.abbr == coin,
        orElse: () => null);

    return balance != null;
  }

  Future<void> initCoinBeforeActivation() async {
    final inactiveCoins = await getAllNotActiveCoins();

    coinBeforeActivation = inactiveCoins.values.map<CoinToActivate>((e) {
      return CoinToActivate(coin: e, isActive: false);
    }).toList();
    _inCoinBeforeActivation.add(coinBeforeActivation);
  }

  bool canActivate(List<CoinToActivate> list) {
    int activated = coinBalance.length;
    int selected = list.where((element) => element.isActive).length;

    int maxCoinLength = Platform.isIOS
        ? appConfig.maxCoinEnabledIOS
        : appConfig.maxCoinsEnabledAndroid;

    return maxCoinLength > selected + activated;
  }

  void setCoinBeforeActivation(Coin coin, bool isActive) {
    coinBeforeActivation
        .removeWhere((CoinToActivate item) => item.coin.abbr == coin.abbr);

    if (isActive && canActivate(coinBeforeActivation)) {
      coinBeforeActivation.add(CoinToActivate(coin: coin, isActive: isActive));

      // auto add parent coin if not enabled previously
      // if the parent is then removed intentionally by the user
      // it wont be enabled. But if SLP coins are even removed after auto adding
      // they will be forced enabled because parent coins are needed enabled before
      // SLP coins can enable
      String platform = coin?.protocol?.protocolData?.platform;
      bool isParentEnabled =
          coinBalance.any((element) => element.coin.abbr == platform);
      if (isActive &&
          platform != null &&
          !isParentEnabled &&
          canActivate(coinBeforeActivation)) {
        Coin parentCoin = getKnownCoinByAbbr(platform);
        coinBeforeActivation.removeWhere(
            (CoinToActivate item) => item.coin.abbr == parentCoin.abbr);
        coinBeforeActivation.add(
          CoinToActivate(coin: parentCoin, isActive: isActive),
        );
      }
    } else {
      coinBeforeActivation.add(CoinToActivate(coin: coin, isActive: false));
    }
    _inCoinBeforeActivation.add(coinBeforeActivation);
  }

  void setCoinsBeforeActivationByType(
    String type,
    bool isActive, {
    String query,
    String filterType,
  }) {
    coinBeforeActivation.sort((a, b) =>
        a.coin.name.toUpperCase().compareTo(b.coin.name.toUpperCase()));

    List<CoinToActivate> typeList = coinBeforeActivation
        .where((coin) =>
            (coin.coin.type.name == (coin.coin.testCoin ? null : type)) &&
            isCoinPresent(coin.coin, query, filterType))
        .toList();

    int selected = coinBeforeActivation
        .where((element) =>
            element.isActive &&
            !typeList.map((e) => e.coin.abbr).contains(element.coin.abbr))
        .length;
    int activated = coinBalance.length;

    int maxCoinLength = Platform.isIOS
        ? appConfig.maxCoinEnabledIOS
        : appConfig.maxCoinsEnabledAndroid;

    int remaining = maxCoinLength - activated - selected;
    int counter = 0;
    List<String> _tempList = [];

    for (int i = 0; i < typeList.length; i++) {
      Coin coin = typeList[i].coin;
      coinBeforeActivation
          .removeWhere((CoinToActivate item) => item.coin.abbr == coin.abbr);

      String platform = coin?.protocol?.protocolData?.platform;

      if (isActive && counter < remaining) {
        coinBeforeActivation
            .add(CoinToActivate(coin: coin, isActive: isActive));
        if (!_tempList.contains(coin.abbr)) counter++;

        // auto add parent coin if not enabled previously
        if (platform == null) continue;
        bool isParentEnabled =
            coinBalance.any((element) => element.coin.abbr == platform);
        bool selectedParent = coinBeforeActivation.any(
            (element) => element.coin.abbr == platform && !element.isActive);
        if (selectedParent && !isParentEnabled) {
          Coin parentCoin = getKnownCoinByAbbr(platform);
          _tempList.add(parentCoin.abbr);
          coinBeforeActivation.removeWhere(
              (CoinToActivate item) => item.coin.abbr == parentCoin.abbr);

          coinBeforeActivation
              .add(CoinToActivate(coin: parentCoin, isActive: true));

          counter++;
        }
        coinBeforeActivation
            .add(CoinToActivate(coin: coin, isActive: isActive));
      } else {
        coinBeforeActivation.add(CoinToActivate(coin: coin, isActive: false));
      }
    }
    _inCoinBeforeActivation.add(coinBeforeActivation);
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

      if (coin.type == CoinType.zhtlc) {
        await _zCoinRepository.legacyCoinsBlocDisableLocallyCallback(coin.abbr);
      }
    }
  }

  Future<void> _removeSuspendedCoin(Coin coin) async {
    if (!coin.suspended) {
      Log('coins_bloc] _removeSuspendedCoin]', '${coin.abbr} is not suspended');
      return;
    }

    await removeCoinBalance(coin);
    await deactivateCoins(<Coin>[coin]);
  }

  Future<void> removeIrisCoin(Coin coin, List<CoinBalance> irisTokens) async {
    if (coin.suspended) {
      _removeSuspendedCoin(coin);
      for (var e in irisTokens) {
        e.coin.suspended = true;
        _removeSuspendedCoin(e.coin);
      }
      return;
    }

    await removeCoinBalance(coin);
    final res = await MM.disableCoin(GetDisableCoin(coin: coin.abbr));
    removeCoinLocal(coin, res);
    syncOrderbook.updateActivePair();
    for (var e in irisTokens) {
      e.coin.suspended = true;
      _removeSuspendedCoin(e.coin);
    }
  }

  Future<void> removeCoin(Coin coin) async {
    if (coin.suspended) {
      _removeSuspendedCoin(coin);
      return;
    }

    await removeCoinBalance(coin);
    final res = await MM.disableCoin(GetDisableCoin(coin: coin.abbr));
    removeCoinLocal(coin, res);
    syncOrderbook.updateActivePair();
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

  Future<void> updateTransactions(
      CoinBalance coinBalance, int limit, String fromId) async {
    Coin coin = coinBalance.coin;
    try {
      dynamic transactionData;

      if (isErcType(coin)) {
        transactionData = await getErcTransactions.getTransactions(
          coin: coin,
          fromId: fromId,
        );
      } else {
        transactionData = await MM.getTransactions(
          mmSe.client,
          GetTxHistory(coin: coin.abbr, limit: limit, fromId: fromId),
        );
      }

      if (transactionData is Transactions && transactionData.result != null) {
        transactionData.camouflageIfNeeded();

        final thisTransactions = transactions?.result?.transactions;

        final mustMergeCurrentCoin = fromId != null &&
            (thisTransactions is List<Transaction> &&
                    (thisTransactions
                        .any((Transaction tx) => tx.coin == coin.abbr)) ??
                false);

        transactionData.result?.transactions = [
          if (mustMergeCurrentCoin) ...(thisTransactions ?? []),
          ...(transactionData.result?.transactions ?? [])
        ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        transactions = transactionData;
      } else if (transactionData is ErrorCode) {
        Log(
          'coins_bloc:updateTransactions',
          'Failed to get transactions: $coin: ${transactionData.toJson()}',
        );
      }
      _inTransactions.add(transactionData);
    } catch (e) {
      Log('coins_bloc:244', e);
      rethrow;
    }
  }

  Future<void> retryActivatingSuspendedCoins() async {
    if (_isRetryActivatingRunning) return;
    if (_suspendedCoins.isEmpty) return;

    _isRetryActivatingRunning = true;

    final formattedAbbrs = _suspendedCoins.map((c) => c.abbr).join(', ');
    Log('coins_bloc',
        'retryActivatingSuspendedCoins] Retrying activating suspended coins: $formattedAbbrs');

    await enableCoins(_suspendedCoins.toList());

    if (_suspendedCoins.isEmpty) {
      Log('coins_bloc',
          'retryActivatingSuspendedCoins] All suspended coins were successfully activated and un-suspended');
    } else {
      final remaining = _suspendedCoins.join(', ');
      Log('coins_bloc',
          'retryActivatingSuspendedCoins] After 3 tries the following coins remain suspended: $remaining');
    }

    _isRetryActivatingRunning = false;
  }

  Future<List> enablePreParentCoins(List<Coin> parentCoins) async {
    if (parentCoins.isEmpty) return [];
    List<Map<String, dynamic>> batch = [];
    for (Coin coin in parentCoins) {
      batch.add(json.decode(MM.enableCoinImpl(coin)));
    }
    return await MM.batch(batch);
  }

  /// Handle the coins user has picked for activation.
  /// Also used for coin activations during the application startup.
  Future<void> enableCoins(List<Coin> coins, {initialization = false}) async {
    await pauseUntil(() => !_coinsLock, maxMs: 3000);
    _coinsLock = true;

    // list of needed-parent-coins
    List<Coin> preEnabledCoins = [];
    for (Coin coin
        in coins.where((element) => hasParentPreInstalled(element))) {
      String platform = coin?.protocol?.protocolData?.platform;
      bool isParentEnabled =
          coinBalance.any((element) => element.coin.abbr == platform);
      if (!isParentEnabled) //parent coin is already enabled
        preEnabledCoins
            .add(getKnownCoinByAbbr(coin.protocol.protocolData.platform));
    }
    preEnabledCoins = preEnabledCoins.toSet().toList();

    final List<String> requestedZCoins = coins
        .where((c) => c.type == CoinType.zhtlc)
        .map((c) => c.abbr)
        .toList();

    await _zCoinRepository.addRequestedActivatedCoins(requestedZCoins);

    // await _zCoinRepository.setRequestedActivatedCoins(requestedZCoins);
    // _zCoinRepository.activateRequestedZCoins().forEach((_) {
    //   Log('coins_bloc:enableCoins', 'Activating requested ZCoins');
    // });

    coins.removeWhere((coin) => requestedZCoins.contains(coin.abbr));

    // remove needed-parent-coins from the main coin list
    coins.removeWhere((coin) => preEnabledCoins.contains(coin));

    // activate remaining coins using a batch request to speed up the coin activation.
    final List<Map<String, dynamic>> batch = [];
    for (Coin coin in coins) {
      batch.add(json.decode(MM.enableCoinImpl(coin)));
    }
    // activate slp-parent-coins first before others.
    final preEnabledCoinReplies = await enablePreParentCoins(preEnabledCoins);
    final replies = await MM.batch(batch);
    coins.addAll(preEnabledCoins);
    replies.addAll(preEnabledCoinReplies);
    if (replies.length != coins.length) {
      throw Exception(
          'Unexpected number of replies: ${replies.length} != ${coins.length}');
    }
    for (int ix = 0; ix < coins.length; ++ix) {
      final coin = coins[ix];
      final Map<String, dynamic> ans = replies[ix];
      final err = ErrorString.fromJson(ans);
      final abbr = coin.abbr;

      if (err.error.isNotEmpty) {
        Log('coins_bloc:273', 'Error activating $abbr: ${err.error}');

        continue;
      }
      final acc = ActiveCoin.fromJson(ans, coin);
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
      // Before actual coin activation, coinBalance can store
      // coins data (including balanceUSD) loaded from wallet snapshot,
      // created during previous session (#898)
      final double preSavedUsdBalance = getBalanceByAbbr(acc.coin)?.balanceUSD;
      cb.balanceUSD = preSavedUsdBalance ?? 0;
      updateOneCoin(cb);
    }

    await syncCoinsStateWithApi();

    currentCoinActivate(null);
    _coinsLock = false;
  }

  /// Used by external services that need to integrate with the coins bloc
  /// to register a coin as active in the frontend after it has been activated
  /// in the backend by an external service.
  Future<void> setupCoinAfterActivation(Coin coin) async {
    Db.coinActive(coin);
    final balance = await MM.getBalance(GetBalance(coin: coin.abbr));

    if (balance == null) {
      Log('coins_bloc:549', 'balance is null');
      return;
    }

    balance.camouflageIfNeeded();

    final cb = CoinBalance(coin, balance);

    final double preSavedUsdBalance = getBalanceByAbbr(coin.abbr)?.balanceUSD;
    cb.balanceUSD = preSavedUsdBalance ?? 0;

    updateOneCoin(cb);

    await syncCoinsStateWithApi();

    if (currentActiveCoin?.coin?.abbr == coin.abbr) {
      currentCoinActivate(null);
    }
  }

  Future<void> syncCoinsStateWithApi([bool ignoreZcash = true]) async {
    final List<dynamic> apiCoinsJson = await MM.getEnabledCoins();
    final List<String> apiCoins = [];

    for (dynamic item in apiCoinsJson) {
      apiCoins.add(item['ticker']);
    }

    for (CoinBalance balance in coinBalance) {
      bool shouldSuspend = !apiCoins.contains(balance.coin.abbr);

      if (balance.coin.type == CoinType.zhtlc && ignoreZcash) {
        // ignore zhtlc coins because they activate later than the
        // other coins and they are handled in zcashBloc
        continue;
      } else if (shouldSuspend) {
        balance.coin.suspended = true;

        Log('coins_bloc]',
            '${balance.coin.abbr} had an error during activation and was suspended');
      } else if (balance.coin.suspended) {
        balance.coin.suspended = false;

        Log('coins_bloc]',
            '${balance.coin.abbr} did successfully activate and was un-suspended');
      }

      _inCoins.add(coinBalance);
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
      await removeCoinBalance(Coin(abbr: ticker));
    }

    _knownCoins = known;

    return ret;
  }

  Future<LinkedHashMap<String, Coin>> getAllNotActiveCoins() async {
    final LinkedHashMap<String, Coin> all = await coins;
    final Set<String> active = await Db.activeCoins;

    // Get all coin abbreviations
    Set<String> allCoinAbbrs = all.keys.toSet();

    // Find the difference
    Set<String> notActiveAbbrs = allCoinAbbrs.difference(active);

    final pendingZCoins = await _zCoinRepository.outstandingZCoinActivations();

    // remove z-coin that are currently enabling from activation list
    notActiveAbbrs.removeAll(pendingZCoins);

    final List<String> sorted = notActiveAbbrs.toList()
      ..sort((a, b) =>
          all[a].swapContractAddress.compareTo(all[b].swapContractAddress));

    final hashMap = LinkedHashMap<String, Coin>();

    hashMap.addEntries(sorted.map((e) => MapEntry(e, all[e])));

    return hashMap;
  }

  Future<List<Coin>> getAllNotActiveCoinsWithFilter(
      String query, String type) async {
    List<Coin> coinsActivate = (await getAllNotActiveCoins()).values.toList();
    coinsActivate = filterCoinsByQuery(coinsActivate, query, type: type);
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
    if (!mmSe.running || mainBloc.networkStatus != NetworkStatus.Online) return;

    final List<Coin> coins = await coinsBloc.electrumCoins();
    if (coins.isEmpty) {
      resetCoinBalance();
      return;
    }

    await pauseUntil(() => !_coinsLock, maxMs: 3000);
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

      if (coinToActivate.coin.testCoin && !settingsBloc.enableTestCoins) {
        if (!appConfig.defaultTestCoins.contains(coinToActivate.coin.abbr))
          continue;
      }

      coins.add(coinToActivate.coin);
    }
    await coinsBloc.enableCoins(coins);
    await updateCoinBalances();

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

      final int namesCompared = a.coin.name.compareTo(b.coin.name);
      if (namesCompared != 0) return namesCompared;

      return a.coin.abbr.compareTo(b.coin.abbr);
    });

    return _sorted;
  }

  List<CoinBalance> sortCoinsWithoutTestCoins(List<CoinBalance> unsorted) {
    List<CoinBalance> _sorted = [];
    _sorted = sortCoins(unsorted);
    _sorted.removeWhere((CoinBalance c) => c.coin.testCoin);
    return _sorted;
  }

  Future<Transaction> getLatestTransaction(CoinBalance coinBalance) async {
    const int limit = 1;
    const String fromId = null;
    Coin coin = coinBalance.coin;
    try {
      dynamic transactions;
      if (isErcType(coin)) {
        transactions = await getErcTransactions.getTransactions(
            coin: coin, fromId: fromId);
      } else {
        transactions = await MM.getTransactions(mmSe.client,
            GetTxHistory(coin: coin.abbr, limit: limit, fromId: fromId));
      }

      if (transactions is Transactions) {
        transactions.camouflageIfNeeded();
        if ((transactions.result?.transactions ?? []).isNotEmpty) {
          return transactions.result.transactions[0];
        }
        return null;
      } else if (transactions is ErrorCode) {
        return null;
      }
      return null;
    } catch (e) {
      Log('coins_bloc:545', e);
      rethrow;
    }
  }

  bool _walletSnapshotInProgress = false;
  Future<void> _saveWalletSnapshot() async {
    if (_walletSnapshotInProgress) return;
    if (coinBalance == null || coinBalance.isEmpty) return;

    _walletSnapshotInProgress = true;

    final String jsonStr = json.encode(coinBalance);
    await Db.saveWalletSnapshot(jsonStr);
    Log('coins_bloc]', 'Wallet snapshot created');

    _walletSnapshotInProgress = false;
  }

  Future<void> loadWalletSnapshot({Wallet wallet}) async {
    final String jsonStr = await Db.getWalletSnapshot(wallet: wallet);
    if (jsonStr == null) return;

    List<dynamic> items;
    try {
      items = json.decode(jsonStr);
    } catch (e) {
      print('Failed to parse wallet snapshot: $e');
    }

    if (items == null || items.isEmpty) return;

    final currentCoins = await Db.activeCoins;
    final List<CoinBalance> list = [];
    for (dynamic item in items) {
      final tmp = CoinBalance.fromJson(item);
      final abbr = tmp.coin.abbr;
      if (!currentCoins.contains(abbr)) {
        Log('coins_bloc',
            'loadWalletSnapshot] $abbr IS PRESENT on SNAPSHOT but was disabled by user, ignoring stored data...');
        continue;
      }
      list.add(tmp);
    }

    coinBalance = list;
    _inCoins.add(coinBalance);
  }
}

CoinsBloc coinsBloc = CoinsBloc();

class CoinToActivate {
  CoinToActivate({this.coin, this.isActive, this.currentStatus});

  Coin coin;
  String currentStatus;
  bool isActive;
}
