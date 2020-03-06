import 'dart:convert';

import 'package:http/http.dart' show Response;
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/get_recover_funds_of_swap.dart';
import 'package:komodo_dex/model/recover_funds_of_swap.dart';
import 'package:komodo_dex/services/music_service.dart';

import '../model/active_coin.dart';
import '../model/balance.dart';
import '../model/base_service.dart';
import '../model/buy_response.dart';
import '../model/coin.dart';
import '../model/coin_to_kick_start.dart';
import '../model/disable_coin.dart';
import '../model/error_disable_coin_active_swap.dart';
import '../model/error_disable_coin_order_is_matched.dart';
import '../model/error_string.dart';
import '../model/get_active_coin.dart';
import '../model/get_balance.dart';
import '../model/get_buy.dart';
import '../model/get_cancel_order.dart';
import '../model/get_disable_coin.dart';
import '../model/get_enable_coin.dart';
import '../model/get_orderbook.dart';
import '../model/get_recent_swap.dart';
import '../model/get_send_raw_transaction.dart';
import '../model/get_setprice.dart';
import '../model/get_swap.dart';
import '../model/get_trade_fee.dart';
import '../model/get_tx_history.dart';
import '../model/get_withdraw.dart';
import '../model/orderbook.dart';
import '../model/orders.dart' hide Match;
import '../model/recent_swaps.dart';
import '../model/result.dart';
import '../model/send_raw_transaction_response.dart';
import '../model/setprice_response.dart';
import '../model/swap.dart';
import '../model/trade_fee.dart';
import '../model/transactions.dart';
import '../model/withdraw_response.dart';
import '../utils/log.dart';
import 'mm_service.dart';

class UserpassBody {
  UserpassBody({this.body, this.client});
  dynamic body;
  http.Client client;
}

// AG: Planning to get rid of `res` and turn `MM` into a const:
// 
//     const ApiProvider MM = const ApiProvider();
// 
// ignore: non_constant_identifier_names
ApiProvider MM = ApiProvider();

class ApiProvider {
  String url = 'http://localhost:7783';
  Response res;

  Response _saveRes(String method, Response res) {
    final String loggedBody = res.body.toString();
    String loggedLine = '$method $loggedBody';

    // getMyOrders and getRecentSwaps are invoked every two seconds during an active order or swap
    // and fully logging their response bodies every two seconds is an overkill,
    // though we still want to *mention* the invocations in the logs.
    final bool cut = musicService.recommendsPeriodicUpdates() &&
        (method == 'getMyOrders' || method == 'getRecentSwaps');
    if (cut && loggedLine.length > 77) {
      loggedLine = loggedLine.substring(0, 75) + '..';
    }

    Log.println('mm:76', loggedLine);
    this.res = res;
    return res;
  }

  ErrorString injectErrorString(dynamic value, String errorStr) {
    if (value is ErrorString) {
      if (value.error.contains(errorStr)) {
        value.error = errorStr;
        return value;
      }
    }
    return value;
  }

  // ErrorString removeLineFromMM2(ErrorString errorString) {
  //   if (errorString.error.lastIndexOf(']') != -1) {
  //     errorString.error = errorString.error.substring(errorString.error.lastIndexOf(']') + 1).trim();
  //   }
  //   return errorString;
  // }

  ErrorString _catchErrorString(String key, dynamic e, String message) {
    Log.println(key, e);
    return ErrorString(message);
  }

  Future<UserpassBody> _assertUserpass(http.Client client, dynamic body) async {
    body.userpass =
        MMService().userpass.isNotEmpty ? MMService().userpass : body.userpass;
    return UserpassBody(body: body, client: client);
  }

  Future<dynamic> getSwapStatus(
    http.Client client,
    GetSwap body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getSwapToJson(userBody.body))
              .then((Response r) => _saveRes('getSwapStatus', r))
              .then<dynamic>((Response res) => swapFromJson(res.body))
              .catchError((dynamic e) => errorStringFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getSwapStatus', e, 'Error on get swap status')));

  Future<dynamic> getOrderbook(
    http.Client client,
    GetOrderbook body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getOrderbookToJson(userBody.body))
              .then(
                  (Response r) => _saveRes('getOrderbook_api_providers:110', r))
              .then<dynamic>((Response res) => orderbookFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getOrderbook_api_providers:111',
                  e,
                  'Error on get orderbook')));

  Future<Balance> getBalance(GetBalance gb, {http.Client client}) async {
    // AG: HTTP handling is improved in this method.
    //     After using it for a while and seeing that it works as expected
    //     we should refactor the rest of the methods accordingly.

    client ??= MMService().client;
    try {
      final userBody = await _assertUserpass(client, gb);
      final r = await userBody.client
          .post(url, body: getBalanceToJson(userBody.body));
      if (r.body.isEmpty) throw ErrorString('HTTP ${r.statusCode} empty');
      if (r.statusCode != 200) {
        String emsg;
        try {
          // See if the body is a JSON error.
          emsg = ErrorString.fromJson(json.decode(r.body)).error;
        } catch (_notJson) {/**/}
        if (emsg.isEmpty) {
          // Treat the body as a potentially useful but untrusted error message.
          emsg = r.body
              .replaceAll(RegExp('[^a-zA-Z0-9, :\]\.-]+'), '.')
              .replaceFirstMapped(RegExp('^(.{0,99}).*'), (Match m) => m[1]);
        }
        throw ErrorString('HTTP ${r.statusCode}: $emsg');
      }
      _saveRes('getBalance', r);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = json.decode(r.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      return Balance.fromJson(jbody);
    } catch (e) {
      throw _catchErrorString(
          'getBalance', e, 'Error getting ${gb.coin} balance');
    }
  }

  Future<dynamic> postBuy(
    http.Client client,
    GetBuySell body,
  ) async =>
      await _assertUserpass(client, body)
          .then<dynamic>((UserpassBody userBody) {
        body.method = 'buy';
        return userBody.client
            .post(url, body: getBuyToJson(userBody.body))
            .then((Response r) => _saveRes('postBuy', r))
            .then<dynamic>((Response res) => buyResponseFromJson(res.body))
            .catchError((dynamic e) => errorStringFromJson(res.body).then(
                (ErrorString errorString) => injectErrorString(
                    errorString, 'All electrums are currently disconnected')))
            .catchError((dynamic e) =>
                _catchErrorString('postBuy', e, 'Error on post buy'));
      });

  Future<dynamic> postSell(
    http.Client client,
    GetBuySell body,
  ) async =>
      await _assertUserpass(client, body)
          .then<dynamic>((UserpassBody userBody) {
        body.method = 'sell';
        return userBody.client
            .post(url, body: getBuyToJson(userBody.body))
            .then((Response r) => _saveRes('postSell', r))
            .then<dynamic>((Response res) => buyResponseFromJson(res.body))
            .catchError((dynamic e) => errorStringFromJson(res.body))
            .catchError((dynamic e) =>
                _catchErrorString('postSell', e, 'Error on post sell'));
      });

  dynamic getBodyActiveCoin(Coin coin) {
    final List<Server> servers = coin.serverList
        .map((String url) =>
            Server(url: url, protocol: 'TCP', disableCertVerification: false))
        .toList();

    return coin.type == 'erc'
        ? getEnabledCoinToJson(GetEnabledCoin(
            userpass: MMService().userpass,
            coin: coin.abbr,
            txHistory: true,
            swapContractAddress: coin.swapContractAddress,
            urls: coin.serverList))
        : getActiveCoinToJson(GetActiveCoin(
            userpass: MMService().userpass,
            coin: coin.abbr,
            txHistory: true,
            servers: servers));
  }

  Future<dynamic> activeCoin(
    http.Client client,
    Coin coin,
  ) async =>
      await client
          .post(url, body: getBodyActiveCoin(coin))
          .then((Response r) => _saveRes('activeCoin', r))
          .then((Response res) => activeCoinFromJson(res.body))
          .then<dynamic>((ActiveCoin data) =>
              data.result.isEmpty ? errorStringFromJson(res.body) : data)
          .catchError((dynamic e) => errorStringFromJson(res.body))
          .catchError((dynamic e) => _catchErrorString(
              'activeCoin', e, 'Error on active ${coin.name}'))
          .timeout(const Duration(seconds: 60),
              onTimeout: () => ErrorString('Timeout on ${coin.abbr}'));

  Future<dynamic> postSetPrice(
    http.Client client,
    GetSetPrice body,
  ) async =>
      await _assertUserpass(client, body)
          .then<dynamic>((UserpassBody userBody) => userBody.client
              .post(url, body: getSetPriceToJson(userBody.body))
              .then((Response r) => _saveRes('postSetPrice', r))
              .then<dynamic>(
                  (Response res) => setPriceResponseFromJson(res.body))
              .catchError((dynamic e) => errorStringFromJson(res.body)))
          .catchError((dynamic e) =>
              _catchErrorString('postSetPrice', e, 'Error on set price'));

  Future<dynamic> getTransactions(
    http.Client client,
    GetTxHistory body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getTxHistoryToJson(userBody.body))
              .then((Response r) => _saveRes('getTransactions', r))
              .then<dynamic>((Response res) => transactionsFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getTransactions', e, 'Error on get transactions')));

  Future<dynamic> getRecentSwaps(
    http.Client client,
    GetRecentSwap body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getRecentSwapToJson(userBody.body))
              .then((Response r) => _saveRes('getRecentSwaps', r))
              .then<dynamic>((Response res) => recentSwapsFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getRecentSwaps', e, 'Error on get recent swaps')));

  Future<dynamic> getMyOrders(
    http.Client client,
    BaseService body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: baseServiceToJson(userBody.body))
              .then((Response r) => _saveRes('getMyOrders', r))
              .then<dynamic>((Response res) => ordersFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getMyOrders', e, 'Error on get my orders')));

  Future<dynamic> cancelOrder(
    http.Client client,
    GetCancelOrder body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getCancelOrderToJson(userBody.body))
              .then((Response r) => _saveRes('cancelOrder', r))
              .then((Response res) => resultSuccessFromJson(res.body))
              .then((ResultSuccess data) =>
                  data.result.isEmpty ? errorStringFromJson(res.body) : data)
              .catchError((dynamic e) => _catchErrorString(
                  'cancelOrder', e, 'Error on cancel order')));

  Future<dynamic> getCoinToKickStart(
    http.Client client,
    BaseService body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: baseServiceToJson(userBody.body))
              .then((Response r) => _saveRes('getCoinToKickStart', r))
              .then<dynamic>(
                  (Response res) => coinToKickStartFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getCoinToKickStart', e, 'Error on get coin to kick start')));

  Future<dynamic> postRawTransaction(
    http.Client client,
    GetSendRawTransaction body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody
              .client
              .post(url, body: getSendRawTransactionToJson(userBody.body))
              .then((Response r) => _saveRes('postRawTransaction', r))
              .then((Response res) =>
                  sendRawTransactionResponseFromJson(res.body))
              .then((SendRawTransactionResponse data) =>
                  data.txHash.isEmpty ? errorStringFromJson(res.body) : data)
              .catchError((dynamic e) => errorStringFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'postRawTransaction', e, 'Error on post raw transaction')));

  Future<dynamic> postWithdraw(
    http.Client client,
    GetWithdraw body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getWithdrawToJson(userBody.body))
              .then((Response r) => _saveRes('postWithdraw', r))
              .then<dynamic>(
                  (Response res) => withdrawResponseFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'postWithdraw', e, 'Error on post withdraw')));

  Future<dynamic> getTradeFee(
    http.Client client,
    GetTradeFee body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getTradeFeeToJson(userBody.body))
              .then((Response r) => _saveRes('getTradeFee', r))
              .then<dynamic>((Response res) => tradeFeeFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getTradeFee', e, 'Error on get tradeFee')));

  Future<dynamic> getVersionMM2(
    http.Client client,
    BaseService body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: baseServiceToJson(userBody.body))
              .then((Response r) => _saveRes('getVersionMM2', r))
              .then<dynamic>((Response res) => resultSuccessFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'getVersionMM2', e, 'Error on get version MM2')));

  Future<dynamic> disableCoin(
    http.Client client,
    GetDisableCoin body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getDisableCoinToJson(userBody.body))
              .then((Response r) => _saveRes('disableCoin', r))
              .then<dynamic>((Response res) => disableCoinFromJson(res.body))
              .catchError(
                  (dynamic _) => errorDisableCoinActiveSwapFromJson(res.body))
              .catchError((dynamic _) =>
                  errorDisableCoinOrderIsMatchedFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError((dynamic e) => _catchErrorString(
                  'disableCoin', e, 'Error on disable coin')));

  Future<dynamic> recoverFundsOfSwap(
    http.Client client,
    GetRecoverFundsOfSwap body,
  ) async =>
      await _assertUserpass(client, body).then<dynamic>((UserpassBody userBody) => userBody
          .client
          .post(url, body: getRecoverFundsOfSwapToJson(userBody.body))
          .then((Response r) => _saveRes('recoverFundsOfSwap', r))
          .then<dynamic>((Response res) => recoverFundsOfSwapFromJson(res.body))
          .catchError((dynamic _) => errorStringFromJson(res.body)
              .then((ErrorString errorString) => injectErrorString(
                  errorString, 'Maker payment is spent, swap is not recoverable'))
              .then((ErrorString errorString) => injectErrorString(errorString,
                  'Swap must be finished before recover funds attempt'))
              .then((ErrorString errorString) => injectErrorString(errorString, 'swap data is not found')))
          .catchError((dynamic e) => _catchErrorString('recoverFundsOfSwap', e, 'Error on recover funds of swap')));
}
