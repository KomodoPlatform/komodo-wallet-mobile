import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show File, Platform, Process, ProcessResult;

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart'
    show ByteData, EventChannel, MethodChannel, rootBundle;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_init.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/model/get_enable_coin.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_active_coin.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/get_cancel_order.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/get_recent_swap.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_swap.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// MarketMakerService mm2 = MarketMakerService();

class MarketMakerService {
  factory MarketMakerService() {
    return _singleton;
  }

  MarketMakerService._internal();

  static final MarketMakerService _singleton = MarketMakerService._internal();

  List<dynamic> balances = <dynamic>[];
  Process mm2Process;
  List<Coin> coins = <Coin>[];
  bool ismm2Running = false;
  String url = 'http://localhost:7783';
  String userpass = '';
  Stream<List<int>> streamSubscriptionStdout;
  String pubkey = '';
  String filesPath = '';
  dynamic sink;
  static const MethodChannel platformmm2 = MethodChannel('mm2');
  static const EventChannel eventChannel = EventChannel('streamLogMM2');

  Future<void> initMarketMaker() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    filesPath = directory.path + '/';

    if (Platform.isAndroid) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String newBuildNumber = packageInfo.buildNumber;

      try {
        final ProcessResult checkmm2 =
            await Process.run('ls', <String>['${filesPath}mm2']);
        final String currentBuildNumber = prefs.getString('version');

        if (checkmm2.stdout.toString().trim() != '${filesPath}mm2' ||
            currentBuildNumber == null ||
            currentBuildNumber.isEmpty ||
            currentBuildNumber != newBuildNumber) {
          await prefs.setString('version', newBuildNumber);
          await coinsBloc.resetCoinDefault();
          final ByteData resultmm2 = await rootBundle.load('assets/mm2');
          if (checkmm2.stdout.toString().trim() == '${filesPath}mm2') {
            await deletemm2File();
          }
          await writeData(resultmm2.buffer.asUint8List());
          await Process.run('chmod', <String>['544', '${filesPath}mm2']);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> runBin() async {
    final String passphrase = await EncryptionTool().read('passphrase');

    final List<int> bytes = utf8.encode(passphrase); // data being hashed
    userpass = sha256.convert(bytes).toString();

    final String coinsInitParam = coinInitToJson(await readJsonCoinInit());

    final String startParam =
        '{\"gui\":\"atomicDEX\",\"netid\":9999,\"client\":1,\"userhome\":\"$filesPath\",\"passphrase\":\"$passphrase\",\"rpc_password\":\"$userpass\",\"coins\":$coinsInitParam,\"dbdir\":\"$filesPath\"}';

    final File file = File('$filesPath/log.txt');

    sink = file.openWrite();

    if (Platform.isAndroid) {
      await stopmm2();

      try {
        mm2Process = await Process.start('./mm2', <String>[startParam],
            workingDirectory: '$filesPath');

        mm2Process.stderr.listen((List<int> onData) {
          final String logMm2 = utf8.decoder.convert(onData).trim();
          print(logMm2);
          sink.write(logMm2 + '\n');
        });
        mm2Process.stdout.listen((List<int> onData) {
          final String logMm2 = utf8.decoder.convert(onData).trim();

          _onLogsmm2(logMm2);
          if (logMm2.contains('DEX stats API enabled at')) {
            print('DEX stats API enabled at');

            ismm2Running = true;

            _initCoinsAndLoad();
            coinsBloc.startCheckBalance();
          }
        });
      } catch (e) {
        print(e);
        rethrow;
      }
    } else if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      try {
        await platformmm2.invokeMethod<dynamic>(
            'start', <String, String>{'params': startParam}); //start mm2

        // check when mm2 is ready then load coins
        final int timerTmp = DateTime.now().millisecondsSinceEpoch;
        Timer.periodic(const Duration(seconds: 2), (_) {
          final int t1 = timerTmp + 20000;
          final int t2 = DateTime.now().millisecondsSinceEpoch;
          if (t1 <= t2) {
            _.cancel();
          }

          checkStatusmm2().then((int onValue) {
            print('STATUS MM2: ' + onValue.toString());
            if (onValue == 3) {
              ismm2Running = true;
              _.cancel();
              print('CANCEL TIMER');
              _initCoinsAndLoad();
              coinsBloc.startCheckBalance();
            }
          });
        });
      } catch (e) {
        print(e);
        rethrow;
      }
    }
  }

  void _onLogsmm2(String log) {
    print(log);
    sink.write(log + '\n');
    if (log.contains('CONNECTED') ||
        log.contains('Entering the taker_swap_loop') ||
        log.contains('Received \'negotiation') ||
        log.contains('Got maker payment') ||
        log.contains('Sending \'taker-fee') ||
        log.contains('Sending \'taker-payment') ||
        log.contains('Finished')) {
      Future<dynamic>.delayed(const Duration(seconds: 1), () {
        swapHistoryBloc.updateSwaps(50, null).then((_) {
          ordersBloc.updateOrdersSwaps();
        });
      });
    }
  }

  void _onEvent(Object event) {
    _onLogsmm2(event);
  }

  void _onError(Object error) {
    print(error);
  }

  Future<List<CoinInit>> readJsonCoinInit() async {
    try {
      return coinInitFromJson(
          await rootBundle.loadString('assets/coins_init_mm2.json'));
    } catch (e) {
      return <CoinInit>[];
    }
  }

  Future<void> _initCoinsAndLoad() async {
    try {
      await coinsBloc.activateCoinKickStart();

      coinsBloc.addMultiCoins(await coinsBloc.readJsonCoin()).then((_) {
        print('ALL COINS ACTIVATES');
        coinsBloc.loadCoin().then((_) {
          print('LOADCOIN FINISHED');
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<int> checkStatusmm2() async {
    return await platformmm2.invokeMethod('status');
  }

  Future<File> get _localFile async {
    return File('${filesPath}mm2');
  }

  Future<File> writeData(List<int> data) async {
    final File file = await _localFile;
    return file.writeAsBytes(data);
  }

  Future<void> deletemm2File() async {
    final File file = await _localFile;
    await file.delete();
  }

  Future<dynamic> stopmm2() async {
    ismm2Running = false;
    try {
      final BaseService baseService =
          BaseService(userpass: userpass, method: 'stop');
      final Response response =
          await http.post(url, body: baseServiceToJson(baseService));
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      return baseServiceFromJson(response.body);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Coin>> loadJsonCoins(String loadFile) async {
    final String jsonString = loadFile;
    final Iterable<dynamic> l = json.decode(jsonString);
    final List<Coin> coins =
        l.map((dynamic model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<Coin>> loadJsonCoinsDefault() async {
    final String jsonString = await loadDefaultActivateCoin();
    final Iterable<dynamic> l = json.decode(jsonString);
    final List<Coin> coins =
        l.map((dynamic model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<dynamic>> getAllBalances(bool forceUpdate) async {
    final List<Coin> coins = await coinsBloc.readJsonCoin();

    if (balances.isEmpty || forceUpdate || coins.length != balances.length) {
      List<dynamic> balances = <dynamic>[];
      final List<Future<dynamic>> futureBalances = <Future<dynamic>>[];

      for (Coin coin in coins) {
        futureBalances.add(getBalance(coin));
      }
      balances = await Future.wait<dynamic>(futureBalances);
      balances = balances;
      return balances;
    } else {
      return balances;
    }
  }

  Future<String> loadElectrumServersAsset() async {
    return await rootBundle.loadString('assets/coins_config.json');
  }

  Future<String> loadDefaultActivateCoin() async {
    return await rootBundle.loadString('assets/coins_activate_default.json');
  }

  Future<dynamic> getSwapStatus(String uuid) async {
    final GetSwap getSwap = GetSwap(
        userpass: userpass,
        method: 'my_swap_status',
        params: Params(uuid: uuid));

    try {
      final Response response =
          await http.post(url, body: getSwapToJson(getSwap));
      try {
        return swapFromJson(response.body);
      } catch (e) {
        print(e);
        return errorStringFromJson(response.body);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Orderbook> getOrderbook(Coin coinBase, Coin coinRel) async {
    final GetOrderbook getOrderbook = GetOrderbook(
        userpass: userpass,
        method: 'orderbook',
        base: coinBase.abbr,
        rel: coinRel.abbr);

    try {
      final Response response =
          await http.post(url, body: json.encode(getOrderbook));
      print('orderbook' + response.body.toString());
      return orderbookFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<dynamic> getBalance(Coin coin) async {
    final GetBalance getBalance =
        GetBalance(userpass: userpass, method: 'my_balance', coin: coin.abbr);

    try {
      final Response response =
          await http.post(url, body: json.encode(getBalance));

      print('getBalance' + response.body.toString());

      try {
        return balanceFromJson(response.body);
      } catch (e) {
        print(e);
        return errorStringFromJson(response.body);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<BuyResponse> postBuy(
      Coin base, Coin rel, Decimal volume, String price) async {
    print('postBuy>>>>>>>>>>>>>>>>> SWAPPARAM: base: ' +
        base.abbr +
        ' rel: ' +
        rel.abbr.toString() +
        ' relvol: ' +
        volume.toString() +
        ' price: ' +
        price.toString());
    final GetBuy getBuy = GetBuy(
        userpass: userpass,
        method: 'buy',
        base: base.abbr,
        rel: rel.abbr,
        volume: volume.toString(),
        price: price);
    print(json.encode(getBuy));

    try {
      final Response response = await http.post(url, body: json.encode(getBuy));
      print(response.body.toString());
      try {
        return buyResponseFromJson(response.body);
      } catch (e) {
        print(e);
        throw errorStringFromJson(response.body);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<dynamic> postSell(
      Coin base, Coin rel, double volume, double price) async {
    print('postSellSWAPPARAM: base: ' +
        base.abbr +
        ' rel: ' +
        rel.abbr.toString() +
        ' relvol: ' +
        volume.toString() +
        ' price: ' +
        price.toString());
    final GetBuy getBuy = GetBuy(
        userpass: userpass,
        method: 'sell',
        base: base.abbr,
        rel: rel.abbr,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));
    print(json.encode(getBuy));

    try {
      final Response response = await http.post(url, body: json.encode(getBuy));

      print(response.body.toString());
      try {
        return buyResponseFromJson(response.body);
      } catch (e) {
        return errorStringFromJson(response.body);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<SetPriceResponse> postSetPrice(Coin base, Coin rel, String volume,
      String price, bool cancelPrevious, bool max) async {
    final GetSetPrice getSetPrice = GetSetPrice(
        userpass: userpass,
        method: 'setprice',
        base: base.abbr,
        rel: rel.abbr,
        cancelPrevious: cancelPrevious,
        max: max,
        volume: volume,
        price: price);

    print('postSetPrice' + getSetPriceToJson(getSetPrice));
    try {
      final Response response =
          await http.post(url, body: getSetPriceToJson(getSetPrice));

      print(response.body.toString());

      try {
        return setPriceResponseFromJson(response.body);
      } catch (e) {
        throw errorStringFromJson(response.body);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<dynamic> getTransactions(Coin coin, int limit, String fromId) async {
    final GetTxHistory getTxHistory = GetTxHistory(
        userpass: userpass,
        method: 'my_tx_history',
        coin: coin.abbr,
        limit: limit,
        fromId: fromId);
    print(json.encode(getTxHistory));
    print(url);
    try {
      final Response response =
          await http.post(url, body: getTxHistoryToJson(getTxHistory));
      print('RESULT: ' + response.body.toString());
      try {
        return transactionsFromJson(response.body);
      } catch (e) {
        print(e);
        return errorCodeFromJson(response.body);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<RecentSwaps> getRecentSwaps(int limit, String fromUuid) async {
    final GetRecentSwap getRecentSwap = GetRecentSwap(
        userpass: userpass,
        method: 'my_recent_swaps',
        limit: limit,
        fromUuid: fromUuid);

    try {
      final Response response =
          await http.post(url, body: getRecentSwapToJson(getRecentSwap));
      print(response.body.toString());
      return recentSwapsFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Orders> getMyOrders() async {
    final GetRecentSwap getRecentSwap =
        GetRecentSwap(userpass: userpass, method: 'my_orders');

    try {
      final Response response =
          await http.post(url, body: getRecentSwapToJson(getRecentSwap));
      print('my_orders' + response.body.toString());
      return ordersFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<ResultSuccess> cancelOrder(String uuid) async {
    final GetCancelOrder getCancelOrder =
        GetCancelOrder(userpass: userpass, method: 'cancel_order', uuid: uuid);

    try {
      final Response response =
          await http.post(url, body: getCancelOrderToJson(getCancelOrder));
      print('cancel_order' + response.body.toString());
      return resultSuccessFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<CoinToKickStart> getCoinToKickStart() async {
    final GetRecentSwap getRecentSwap = GetRecentSwap(
        userpass: userpass, method: 'coins_needed_for_kick_start');

    try {
      final Response response =
          await http.post(url, body: getRecentSwapToJson(getRecentSwap));
      print('coins_needed_for_kick_start' + response.body.toString());
      return coinToKickStartFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<dynamic> postRawTransaction(Coin coin, String txHex) async {
    final GetSendRawTransaction getSendRawTransaction = GetSendRawTransaction(
        userpass: userpass,
        method: 'send_raw_transaction',
        coin: coin.abbr,
        txHex: txHex);

    try {
      final Response response =
          await http.post(url, body: json.encode(getSendRawTransaction));
      return sendRawTransactionResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> postWithdraw(
      Coin coin, String addressTo, double amount, bool isMax) async {
    final GetWithdraw getWithdraw = GetWithdraw(
      userpass: userpass,
      method: 'withdraw',
      coin: coin.abbr,
      to: addressTo,
      max: isMax,
    );
    if (!isMax) {
      getWithdraw.amount = amount;
    }

    print('sending: ' + amount.toString());
    print(getWithdrawToJson(getWithdraw));

    try {
      final Response response =
          await http.post(url, body: getWithdrawToJson(getWithdraw));
      print('response.body postWithdraw' + response.body.toString());
      return withdrawResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<ActiveCoin> activeCoin(Coin coin) async {
    print('activate coin :' + coin.abbr);
    final List<Server> servers = <Server>[];
    for (String url in coin.serverList) {
      servers.add(
          Server(url: url, protocol: 'TCP', disableCertVerification: false));
    }
    dynamic getActiveCoin;
    Response response;

    try {
      if (coin.swapContractAddress.isNotEmpty) {
        getActiveCoin = GetEnabledCoin(
            userpass: userpass,
            method: 'enable',
            coin: coin.abbr,
            txHistory: true,
            swapContractAddress: coin.swapContractAddress,
            urls: coin.serverList);
        response = await http
            .post(url, body: getEnabledCoinToJson(getActiveCoin))
            .timeout(const Duration(seconds: 60));
      } else {
        getActiveCoin = GetActiveCoin(
            userpass: userpass,
            method: 'electrum',
            coin: coin.abbr,
            txHistory: true,
            servers: servers);
        response = await http
            .post(url, body: getActiveCoinToJson(getActiveCoin))
            .timeout(const Duration(seconds: 60));
      }

      print('response Active Coin: ' + response.body.toString());

      if (activeCoinFromJson(response.body).result != null) {
        return activeCoinFromJson(response.body);
      } else {
        print(response.body);
        throw errorStringFromJson(response.body);
      }
    } on TimeoutException catch (_) {
      throw ErrorString(error: 'Timeout on ${coin.abbr}');
    } catch (e) {
      print('-------------------' + errorStringFromJson(response.body).error);
      print(response.body);
      throw errorStringFromJson(response.body);
    }
  }

  Future<TradeFee> getTradeFee(Coin coin) async {
    final GetTradeFee getTradeFee = GetTradeFee(
        userpass: userpass, method: 'get_trade_fee', coin: coin.abbr);

    try {
      final Response response =
          await http.post(url, body: getTradeFeeToJson(getTradeFee));
      return tradeFeeFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<ResultSuccess> getVersionMM2() async {
    final BaseService baseService =
        BaseService(userpass: userpass, method: 'version');

    try {
      final Response response =
          await http.post(url, body: baseServiceToJson(baseService));
      return resultSuccessFromJson(response.body);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
