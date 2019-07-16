import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show File, Platform, Process, ProcessResult;

import 'package:crypto/crypto.dart';
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
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:path_provider/path_provider.dart';

MarketMakerService mm2 = MarketMakerService();

class MarketMakerService {
  MarketMakerService() {
    if (Platform.isAndroid) {
      url = 'http://localhost:7783';
    } else if (Platform.isIOS) {
      url = 'http://localhost:7783';
    }
  }

  List<dynamic> balances =  <dynamic>[];
  Process mm2Process;
  List<Coin> coins = <Coin>[];
  bool ismm2Running = false;
  String url = 'http://10.0.2.2:7783';
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
      final ProcessResult checkmm2 = await Process.run('ls', <String>['${filesPath}mm2']);

      if (checkmm2.stdout.toString().trim() != '${filesPath}mm2') {
        final ByteData resultmm2 = await rootBundle.load('assets/mm2');
        await writeData(resultmm2.buffer.asUint8List());
        await Process.run('chmod', <String>['777', '${filesPath}mm2']);
      }
    }
  }

  Future<void> runBin() async {
    final String passphrase = await  EncryptionTool().read('passphrase');

    final List<int> bytes = utf8.encode(passphrase); // data being hashed
    userpass = sha256.convert(bytes).toString();

    final String coinsInitParam = coinInitToJson(await readJsonCoinInit());

    final String startParam =
        '{\"gui\":\"atomicDEX\",\"netid\":9999,\"client\":1,\"userhome\":\"$filesPath\",\"passphrase\":\"$passphrase\",\"rpc_password\":\"$userpass\",\"coins\":$coinsInitParam,\"dbdir\":\"$filesPath\"}';

    final File file =  File('$filesPath/log.txt');

    sink = file.openWrite();

    if (Platform.isAndroid) {
      await stopmm2();
      mm2Process = await Process.start('./mm2', <String>[startParam],
          workingDirectory: '$filesPath');

      mm2Process.stdout.listen((List<int> onData) {
        final String logMm2 = utf8.decoder.convert(onData).trim();

        _onLogsmm2(logMm2);
        if (logMm2.contains('DEX stats API enabled at')) {
          print('DEX stats API enabled at');

          ismm2Running = true;

          _initCoinsAndLoad();
        }
      });
    } else if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
      await platformmm2
          .invokeMethod<dynamic>('start', <String, String>{'params': startParam}); //start mm2

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
      return  <CoinInit>[];
    }
  }

  Future<void> _initCoinsAndLoad() async {
    await coinsBloc.activateCoinKickStart();

    coinsBloc.addMultiCoins(await coinsBloc.readJsonCoin()).then((_) {
      print('ALL COINS ACTIVATES');
      coinsBloc.loadCoin().then((_) {
        print('LOADCOIN FINISHED');
        // swapHistoryBloc.updateSwaps(50, null);
        // coinsBloc.startCheckBalance();
      });
    });
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

  Future<dynamic> stopmm2() async {
    // int res = await checkStatusmm2();
    // print('STATUS RES' + res.toString());
    ismm2Running = false;
    // if (res == 3) {
    try {
      final BaseService baseService =
           BaseService(userpass: userpass, method: 'stop');
      final Response response =
          await http.post(url, body: baseServiceToJson(baseService));
      return baseServiceFromJson(response.body);
    } catch (e) {
      return null;
    }
    // }
  }

  Future<List<Coin>> loadJsonCoins(String loadFile) async {
    final String jsonString = loadFile;
    final Iterable<dynamic> l = json.decode(jsonString);
    final List<Coin> coins = l.map((dynamic model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<Coin>> loadJsonCoinsDefault() async {
    final String jsonString = await loadDefaultActivateCoin();
    final Iterable<dynamic> l = json.decode(jsonString);
    final List<Coin> coins = l.map((dynamic model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<dynamic>> getAllBalances(bool forceUpdate) async {
    final List<Coin> coins = await coinsBloc.readJsonCoin();

    if (balances.isEmpty ||
        forceUpdate ||
        coins.length != balances.length) {
      List<dynamic> balances =  <dynamic>[];
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
    final GetSwap getSwap =  GetSwap(
        userpass: userpass,
        method: 'my_swap_status',
        params: Params(uuid: uuid));

    final Response response = await http.post(url, body: getSwapToJson(getSwap));

    try {
      return swapFromJson(response.body);
    } catch (e) {
      return errorStringFromJson(response.body);
    }
  }

  Future<Orderbook> getOrderbook(Coin coinBase, Coin coinRel) async {
    final GetOrderbook getOrderbook =  GetOrderbook(
        userpass: userpass,
        method: 'orderbook',
        base: coinBase.abbr,
        rel: coinRel.abbr);
    final Response response = await http.post(url, body: json.encode(getOrderbook));
    print(response.body.toString());
    return orderbookFromJson(response.body);
  }

  Future<dynamic> getBalance(Coin coin) async {
    final GetBalance getBalance =  GetBalance(
        userpass: userpass, method: 'my_balance', coin: coin.abbr);
    final Response response = await http.post(url, body: json.encode(getBalance));

    print('getBalance' + response.body.toString());

    try {
      return balanceFromJson(response.body);
    } catch (e) {
      return errorStringFromJson(response.body);
    }
  }

  Future<dynamic> postBuy(
      Coin base, Coin rel, double volume, double price) async {
    print('postBuy>>>>>>>>>>>>>>>>> SWAPPARAM: base: ' +
        base.abbr +
        ' rel: ' +
        rel.abbr.toString() +
        ' relvol: ' +
        volume.toString() +
        ' price: ' +
        price.toString());
    final GetBuy getBuy =  GetBuy(
        userpass: userpass,
        method: 'buy',
        base: base.abbr,
        rel: rel.abbr,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));
    print(json.encode(getBuy));
    final Response response = await http.post(url, body: json.encode(getBuy));

    print(response.body.toString());
    final BuyResponse buyResponse = buyResponseFromJson(response.body);
    if (buyResponse != null && buyResponse.result != null) {
      return buyResponse;
    } else {
      throw errorStringFromJson(response.body);
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
    final GetBuy getBuy =  GetBuy(
        userpass: userpass,
        method: 'sell',
        base: base.abbr,
        rel: rel.abbr,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));
    print(json.encode(getBuy));
    final Response response = await http.post(url, body: json.encode(getBuy));

    print(response.body.toString());
    try {
      return buyResponseFromJson(response.body);
    } catch (e) {
      return errorStringFromJson(response.body);
    }
  }

  Future<dynamic> postSetPrice(Coin base, Coin rel, double volume, double price,
      bool cancelPrevious, bool max) async {
    final GetSetPrice getSetPrice =  GetSetPrice(
        userpass: userpass,
        method: 'setprice',
        base: base.abbr,
        rel: rel.abbr,
        cancelPrevious: cancelPrevious,
        max: max,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));

    print('postSetPrice' + getSetPriceToJson(getSetPrice));
    final Response response = await http.post(url, body: getSetPriceToJson(getSetPrice));

    print(response.body.toString());
    final SetPriceResponse setPriceResponse = setPriceResponseFromJson(response.body);
    if (setPriceResponse != null) {
      return setPriceResponse;
    } else {
      throw errorStringFromJson(response.body);
    }
  }

  Future<dynamic> getTransactions(Coin coin, int limit, String fromId) async {
    final GetTxHistory getTxHistory =  GetTxHistory(
        userpass: userpass,
        method: 'my_tx_history',
        coin: coin.abbr,
        limit: limit,
        fromId: fromId);
    print(json.encode(getTxHistory));
    print(url);
    final Response response = await http.post(url, body: json.encode(getTxHistory));
    print('RESULT: ' + response.body.toString());
    try {
      return transactionsFromJson(response.body);
    } catch (e) {
      return errorCodeFromJson(response.body);
    }
  }

  Future<RecentSwaps> getRecentSwaps(int limit, String fromUuid) async {
    final GetRecentSwap getRecentSwap =  GetRecentSwap(
        userpass: userpass,
        method: 'my_recent_swaps',
        limit: limit,
        fromUuid: fromUuid);

    final Response response =
        await http.post(url, body: getRecentSwapToJson(getRecentSwap));
    print(response.body.toString());
    return recentSwapsFromJson(response.body);
  }

  Future<Orders> getMyOrders() async {
    final  GetRecentSwap getRecentSwap =
         GetRecentSwap(userpass: userpass, method: 'my_orders');

    final Response response =
        await http.post(url, body: getRecentSwapToJson(getRecentSwap));
    print('my_orders' + response.body.toString());
    return ordersFromJson(response.body);
  }

  Future<ResultSuccess> cancelOrder(String uuid) async {
    final GetCancelOrder getCancelOrder =  GetCancelOrder(
        userpass: userpass, method: 'cancel_order', uuid: uuid);

    final Response response =
        await http.post(url, body: getCancelOrderToJson(getCancelOrder));
    print('cancel_order' + response.body.toString());
    return resultSuccessFromJson(response.body);
  }

  Future<CoinToKickStart> getCoinToKickStart() async {
    final GetRecentSwap getRecentSwap =  GetRecentSwap(
        userpass: userpass, method: 'coins_needed_for_kick_start');

    final Response response =
        await http.post(url, body: getRecentSwapToJson(getRecentSwap));
    print('coins_needed_for_kick_start' + response.body.toString());
    return coinToKickStartFromJson(response.body);
  }

  Future<dynamic> postRawTransaction(Coin coin, String txHex) async {
    final GetSendRawTransaction getSendRawTransaction =  GetSendRawTransaction(
        userpass: userpass,
        method: 'send_raw_transaction',
        coin: coin.abbr,
        txHex: txHex);

    final Response response =
        await http.post(url, body: json.encode(getSendRawTransaction));
    try {
      return sendRawTransactionResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> postWithdraw(
      Coin coin, String addressTo, double amount, bool isMax) async {
    final GetWithdraw getWithdraw =  GetWithdraw(
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
    final Response response = await http.post(url, body: getWithdrawToJson(getWithdraw));
    print('response.body postWithdraw' + response.body.toString());
    try {
      return withdrawResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<ActiveCoin> activeCoin(Coin coin) async {
    print('activate coin :' + coin.abbr);
    final List<Server> servers =  <Server>[];
    for (String url in coin.serverList) {
            servers.add(
          Server(url: url, protocol: 'TCP', disableCertVerification: false));
    }
    dynamic getActiveCoin;
    Response response;

    try {
      if (coin.swapContractAddress != null) {
        getActiveCoin =  GetEnabledCoin(
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
        getActiveCoin =  GetActiveCoin(
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
      throw  ErrorString(error: 'Timeout on ${coin.abbr}');
    } catch (e) {
      print('-------------------' + errorStringFromJson(response.body).error);
      print(response.body);
      throw errorStringFromJson(response.body);
    }
  }
}
