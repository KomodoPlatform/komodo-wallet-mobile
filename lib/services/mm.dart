import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' show Response;
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/get_import_swaps.dart';
import 'package:komodo_dex/model/get_min_trading_volume.dart';
import 'package:komodo_dex/model/import_swaps.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/get_convert_address.dart';
import 'package:komodo_dex/model/get_enabled_coins.dart';
import 'package:komodo_dex/model/get_max_taker_volume.dart';
import 'package:komodo_dex/model/get_priv_key.dart';
import 'package:komodo_dex/model/get_recover_funds_of_swap.dart';
import 'package:komodo_dex/model/get_rewards_info.dart';
import 'package:komodo_dex/model/get_trade_preimage.dart';
import 'package:komodo_dex/model/get_validate_address.dart';
import 'package:komodo_dex/model/priv_key.dart';
import 'package:komodo_dex/model/recover_funds_of_swap.dart';
import 'package:komodo_dex/model/rewards_provider.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/model/version_mm2.dart';
import 'package:komodo_dex/services/music_service.dart';
import 'package:komodo_dex/utils/utils.dart';

import '../model/active_coin.dart';
import '../model/balance.dart';
import '../model/base_service.dart';
import '../model/buy_response.dart';
import '../model/coin.dart';
import '../model/coin_to_kick_start.dart';
import '../model/disable_coin.dart';
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
    final bool cut = musicService.recommendsPeriodicUpdates &&
        (method == 'getMyOrders' || method == 'getRecentSwaps');
    if (cut && loggedLine.length > 77) {
      loggedLine = loggedLine.substring(0, 75) + '..';
    }

    Log.println('mm:74', loggedLine);
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
    body.userpass = mmSe.userpass.isNotEmpty ? mmSe.userpass : body.userpass;
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
                  .then((Response r) =>
                      _saveRes('getOrderbook_api_providers:110', r))
                  .then<dynamic>((Response res) {
                _assert200(res);
                return orderbookFromJson(res.body);
              }).catchError((dynamic e) => _catchErrorString(
                      'getOrderbook_api_providers:111',
                      e,
                      'Error on get orderbook')));

  void _assert200(Response r) {
    if (r.body.isEmpty) throw ErrorString('HTTP ${r.statusCode} empty');
    if (r.statusCode != 200) {
      String emsg;
      try {
        // See if the body is a JSON error.
        emsg = ErrorString.fromJson(json.decode(r.body)).error;
      } catch (_notJson) {/**/}
      if (emsg == null || emsg.isEmpty) {
        // Treat the body as a potentially useful but untrusted error message.
        emsg = r.body
            .replaceAll(RegExp('[^a-zA-Z0-9, :\]\.-]+'), '.')
            .replaceFirstMapped(RegExp('^(.{0,99}).*'), (Match m) => m[1]);
      }
      throw ErrorString('HTTP ${r.statusCode}: $emsg');
    }
  }

  Future<Balance> getBalance(GetBalance gb, {http.Client client}) async {
    // AG: HTTP handling is improved in this method.
    //     After using it for a while and seeing that it works as expected
    //     we should refactor the rest of the methods accordingly.

    client ??= mmSe.client;
    try {
      final userBody = await _assertUserpass(client, gb);
      final r = await userBody.client
          .post(url, body: getBalanceToJson(userBody.body));
      _assert200(r);
      _saveRes('getBalance', r);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = json.decode(r.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      final Balance balance = Balance.fromJson(jbody);
      balance.camouflageIfNeeded();

      return balance;
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

  Future<void> simPanic({http.Client client}) async {
    client ??= mmSe.client;
    final req = <String, dynamic>{
      'method': 'sim_panic',
      'userpass': mmSe.userpass,
      'mode': 'simple'
    };
    final r = await client.post(url, body: json.encode(req));
    _assert200(r);
    final dynamic jbody = json.decode(r.body);
    final err = ErrorString.fromJson(jbody);
    if (err.error.isNotEmpty) throw removeLineFromMM2(err);
  }

  String enableCoinImpl(Coin coin) {
    final List<Server> servers = coin.serverList
        .map((String url) => Server(
            url: url,
            protocol: coin.proto == null ? 'TCP' : coin.proto.toUpperCase(),
            disableCertVerification: false))
        .toList();

    if (coin.type == 'erc')
      return json.encode(MmEnable(
              userpass: mmSe.userpass,
              coin: coin.abbr,
              txHistory: true,
              swapContractAddress: coin.swapContractAddress,
              urls: coin.serverList)
          .toJson());

    // https://developers.atomicdex.io/basic-docs/atomicdex/atomicdex-api.html#electrum
    final electrum = <String, dynamic>{
      'method': 'electrum',
      'userpass': mmSe.userpass,
      'coin': coin.abbr,
      'servers': List<dynamic>.from(servers.map<dynamic>((se) => se.toJson())),
      'mm2': coin.mm2,
      'tx_history': true,
      'required_confirmations': coin.requiredConfirmations,
      if (coin.matureConfirmations != null)
        'mature_confirmations': coin.matureConfirmations,
      'requires_notarization': coin.requiresNotarization ?? false,
      'address_format': coin.addressFormat,
      if (coin.swapContractAddress.isNotEmpty)
        'swap_contract_address': coin.swapContractAddress
    };
    final js = json.encode(electrum);
    Log('mm:251', js.replaceAll(RegExp(r'"\w{64}"'), '"-"'));
    return js;
  }

  Future<ActiveCoin> enableCoin(Coin coin, {http.Client client}) async {
    client ??= mmSe.client;
    final r = await client.post(url, body: enableCoinImpl(coin));
    _assert200(r);
    final dynamic jbody = json.decode(r.body);
    final err = ErrorString.fromJson(jbody);
    if (err.error.isNotEmpty) throw removeLineFromMM2(err);
    return ActiveCoin.fromJson(jbody);
  }

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

  Future<RecentSwaps> getRecentSwaps(GetRecentSwap grs,
      {http.Client client}) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(client, grs);
    final r = await userBody.client
        .post(url, body: getRecentSwapToJson(userBody.body));
    _assert200(r);
    _saveRes('getRecentSwaps', r);

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    return RecentSwaps.fromJson(jbody);
  }

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

  /// https://developers.atomicdex.io/basic-docs/atomicdex/atomicdex-api.html#coins-needed-for-kick-start
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
  ) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(client, body);
    final r = await client.post(url, body: json.encode(userBody.body));
    _assert200(r);
    _saveRes('postWithdraw', r);

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    return withdrawResponseFromJson(res.body);
  }

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

  Future<VersionMm2> getVersionMM2(BaseService body,
      {http.Client client}) async {
    client ??= mmSe.client;

    try {
      final userBody = await _assertUserpass(client, body);
      final r = await userBody.client
          .post(url, body: baseServiceToJson(userBody.body));
      _assert200(r);
      _saveRes('getVersionMM2', r);

      final dynamic jbody = json.decode(r.body);

      final v = VersionMm2.fromJson(jbody);
      return v;
    } catch (e) {
      throw _catchErrorString('getVersionMM2', e, 'Error on get version MM2');
    }
  }

  /// Reduce log noise
  int _lastMetricsLog = 0;

  /// Returns a parsed JSON of the MM metrics
  /// https://developers.atomicdex.io/basic-docs/atomicdex/atomicdex-tutorials/atomicdex-metrics.html
  Future<dynamic> getMetricsMM2(BaseService body, {http.Client client}) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(client, body);
    final r =
        await userBody.client.post(url, body: baseServiceToJson(userBody.body));
    _assert200(r);

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastMetricsLog > 600 * 1000) {
      _lastMetricsLog = now;
      _saveRes('getMetricsMM2', r);
    }

    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    return jbody;
  }

  Future<DisableCoin> disableCoin(GetDisableCoin req,
      {http.Client client}) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(client, req);
    final r = await client.post(url, body: json.encode(userBody.body));
    _assert200(r);
    _saveRes('disableCoin', r);

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    return DisableCoin.fromJson(jbody);
  }

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

  /// https://github.com/KomodoPlatform/developer-docs/pull/171/files
  /// https://github.com/KomodoPlatform/atomicDEX-API/commit/a00c2863210ce9a262bb579a74249dbb04a94efc
  Future<List<dynamic>> batch(List<Map<String, dynamic>> batch,
      {http.Client client}) async {
    client ??= mmSe.client;
    final r = await client.post(url, body: json.encode(batch));
    _assert200(r);
    _saveRes('batch', r);
    return List<dynamic>.from(json.decode(r.body));
  }

  Future<List<dynamic>> getEnabledCoins({http.Client client}) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(
      client,
      GetEnabledCoins(),
    );

    final r = await client.post(url, body: jsonEncode(userBody.body));
    _assert200(r);
    _saveRes('getEnabledCoins', r);

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    return jbody['result'].toList();
  }

  Future<List<RewardsItem>> getRewardsInfo({http.Client client}) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(
      client,
      GetRewardsInfo(),
    );

    final r = await client.post(url, body: jsonEncode(userBody.body));
    _assert200(r);
    _saveRes('getRewardsInfo', r);

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    List<RewardsItem> list;
    try {
      for (dynamic item in jbody['result']) {
        list ??= [];
        list.add(RewardsItem.fromJson(item));
      }
    } catch (e) {
      print('$e');
    }

    return list;
  }

  /// returns `null` if address is valid, and String [reason] if not
  Future<String> validateAddress({
    @required String address,
    @required String coin,
    http.Client client,
  }) async {
    client ??= mmSe.client;
    final userBody = await _assertUserpass(
      client,
      GetValidateAddress(
        address: address,
        coin: coin,
      ),
    );

    final r = await client.post(url, body: jsonEncode(userBody.body));
    _assert200(r);
    _saveRes('validateAddress', r);

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    if (jbody['result']['is_valid']) {
      return null;
    } else {
      return jbody['result']['reason'];
    }
  }

  /// Returns converted address, or `null` if convertion failed
  Future<String> convertLegacyAddress({
    @required String address,
    @required String coin,
    http.Client client,
  }) async {
    if (await validateAddress(address: address, coin: coin) == null) {
      // address already valid
      return address;
    }

    client ??= mmSe.client;
    final userBody = await _assertUserpass(
      client,
      GetConvertAddress(
        from: address,
        coin: coin,
      ),
    );

    final r = await client.post(url, body: jsonEncode(userBody.body));
    if (r.statusCode != 200) return null;

    // Parse JSON once, then check if the JSON is an error.
    final dynamic jbody = json.decode(r.body);
    final error = ErrorString.fromJson(jbody);
    if (error.error.isNotEmpty) throw removeLineFromMM2(error);

    return jbody['result']['address'];
  }

  Future<PrivKey> getPrivKey(GetPrivKey gpk, {http.Client client}) async {
    client ??= mmSe.client;
    try {
      final userBody = await _assertUserpass(client, gpk);
      final r = await userBody.client
          .post(url, body: getPrivKeyToJson(userBody.body));
      _assert200(r);
      _saveRes('getPrivKey', r);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = json.decode(r.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      final PrivKey privKey = PrivKey.fromJson(jbody);

      return privKey;
    } catch (e) {
      throw _catchErrorString(
          'getPrivKey', e, 'Error getting ${gpk.coin} private key');
    }
  }

  Future<TradePreimage> getTradePreimage(
    GetTradePreimage request, {
    http.Client client,
  }) async {
    client ??= mmSe.client;

    try {
      final userBody = await _assertUserpass(client, request);
      final response = await userBody.client
          .post(url, body: getTradePreimageToJson(userBody.body));
      _assert200(response);
      _saveRes('getTradePreimage', response);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = jsonDecode(response.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      final preimage = TradePreimage.fromJson(jbody);
      preimage.request = request;
      return preimage;
    } catch (e) {
      throw _catchErrorString('getTradePreimage', e, 'mm trade_preimage] $e');
    }
  }

  Future<Rational> getMaxTakerVolume(
    GetMaxTakerVolume request, {
    http.Client client,
  }) async {
    client ??= mmSe.client;

    try {
      final userBody = await _assertUserpass(client, request);
      final response = await userBody.client
          .post(url, body: getMaxTakerVolumeToJson(userBody.body));
      _assert200(response);
      _saveRes('getMaxTakerVolume', response);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = jsonDecode(response.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      return fract2rat(jbody['result']);
    } catch (e) {
      throw _catchErrorString('getMaxTakerVolume', e, 'max_taker_vol] $e');
    }
  }

  Future<double> getMinTradingVolume(
    GetMinTradingVolume request, {
    http.Client client,
  }) async {
    client ??= mmSe.client;

    try {
      final userBody = await _assertUserpass(client, request);
      final response = await userBody.client
          .post(url, body: getMinTradingVolumeToJson(userBody.body));
      _assert200(response);
      _saveRes('getMinTradingVolume', response);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = jsonDecode(response.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      return double.tryParse(jbody['result']['min_trading_vol'] ?? '');
    } catch (e) {
      throw _catchErrorString(
          'getMinTradingVolume', e, 'mm min_trading_volume] $e');
    }
  }

  Future<ImportSwaps> getImportSwaps(
    GetImportSwaps request, {
    http.Client client,
  }) async {
    client ??= mmSe.client;

    try {
      final userBody = await _assertUserpass(client, request);
      final response = await userBody.client
          .post(url, body: getImportSwapsToJson(userBody.body));
      _assert200(response);
      _saveRes('getImportSwaps', response);

      // Parse JSON once, then check if the JSON is an error.
      final dynamic jbody = jsonDecode(response.body);
      final error = ErrorString.fromJson(jbody);
      if (error.error.isNotEmpty) throw removeLineFromMM2(error);

      final importSwaps = ImportSwaps.fromJson(jbody);

      return importSwaps;
    } catch (e) {
      throw _catchErrorString('getImportSwaps', e, 'mm import_swaps] $e');
    }
  }
}
