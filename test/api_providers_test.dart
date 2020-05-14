import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/batch_request.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_active_coin.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/get_cancel_order.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/get_recent_swap.dart';
import 'package:komodo_dex/model/get_recover_funds_of_swap.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/model/get_swap.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/recover_funds_of_swap.dart';
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'fixtures/fixture_reader.dart';

class MockClient extends Mock implements http.Client {}

/// Might run this with
///
///     flutter test test/api_providers_test.dart
void main() {
  // Allow for running from IDE.
  ft.TestWidgetsFlutterBinding.ensureInitialized();

  // Fix "MissingPluginException(No implementation found for method
  // getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)"
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    return '.';
  });

  const String url = 'http://localhost:7783';

  mmSe.testDocuments = Directory(testDir().path + '/documents');
  mmSe.testDocuments.createSync();
  print('api_providers_test] Documents are in ${mmSe.testDocuments}');

  group('disable_coin', () {
    final MockClient client = MockClient();

    final GetDisableCoin getDisableCoin =
        GetDisableCoin(userpass: 'test', method: 'disable_coin', coin: 'KMD');

    test('returns a DisableCoin', () async {
      when(client.post(url, body: json.encode(getDisableCoin))).thenAnswer(
          (_) async =>
              http.Response(fixture('disable_coin/disable_coin.json'), 200));
      expect(await MM.disableCoin(getDisableCoin, client: client),
          const TypeMatcher<DisableCoin>());
    });

    test('throws on 404', () async {
      when(client.post(url, body: json.encode(getDisableCoin)))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      expect(() async => await MM.disableCoin(getDisableCoin, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });

    test('throws on MM error', () async {
      const mock = 'disable_coin/errors/error_disable_coin_no_such_coin.json';
      when(client.post(url, body: json.encode(getDisableCoin)))
          .thenAnswer((_) async => http.Response(fixture(mock), 200));
      expect(() async => await MM.disableCoin(getDisableCoin, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });

    test('throws on MM error, v2', () async {
      const mock = 'disable_coin/errors/error_disable_coin_active_swaps.json';
      when(client.post(url, body: json.encode(getDisableCoin)))
          .thenAnswer((_) async => http.Response(fixture(mock), 200));
      expect(() async => await MM.disableCoin(getDisableCoin, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });

    test('throws on MM error, v3', () async {
      const mk = 'disable_coin/errors/error_disable_coin_matching_orders.json';
      when(client.post(url, body: json.encode(getDisableCoin)))
          .thenAnswer((_) async => http.Response(fixture(mk), 200));
      expect(() async => await MM.disableCoin(getDisableCoin, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });
  });

  group('withdraw', () {
    final MockClient client = MockClient();

    final GetWithdraw getWithdraw = GetWithdraw(userpass: 'test', coin: 'KMD');

    test('returns a WithdrawResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getWithdrawToJson(getWithdraw))).thenAnswer(
          (_) async => http.Response(fixture('withdraw/withdraw.json'), 200));
      expect(await MM.postWithdraw(client, getWithdraw),
          const TypeMatcher<WithdrawResponse>());
    });

    test('returns a ErrorString if the http call success with a error',
        () async {
      when(client.post(url, body: getWithdrawToJson(getWithdraw))).thenAnswer(
          (_) async => http.Response(
              fixture('withdraw/errors/error_withdraw.json'), 200));
      expect(await MM.postWithdraw(client, getWithdraw),
          const TypeMatcher<ErrorString>());
    });
  });

  group('get_trade_fee', () {
    final MockClient client = MockClient();

    final GetTradeFee getTradeFee = GetTradeFee(userpass: 'test', coin: 'BTC');

    test('returns a TradeFee if the http call completes successfully',
        () async {
      when(client.post(url, body: getTradeFeeToJson(getTradeFee))).thenAnswer(
          (_) async =>
              http.Response(fixture('get_trade_fee/get_trade_fee.json'), 200));
      expect(await MM.getTradeFee(client, getTradeFee),
          const TypeMatcher<TradeFee>());
    });
  });

  group('send_raw_transaction', () {
    final MockClient client = MockClient();

    final GetSendRawTransaction getSendRawTransaction =
        GetSendRawTransaction(userpass: 'test', coin: 'BTC');

    test(
        'returns a SendRawTransactionResponse if the http call completes successfully',
        () async {
      when(client.post(url,
              body: getSendRawTransactionToJson(getSendRawTransaction)))
          .thenAnswer((_) async => http.Response(
              fixture('send_raw_transaction/send_raw_transaction.json'), 200));
      expect(await MM.postRawTransaction(client, getSendRawTransaction),
          const TypeMatcher<SendRawTransactionResponse>());
    });

    test('returns a ErrorString if the http result is error', () async {
      when(client.post(url,
              body: getSendRawTransactionToJson(getSendRawTransaction)))
          .thenAnswer((_) async =>
              http.Response(fixture('general_errors/error_string.json'), 200));
      expect(await MM.postRawTransaction(client, getSendRawTransaction),
          const TypeMatcher<ErrorString>());
    });
  });

  group('coins_needed_for_kick_start', () {
    final MockClient client = MockClient();

    final BaseService getRecentSwap = BaseService(userpass: 'test');

    test('returns a CoinToKickStart if the http call completes successfully',
        () async {
      when(client.post(url, body: baseServiceToJson(getRecentSwap))).thenAnswer(
          (_) async => http.Response(
              fixture(
                  'coins_needed_for_kick_start/coins_needed_for_kick_start.json'),
              200));
      expect(await MM.getCoinToKickStart(client, getRecentSwap),
          const TypeMatcher<CoinToKickStart>());
    });

    test('returns a ErrorString if the http call completes unsuccessfully',
        () async {
      when(client.post(url, body: baseServiceToJson(getRecentSwap))).thenAnswer(
          (_) async =>
              http.Response(fixture('general_errors/error_string.json'), 200));
      expect(await MM.getCoinToKickStart(client, getRecentSwap),
          const TypeMatcher<ErrorString>());
    });
  });

  group('cancel_order', () {
    final MockClient client = MockClient();

    final GetCancelOrder body = GetCancelOrder(userpass: 'test');

    test('returns a ResultSuccess if the http call completes successfully',
        () async {
      when(client.post(url, body: getCancelOrderToJson(body))).thenAnswer(
          (_) async =>
              http.Response(fixture('cancel_order/cancel_order.json'), 200));
      expect(await MM.cancelOrder(client, body),
          const TypeMatcher<ResultSuccess>());
    });

    test('returns a ErrorString if the http call completes with error from mm2',
        () async {
      when(client.post(url, body: getCancelOrderToJson(body))).thenAnswer(
          (_) async => http.Response(
              fixture('cancel_order/errors/error_cancel_order.json'), 200));
      final dynamic error = await MM.cancelOrder(client, body);
      expect(error, const TypeMatcher<ErrorString>());
      expect(error.error,
          'Order with uuid 6a242691-6c05-474a-85c1-5b3f42278f42 is not found');
    });
  });

  group('my_orders', () {
    final MockClient client = MockClient();

    final BaseService body = BaseService(userpass: 'test', method: 'my_orders');

    test('returns a Orders if the http call completes successfully', () async {
      when(client.post(url, body: baseServiceToJson(body))).thenAnswer(
          (_) async => http.Response(fixture('my_orders/my_orders.json'), 200));
      expect(await MM.getMyOrders(client, body), const TypeMatcher<Orders>());
    });

    test('returns a ErrorString if the http call completes unsuccessfully',
        () async {
      when(client.post(url, body: baseServiceToJson(body))).thenAnswer(
          (_) async =>
              http.Response(fixture('general_errors/error_string.json'), 200));
      expect(
          await MM.getMyOrders(client, body), const TypeMatcher<ErrorString>());
    });
  });

  group('my_recent_swaps', () {
    final MockClient client = MockClient();

    final GetRecentSwap body =
        GetRecentSwap(userpass: 'test', method: 'my_recent_swaps');

    test('returns a RecentSwaps if the http call completes successfully',
        () async {
      when(client.post(url, body: getRecentSwapToJson(body))).thenAnswer(
          (_) async => http.Response(
              fixture('my_recent_swaps/my_recent_swaps.json'), 200));
      expect(await MM.getRecentSwaps(body, client: client),
          const TypeMatcher<RecentSwaps>());
    });

    test('throws if http call completes unsuccessfully', () async {
      when(client.post(url, body: getRecentSwapToJson(body))).thenAnswer(
          (_) async =>
              http.Response(fixture('general_errors/error_string.json'), 200));
      expect(() async => await MM.getRecentSwaps(body, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });

    test('throws if http call completes with error', () async {
      when(client.post(url, body: getRecentSwapToJson(body)))
          .thenAnswer((_) async => http.Response('Error Parsing', 200));
      expect(() async => await MM.getRecentSwaps(body, client: client),
          throwsA(ft.isException));
    });

    test('throws if http call completes with status 500', () async {
      when(client.post(url, body: getRecentSwapToJson(body)))
          .thenAnswer((_) async => http.Response('Error Parsing', 500));
      expect(() async => await MM.getRecentSwaps(body, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });

    test('throws if http call completes with error from mm2', () async {
      when(client.post(url, body: getRecentSwapToJson(body))).thenAnswer(
          (_) async => http.Response(
              fixture('my_recent_swaps/errors/swap_not_found.json'), 200));
      ErrorString err;
      try {
        await MM.getRecentSwaps(body, client: client);
      } on ErrorString catch (ex) {
        err = ex;
      }
      expect(err, ft.isNotNull);
      expect(err.error,
          'from_uuid e299c6ece7a7ddc42444eda64d46b163eaa992da65ce6de24eb812d715184e41 swap is not found');
    });
  });

  group('my_tx_history', () {
    final MockClient client = MockClient();

    final GetTxHistory body = GetTxHistory(userpass: 'test');

    test('returns a Transactions if the http call completes successfully',
        () async {
      when(client.post(url, body: getTxHistoryToJson(body))).thenAnswer(
          (_) async =>
              http.Response(fixture('my_tx_history/my_tx_history.json'), 200));
      expect(await MM.getTransactions(client, body),
          const TypeMatcher<Transactions>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getTxHistoryToJson(body))).thenAnswer(
          (_) async => http.Response(
              fixture('my_tx_history/errors/error_my_tx_history.json'), 200));

      final dynamic errorString = await MM.getTransactions(client, body);
      expect(errorString, const TypeMatcher<ErrorString>());
      expect(errorString.error,
          'from_id 1d5c1b67f8ebd3fc480e25a1d60791bece278f5d1245c5f9474c91a142fee8e2 is not found');
    });
  });

  group('setprice', () {
    final MockClient client = MockClient();

    final GetSetPrice body = GetSetPrice(userpass: 'test');

    test('returns a SetPriceResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getSetPriceToJson(body))).thenAnswer(
          (_) async => http.Response(fixture('setprice/set_price.json'), 200));
      expect(await MM.postSetPrice(client, body),
          const TypeMatcher<SetPriceResponse>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getSetPriceToJson(body))).thenAnswer(
          (_) async => http.Response(
              fixture('setprice/errors/error_set_price_rel_not_found.json'),
              200));
      expect(await MM.postSetPrice(client, body),
          const TypeMatcher<ErrorString>());
    });
  });

  group('active_coin', () {
    final MockClient client = MockClient();

    final Coin coinToActiveERC = Coin(
        type: 'erc',
        abbr: 'ETH',
        swapContractAddress: '0x8500AFc0bc5214728082163326C2FF0C73f4a871',
        serverList: <String>[
          'http://eth1.cipig.net:8555',
          'http://eth2.cipig.net:8555',
          'http://eth3.cipig.net:8555'
        ]);

    final Coin coinToActive =
        Coin(type: 'smartChain', abbr: 'RICK', serverList: <String>[
      'http://eth1.cipig.net:8555',
      'http://eth2.cipig.net:8555',
      'http://eth3.cipig.net:8555'
    ]);

    test('returns an ActiveCoin, ERC', () async {
      const mock = 'active_coin/active_coin.json';
      when(client.post(url, body: MM.enableCoinImpl(coinToActiveERC)))
          .thenAnswer((_) async => http.Response(fixture(mock), 200));
      expect(await MM.enableCoin(coinToActiveERC, client: client),
          const TypeMatcher<ActiveCoin>());
    });

    test('returns an ActiveCoin', () async {
      const mock = 'active_coin/active_coin.json';
      when(client.post(url, body: MM.enableCoinImpl(coinToActive)))
          .thenAnswer((_) async => http.Response(fixture(mock), 200));
      expect(await MM.enableCoin(coinToActive, client: client),
          const TypeMatcher<ActiveCoin>());
    });

    test('throws an ErrorString', () async {
      const mock = 'active_coin/errors/error_active_coin_mm2_param.json';
      when(client.post(url, body: MM.enableCoinImpl(coinToActive)))
          .thenAnswer((_) async => http.Response(fixture(mock), 200));
      expect(() async => await MM.enableCoin(coinToActive, client: client),
          throwsA(const TypeMatcher<ErrorString>()));
    });
  });

  group('sell', () {
    final MockClient client = MockClient();

    final GetBuySell body = GetBuySell(userpass: 'test', method: 'sell');

    test('returns a BuyResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response(fixture('buy/buy.json'), 200));
      expect(await MM.postSell(client, body), const TypeMatcher<BuyResponse>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBuyToJson(body))).thenAnswer((_) async =>
          http.Response(fixture('buy/errors/buy_to_low.json'), 200));

      expect(await MM.postSell(client, body), const TypeMatcher<ErrorString>());
    });
  });

  group('buy', () {
    final MockClient client = MockClient();

    final GetBuySell body = GetBuySell(userpass: 'test', method: 'buy');

    test('returns a BuyResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response(fixture('buy/buy.json'), 200));
      expect(await MM.postBuy(client, body), const TypeMatcher<BuyResponse>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBuyToJson(body))).thenAnswer((_) async =>
          http.Response(fixture('error_post_buy_buy_to_low.json'), 200));
      expect(await MM.postBuy(client, body), const TypeMatcher<ErrorString>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBuyToJson(body))).thenAnswer((_) async =>
          http.Response(
              fixture('buy/errors/electrums_disconnected.json'), 200));

      final ErrorString error = await MM.postBuy(client, body);
      expect(error.error, 'All electrums are currently disconnected');
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response('Error parsing json', 200));
      final ErrorString error = await MM.postBuy(client, body);
      expect(error.error, 'Error on post buy');
    });

    test('returns a ErrorString if the http call completes with error from mm2',
        () async {
      when(client.post(url, body: getBuyToJson(body))).thenAnswer((_) async =>
          http.Response(fixture('buy/errors/rel_to_low.json'), 200));
      final ErrorString error = await MM.postBuy(client, body);
      expect(error.error, 'REL balance 12.88892991 is too low, required 21.15');
    });

    test('returns a ErrorString if the http call completes with error from mm2',
        () async {
      when(client.post(url, body: getBuyToJson(body))).thenAnswer((_) async =>
          http.Response(fixture('buy/errors/larger_than_available.json'), 200));
      final ErrorString error = await MM.postBuy(client, body);
      expect(error.error,
          'The WORLD amount 40000/3 is larger than available 47.60450107, balance: 47.60450107, locked by swaps: 0.00000000');
    });
  });

  group('my_balance', () {
    final MockClient client = MockClient();

    final GetBalance body = GetBalance(userpass: 'test');

    test('returns a Balance if the http call completes successfully', () async {
      when(client.post(url, body: getBalanceToJson(body))).thenAnswer(
          (_) async =>
              http.Response(fixture('my_balance/my_balance.json'), 200));
      expect(await MM.getBalance(body, client: client),
          const TypeMatcher<Balance>());
    });

    test('throws ErrorString if the http call completes with error', () async {
      when(client.post(url, body: getBalanceToJson(body))).thenAnswer(
          (_) async =>
              http.Response(fixture('general_errors/error_string.json'), 200));
      ErrorString error;
      try {
        await MM.getBalance(body, client: client);
      } on ErrorString catch (e) {
        error = e;
      }
      expect(error, const TypeMatcher<ErrorString>());
    });

    test('throws ErrorString if the http call completes with error', () async {
      when(client.post(url, body: getBalanceToJson(body)))
          .thenAnswer((_) async => http.Response('Not found', 404));
      ErrorString error;
      try {
        await MM.getBalance(body, client: client);
      } on ErrorString catch (e) {
        error = e;
      }
      expect(error.error, 'Error getting ${body.coin} balance');
    });
  });

  group('orderbook', () {
    final MockClient client = MockClient();

    final GetOrderbook body = GetOrderbook(userpass: 'test');

    test('returns a Balance if the http call completes successfully', () async {
      when(client.post(url, body: getOrderbookToJson(body))).thenAnswer(
          (_) async => http.Response(fixture('orderbook/orderbook.json'), 200));
      expect(
          await MM.getOrderbook(client, body), const TypeMatcher<Orderbook>());
    });
  });

  group('my_swap_status', () {
    final MockClient client = MockClient();

    final GetSwap body = GetSwap(userpass: 'test');

    test('returns a Swap if the http call completes successfully (Taker swap)',
        () async {
      when(client.post(url, body: getSwapToJson(body))).thenAnswer((_) async =>
          http.Response(
              fixture('my_swap_status/my_swap_status_taker_swap.json'), 200));
      final dynamic result = await MM.getSwapStatus(client, body);
      expect(result, const TypeMatcher<Swap>());
    });

    test('returns a Swap if the http call completes successfully (Maker swap)',
        () async {
      when(client.post(url, body: getSwapToJson(body))).thenAnswer((_) async =>
          http.Response(
              fixture('my_swap_status/my_swap_status_maker_swap.json'), 200));
      final dynamic result = await MM.getSwapStatus(client, body);
      expect(result, const TypeMatcher<Swap>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getSwapToJson(body))).thenAnswer((_) async =>
          http.Response(fixture('general_errors/error_string.json'), 200));

      final dynamic errorString = await MM.getSwapStatus(client, body);
      expect(errorString, const TypeMatcher<ErrorString>());
      expect(errorString.error, 'swap data is not found');
    });
  });

  group('recover_funds_of_swap', () {
    final MockClient client = MockClient();

    final GetRecoverFundsOfSwap body = GetRecoverFundsOfSwap(userpass: 'test');

    test('returns a RecoverFundsOfSwap if the http call completes successfully',
        () async {
      when(client.post(url, body: getRecoverFundsOfSwapToJson(body)))
          .thenAnswer((_) async => http.Response(
              fixture('recover_funds_of_swap/recover_funds_of_swap.json'),
              200));
      expect(await MM.recoverFundsOfSwap(client, body),
          const TypeMatcher<RecoverFundsOfSwap>());
    });

    test(
        'return a ErrorString if the http call completes unsuccefully, maker payment was already spent',
        () async {
      when(client.post(url, body: getRecoverFundsOfSwapToJson(body)))
          .thenAnswer((_) async => http.Response(
              fixture(
                  'recover_funds_of_swap/errors/error_swap_recover_maker.json'),
              200));
      final dynamic result = await MM.recoverFundsOfSwap(client, body);
      expect(result, const TypeMatcher<ErrorString>());
      expect(result.error, 'Maker payment is spent, swap is not recoverable');
    });

    test(
        'return a ErrorString if the http call completes unsuccefully, swap is not finished yet',
        () async {
      when(client.post(url, body: getRecoverFundsOfSwapToJson(body)))
          .thenAnswer((_) async => http.Response(
              fixture('recover_funds_of_swap/errors/error_swap_recover.json'),
              200));
      final dynamic result = await MM.recoverFundsOfSwap(client, body);
      expect(result, const TypeMatcher<ErrorString>());
      expect(
          result.error, 'Swap must be finished before recover funds attempt');
    });

    test(
        'returns a ErrorString if the http call completes with a error parsing',
        () async {
      when(client.post(url, body: getRecoverFundsOfSwapToJson(body)))
          .thenAnswer((_) async => http.Response('Error parsing', 200));
      expect(await MM.recoverFundsOfSwap(client, body),
          const TypeMatcher<ErrorString>());
    });

    test(
        'returns a ErrorString if the http call completes with a swap not found',
        () async {
      when(client.post(url, body: getRecoverFundsOfSwapToJson(body)))
          .thenAnswer((_) async => http.Response(
              fixture(
                  'recover_funds_of_swap/errors/error_recover_swap_not_found.json'),
              200));
      final dynamic result = await MM.recoverFundsOfSwap(client, body);

      expect(result.error, 'swap data is not found');
      expect(result, const TypeMatcher<ErrorString>());
    });
  });

  test('batch requests', () async {
    final MockClient client = MockClient();

    final batchRequest = BatchRequest(
      method: 'electrum',
      coin: 'RICK',
      servers: [
        Server(url: 'electrum1.cipig.net:10017'),
        Server(url: 'electrum2.cipig.net:10017'),
        Server(url: 'electrum3.cipig.net:10017')
      ],
      userpass: 'test',
      mm2: 1,
    );

    when(client.post(url, body: batchRequest)).thenAnswer((_) async =>
        http.Response(fixture('batch_requests/batch_request_rick.json'), 200));
    final dynamic result = await MM.batchRequest(batchRequest, client: client);

    expect(await MM.batchRequest(batchRequest, client: client),
        const TypeMatcher<ActiveCoin>());
  });
}
