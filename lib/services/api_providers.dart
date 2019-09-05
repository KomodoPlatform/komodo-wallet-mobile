import 'package:http/http.dart' show Response;
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/base_service.dart';

import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/model/error_disable_coin_order_is_matched.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/withdraw_response.dart';

class ApiProvider {
  String url = 'http://localhost:7783';
  Response res;

  Response printResponse(Response res) {
    print(res.body);
    this.res = res;
    return res;
  }

  Future<dynamic> postWithdraw(http.Client client, GetWithdraw body) async =>
      await client
          .post(url, body: getWithdrawToJson(body))
          .then(printResponse)
          .then<dynamic>((Response res) => withdrawResponseFromJson(res.body))
          .catchError((dynamic onError) => errorStringFromJson(res.body))
          .catchError((dynamic e) => print(e));

  Future<TradeFee> getTradeFee(
          http.Client client, Coin coin, GetTradeFee body) async =>
      await client
          .post(url, body: getTradeFeeToJson(body))
          .then(printResponse)
          .then((Response res) => tradeFeeFromJson(res.body))
          .catchError((dynamic e) => print(e));

  Future<ResultSuccess> getVersionMM2(
          http.Client client, BaseService body) async =>
      await client
          .post(url, body: baseServiceToJson(body))
          .then(printResponse)
          .then((Response res) => resultSuccessFromJson(res.body))
          .catchError((dynamic e) => print(e));

  Future<dynamic> disableCoin(
          http.Client client, Coin coin, GetDisableCoin body) async =>
      await client
          .post(url, body: getDisableCoinToJson(body))
          .then(printResponse)
          .then<dynamic>((Response res) => disableCoinFromJson(res.body))
          .catchError(
              (dynamic e) => errorDisableCoinActiveSwapFromJson(res.body))
          .catchError(
              (dynamic e) => errorDisableCoinOrderIsMatchedFromJson(res.body))
          .catchError((dynamic e) => errorStringFromJson(res.body))
          .catchError((dynamic e) => throw Exception('Failed to disable coin'));
}
