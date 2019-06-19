import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show File, Platform, Process, ProcessResult;

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show ByteData, MethodChannel, rootBundle;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:http/http.dart' as http;
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_active_coin.dart';
import 'package:komodo_dex/model/get_balance.dart';
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
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/getprice_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final mm2 = MarketMakerService();

class MarketMakerService {
  List<dynamic> balances = new List<dynamic>();
  Process mm2Process = null;
  List<Coin> coins = List<Coin>();
  bool ismm2Running = false;
  String url = 'http://10.0.2.2:7783';
  String userpass = "";
  Stream<List<int>> streamSubscriptionStdout;
  String pubkey = "";
  String filesPath = "";
  var sink;
  static const platformmm2 = const MethodChannel('mm2');

  MarketMakerService() {
    if (Platform.isAndroid) {
      url = 'http://localhost:7783';
    } else if (Platform.isIOS) {
      url = 'http://localhost:7783';
    }
  }

  Future<void> initMarketMaker() async {
    final directory = await getApplicationDocumentsDirectory();
    filesPath = directory.path + "/";

    if (Platform.isAndroid) {
      ProcessResult checkmm2 = await Process.run('ls', ['${filesPath}mm2']);

      if (checkmm2.stdout.toString().trim() != "${filesPath}mm2") {
        ByteData resultmm2 = await rootBundle.load("assets/mm2");
        await writeData(resultmm2.buffer.asUint8List());
        await Process.run('chmod', ['777', '${filesPath}mm2']);
      }
    }
  }

  Future<void> runBin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String passphrase = prefs.getString('passphrase');

    var bytes = utf8.encode(passphrase); // data being hashed
    userpass = sha256.convert(bytes).toString();

    String coins =
        '[{\"coin\":\"QTUM\",\"name\":\"QTUM\",\"pubtype\":58,\"p2shtype\":50,\"txfee\":400000,\"wiftype\":128,\"mm2\":1},{\"coin\":\"DGB\",\"name\":\"DGB\",\"pubtype\":30,\"txfee\":100000,\"p2shtype\":5,\"wiftype\":128,\"mm2\":1},{\"coin\":\"BTC\",\"name\":\"Bitcoin\",\"pubtype\":0,\"p2shtype\":5,\"wiftype\":128,\"mm2\":1},{\"coin\":\"KMD\",\"asset\":\"KMD\",\"mm2\":1,\"txfee\":10000},{\"coin\":\"RICK\",\"asset\":\"RICK\",\"rpcport\":28223,\"mm2\":1,\"txfee\":10000},{\"coin\":\"MORTY\",\"asset\":\"MORTY\",\"rpcport\":63812,\"mm2\":1,\"txfee\":10000},{\"coin\":\"ETH\",\"name\":\"ethereum\",\"etomic\":\"0x0000000000000000000000000000000000000000\",\"rpcport\":80,\"mm2\":1},{\"coin\":\"USDT\",\"name\":\"Tether\",\"etomic\":\"0xdac17f958d2ee523a2206206994597c13d831ec7\",\"rpcport\":80,\"mm2\":1},{\"coin\":\"THETA\",\"name\":\"Theta\",\"etomic\":\"0x3883f5e181fccaF8410FA61e12b59BAd963fb645\",\"rpcport\":80},{\"coin\":\"BAT\",\"name\":\"BAT\",\"etomic\":\"0x0d8775f648430679a709e98d2b0cb6250d2887ef\",\"rpcport\":80},{\"coin\":\"EOS\",\"name\":\"EOS\",\"etomic\":\"0x86fa049857e0209aa7d9e616f7eb3b3b78ecfdb0\",\"rpcport\":80}]';

    String startParam =
        '{\"gui\":\"atomicDEX\",\"netid\":9999,\"client\":1,\"userhome\":\"${filesPath}\",\"passphrase\":\"$passphrase\",\"rpc_password\":\"$userpass\",\"coins\":$coins,\"dbdir\":\"$filesPath\"}';

    if (Platform.isAndroid) {
      await stopmm2();

      mm2Process = await Process.start('./mm2', [startParam],
          workingDirectory: '${filesPath}');

      var file = new File('${filesPath}/log.txt');
      sink = file.openWrite();

      mm2Process.stdout.listen((onData) {
        String logMm2 = utf8.decoder.convert(onData).trim();
        sink.write(logMm2);
        print("mm2: " + logMm2);

        if (logMm2.contains("Entering the taker_swap_loop") ||
            logMm2.contains("Received 'negotiation") ||
            logMm2.contains("Got maker payment") ||
            logMm2.contains("Sending 'taker-fee") ||
            logMm2.contains("Sending 'taker-payment") ||
            logMm2.contains("Finished")) {
          print("Update swaps from log");
          Future.delayed(const Duration(seconds: 1), () {
            swapHistoryBloc.updateSwaps(10, null);
          });
        }
        if (logMm2.contains("DEX stats API enabled at")) {
          print("DEX stats API enabled at");

          ismm2Running = true;

          _initCoinsAndLoad();
        }
      });
    } else if (Platform.isIOS) {
      await stopmm2();
      await platformmm2
          .invokeMethod('start', {'params': startParam}); //start mm2

      // check when mm2 is ready then load coins
      var timerTmp = DateTime.now().millisecondsSinceEpoch;
      Timer.periodic(Duration(seconds: 2), (_) {
        var t1 = timerTmp + 20000;
        var t2 = DateTime.now().millisecondsSinceEpoch;
        if (t1 <= t2) {
          _.cancel();
        }

        checkStatusmm2().then((onValue) {
          print("STATUS MM2: " + onValue.toString());
          if (onValue == 3) {
            ismm2Running = true;
            _.cancel();
            print("CANCEL TIMER");
            _initCoinsAndLoad();
          }
        });
      });
    }
  }

  _initCoinsAndLoad() async {
    await coinsBloc.activateCoinKickStart();

    coinsBloc.addMultiCoins(await coinsBloc.readJsonCoin(), false).then((onValue) {
      print("ALL COINS ACTIVATES");
      coinsBloc.loadCoin(true).then((data) {
        print("LOADCOIN FINISHED");
        swapHistoryBloc.updateSwaps(10, null);
        coinsBloc.startCheckBalance();
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
    final file = await _localFile;
    return file.writeAsBytes(data);
  }

  Future<dynamic> stopmm2() async {
    // int res = await checkStatusmm2();
    // print("STATUS RES" + res.toString());
    ismm2Running = false;
    // if (res == 3) {
    try {
      BaseService baseService =
          new BaseService(userpass: userpass, method: "stop");
      final response =
          await http.post(url, body: baseServiceToJson(baseService));
      print(response.body.toString());
      return baseServiceFromJson(response.body);
    } catch (e) {
      return null;
    }
    // }
  }

  Future<List<Coin>> loadJsonCoins(String loadFile) async {
    String jsonString = loadFile;
    Iterable l = json.decode(jsonString);
    List<Coin> coins = l.map((model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<Coin>> loadJsonCoinsDefault() async {
    String jsonString = await loadDefaultActivateCoin();
    Iterable l = json.decode(jsonString);
    List<Coin> coins = l.map((model) => Coin.fromJson(model)).toList();
    return coins;
  }

  Future<List<dynamic>> getAllBalances(bool forceUpdate) async {
    List<Coin> coins = await coinsBloc.readJsonCoin();

    
    if (this.balances.isEmpty ||
        forceUpdate ||
        coins.length != this.balances.length) {
      List<dynamic> balances = new List<dynamic>();
      List<Future<dynamic>> futureBalances = new List<Future<dynamic>>();

      for (var coin in coins) {
        futureBalances.add(getBalance(coin));
      }
      balances = await Future.wait(futureBalances);

      this.balances = balances;
      return this.balances;
    } else {
      return this.balances;
    }
  }

  Future<String> loadElectrumServersAsset() async {
    return await rootBundle.loadString('assets/coins_config.json');
  }

  Future<String> loadDefaultActivateCoin() async {
    return await rootBundle.loadString('assets/coins_activate_default.json');
  }

  Future<dynamic> getSwapStatus(String uuid) async {
    GetSwap getSwap = new GetSwap(
        userpass: userpass,
        method: 'my_swap_status',
        params: Params(uuid: uuid));

    final response = await http.post(url, body: getSwapToJson(getSwap));

    try {
      return swapFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<Orderbook> getOrderbook(Coin coinBase, Coin coinRel) async {
    GetOrderbook getOrderbook = new GetOrderbook(
        userpass: userpass,
        method: 'orderbook',
        base: coinBase.abbr,
        rel: coinRel.abbr);
    final response = await http.post(url, body: json.encode(getOrderbook));
    print(response.body.toString());
    return orderbookFromJson(response.body);
  }

  Future<dynamic> getBalance(Coin coin) async {
    GetBalance getBalance = new GetBalance(
        userpass: userpass, method: "my_balance", coin: coin.abbr);
    final response = await http.post(url, body: json.encode(getBalance));

    print("getBalance" + response.body.toString());

    try {
      return balanceFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<dynamic> postBuy(
      Coin base, Coin rel, double volume, double price) async {
    print(">>>>>>>>>>>>>>>>> SWAPPARAM: base: " +
        base.abbr +
        " rel: " +
        rel.abbr.toString() +
        " relvol: " +
        volume.toString() +
        " price: " +
        price.toString());
    GetBuy getBuy = new GetBuy(
        userpass: userpass,
        method: "buy",
        base: base.abbr,
        rel: rel.abbr,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));
    print(json.encode(getBuy));
    final response = await http.post(url, body: json.encode(getBuy));

    print(response.body.toString());
    try {
      return buyResponseFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<dynamic> postSell(
      Coin base, Coin rel, double volume, double price) async {
    print("SWAPPARAM: base: " +
        base.abbr +
        " rel: " +
        rel.abbr.toString() +
        " relvol: " +
        volume.toString() +
        " price: " +
        price.toString());
    GetBuy getBuy = new GetBuy(
        userpass: userpass,
        method: "sell",
        base: base.abbr,
        rel: rel.abbr,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));
    print(json.encode(getBuy));
    final response = await http.post(url, body: json.encode(getBuy));

    print(response.body.toString());
    try {
      return buyResponseFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<dynamic> postSetPrice(
      Coin base, Coin rel, double volume, double price, bool cancelPrevious, bool max) async {
    GetSetPrice getSetPrice = new GetSetPrice(
        userpass: userpass,
        method: "setprice",
        base: base.abbr,
        rel: rel.abbr,
        cancelPrevious: cancelPrevious,
        max: max,
        volume: volume.toStringAsFixed(8),
        price: price.toStringAsFixed(8));

    print(getSetPriceToJson(getSetPrice));
    final response = await http.post(url, body: getSetPriceToJson(getSetPrice));

    print(response.body.toString());
    try {
      return setPriceResponseFromJson(response.body);
    } catch (e) {
      return errorFromJson(response.body);
    }
  }

  Future<Transactions> getTransactions(
      Coin coin, int limit, String fromId) async {
    GetTxHistory getTxHistory = new GetTxHistory(
        userpass: userpass,
        method: "my_tx_history",
        coin: coin.abbr,
        limit: limit,
        fromId: fromId);
    print(json.encode(getTxHistory));
    print(url);
    final response = await http.post(url, body: json.encode(getTxHistory));
    print("RESULT: " + response.body.toString());
    return transactionsFromJson(response.body);
  }

  Future<RecentSwaps> getRecentSwaps(int limit, String fromUuid) async {
    GetRecentSwap getRecentSwap = new GetRecentSwap(
        userpass: userpass,
        method: "my_recent_swaps",
        limit: limit,
        fromUuid: fromUuid);

    final response =
        await http.post(url, body: getRecentSwapToJson(getRecentSwap));
    print(response.body.toString());
    return recentSwapsFromJson(response.body);
  }

  Future<Orders> getMyOrders() async {
    GetRecentSwap getRecentSwap = new GetRecentSwap(
        userpass: userpass,
        method: "my_orders");

    final response =
        await http.post(url, body: getRecentSwapToJson(getRecentSwap));
    print("my_orders" + response.body.toString());
    return ordersFromJson(response.body);
  }

  Future<ResultSuccess> cancelOrder(String uuid) async {
    GetCancelOrder getCancelOrder = new GetCancelOrder(
        userpass: userpass,
        method: "cancel_order",
        uuid: uuid);

    final response =
        await http.post(url, body: getCancelOrderToJson(getCancelOrder));
    print("cancel_order" + response.body.toString());
    return resultFromJson(response.body);
  }

  Future<CoinToKickStart> getCoinToKickStart() async {
    GetRecentSwap getRecentSwap = new GetRecentSwap(
        userpass: userpass,
        method: "coins_needed_for_kick_start");

    final response =
        await http.post(url, body: getRecentSwapToJson(getRecentSwap));
    print("coins_needed_for_kick_start" + response.body.toString());
    return coinToKickStartFromJson(response.body);
  }

  Future<dynamic> postRawTransaction(Coin coin, String txHex) async {
    GetSendRawTransaction getSendRawTransaction = new GetSendRawTransaction(
        userpass: userpass,
        method: 'send_raw_transaction',
        coin: coin.abbr,
        txHex: txHex);

    final response =
        await http.post(url, body: json.encode(getSendRawTransaction));
    try {
      return sendRawTransactionResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> postWithdraw(
      Coin coin, String addressTo, double amount, bool isMax) async {
    GetWithdraw getWithdraw = new GetWithdraw(
      userpass: userpass,
      method: "withdraw",
      coin: coin.abbr,
      to: addressTo,
      max: isMax,
    );
    if (!isMax) {
      getWithdraw.amount = amount;
    }

    print("sending: " + amount.toString());
    print(getWithdrawToJson(getWithdraw));
    final response = await http.post(url, body: getWithdrawToJson(getWithdraw));
    print("response.body postWithdraw" + response.body.toString());
    try {
      return withdrawResponseFromJson(response.body);
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> activeCoin(Coin coin) async {
    print("activate coin :" + coin.abbr);
    GetActiveCoin getActiveCoin;
    if (coin.swap_contract_address != null) {
      getActiveCoin = new GetActiveCoin(
          userpass: userpass,
          method: "enable",
          coin: coin.abbr,
          tx_history: true,
          swap_contract_address: coin.swap_contract_address,
          urls: coin.serverList);
    } else {
      getActiveCoin = new GetActiveCoin(
          userpass: userpass,
          method: "electrum",
          coin: coin.abbr,
          tx_history: true,
          urls: coin.serverList);
    }

    final response =
        await http.post(url, body: getActiveCoinToJson(getActiveCoin));
    print("response Active Coin: " + response.body.toString());
    try {
      return activeCoinFromJson(response.body);
    } catch (e) {
      print(errorFromJson(response.body));
      return errorFromJson(response.body);
    }
  }
}
