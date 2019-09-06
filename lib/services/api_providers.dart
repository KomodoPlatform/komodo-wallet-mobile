import 'package:http/http.dart' show Response;
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/base_service.dart';

import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/model/error_disable_coin_order_is_matched.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_cancel_order.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_recent_swap.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

class UserpassBody {
  UserpassBody({this.body, this.client});
  dynamic body;
  http.Client client;
}

class ApiProvider {
  String url = 'http://localhost:7783';
  Response res;
  String userpass;

  Response printResponse(Response res) {
    print(res.body);
    this.res = res;
    return res;
  }

  Future<UserpassBody> assertUserpass(http.Client client, dynamic body) async {
    body.userpass = MarketMakerService().userpass.isNotEmpty
        ? MarketMakerService().userpass
        : body.userpass;
    return UserpassBody(body: body, client: client);
  }

  Future<dynamic> getTransactions(
          http.Client client, GetTxHistory body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getTxHistoryToJson(userBody.body))
              .then(printResponse)
              .then<dynamic>((Response res) => transactionsFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<RecentSwaps> getRecentSwaps(
          http.Client client, GetRecentSwap body) async =>
      await assertUserpass(client, body).then((UserpassBody userBody) =>
          userBody.client
              .post(url, body: getRecentSwapToJson(userBody.body))
              .then(printResponse)
              .then((Response res) => recentSwapsFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<Orders> getMyOrders(http.Client client, BaseService body) async =>
      await assertUserpass(client, body).then((UserpassBody userBody) =>
          userBody.client
              .post(url, body: baseServiceToJson(userBody.body))
              .then(printResponse)
              .then((Response res) => ordersFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<dynamic> cancelOrder(http.Client client, GetCancelOrder body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getCancelOrderToJson(userBody.body))
              .then(printResponse)
              .then((Response res) => resultSuccessFromJson(res.body))
              .then((ResultSuccess data) =>
                  data.result.isEmpty ? errorStringFromJson(res.body) : data)
              .catchError((dynamic e) => print(e)));

  Future<CoinToKickStart> getCoinToKickStart(
          http.Client client, BaseService body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: baseServiceToJson(userBody.body))
              .then(printResponse)
              .then((Response res) => coinToKickStartFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<dynamic> postRawTransaction(
          http.Client client, GetSendRawTransaction body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getSendRawTransactionToJson(userBody.body))
              .then(printResponse)
              .then((Response res) =>
                  sendRawTransactionResponseFromJson(res.body))
              .then((SendRawTransactionResponse data) =>
                  data.txHash.isEmpty ? errorStringFromJson(res.body) : data)
              .catchError((dynamic e) => errorStringFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<dynamic> postWithdraw(http.Client client, GetWithdraw body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getWithdrawToJson(userBody.body))
              .then(printResponse)
              .then<dynamic>(
                  (Response res) => withdrawResponseFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<TradeFee> getTradeFee(http.Client client, GetTradeFee body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getTradeFeeToJson(userBody.body))
              .then(printResponse)
              .then((Response res) => tradeFeeFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<ResultSuccess> getVersionMM2(
          http.Client client, BaseService body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: baseServiceToJson(userBody.body))
              .then(printResponse)
              .then((Response res) => resultSuccessFromJson(res.body))
              .catchError((dynamic e) => print(e)));

  Future<dynamic> disableCoin(http.Client client, GetDisableCoin body) async =>
      await assertUserpass(client, body).then<dynamic>(
          (UserpassBody userBody) => userBody.client
              .post(url, body: getDisableCoinToJson(userBody.body))
              .then(printResponse)
              .then<dynamic>((Response res) => disableCoinFromJson(res.body))
              .catchError(
                  (dynamic _) => errorDisableCoinActiveSwapFromJson(res.body))
              .catchError((dynamic _) =>
                  errorDisableCoinOrderIsMatchedFromJson(res.body))
              .catchError((dynamic _) => errorStringFromJson(res.body))
              .catchError(
                  (dynamic _) => throw Exception('Failed to disable coin')));
}
