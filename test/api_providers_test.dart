import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/model/error_disable_coin_order_is_matched.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/api_providers.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  const String url = 'http://localhost:7783';

  group('disable_coin', () {
    final MockClient client = MockClient();

    final GetDisableCoin getDisableCoin =
        GetDisableCoin(userpass: 'test', method: 'disable_coin', coin: 'KMD');

    test('returns a DisableCoin if the http call completes successfully',
        () async {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response('''
              {
                "result": 
                  {
                    "cancelled_orders":["e5fc7c81-7574-4d3f-b64a-47227455d62a"],
                    "coin":"RICK"
                  }
              }
              ''', 200));
      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<DisableCoin>());
    });

    test('throws an exception if the http call completes with an error', () {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      expect(
          ApiProvider().disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          throwsException);
    });

    test(
        'returns a ErrorString if the http call completes with errors - coin is not enabled',
        () async {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async =>
              http.Response('{"error": "No such coin: RICK"}', 200));
      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<ErrorString>());
    });

    test(
        'returns a ErrorDisableCoinActiveSwap if the http call completes with errors - active swap is using the coin',
        () async {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response('''
              {
                "error": "There\'re active swaps using RICK",
                "swaps":["d88d0a0e-f8bd-40ab-8edd-fe20801ef349"]
              }
              ''', 200));

      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<ErrorDisableCoinActiveSwap>());
    });

    test(
        'returns a ErrorDisableCoin if the http call completes with error - the order is matched at the moment, but another order is cancelled',
        () async {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response('''
              {
                "error":"There\'re currently matching orders using RICK",
                "orders":{"matching": ["d88d0a0e-f8bd-40ab-8edd-fe20801ef349"],
                "cancelled":["c88d0a0e-f8bd-40ab-8edd-fe20801ef349"]}
              }
              ''', 200));

      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<ErrorDisableCoinOrderIsMatched>());
    });
  });

  group('withdraw', () {
    final MockClient client = MockClient();

    final GetWithdraw getWithdraw = GetWithdraw(userpass: 'test', coin: 'KMD');

    test('returns a WithdrawResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getWithdrawToJson(getWithdraw)))
          .thenAnswer((_) async => http.Response('''
              {
                "tx_hex":"0400008085202f8901ef25b1b7417fe7693097918ff90e90bba1351fff1f3a24cb51a9b45c5636e57e010000006b483045022100b05c870fcd149513d07b156e150a22e3e47fab4bb4776b5c2c1b9fc034a80b8f022038b1bf5b6dad923e4fb1c96e2c7345765ff09984de12bbb40b999b88b628c0f9012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0200e1f505000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac8cbaae5f010000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ace87a5e5d000000000000000000000000000000",
                "tx_hash":"1ab3bc9308695960bc728fa427ac00d1812c4ae89aaa714c7618cb96d111be58",
                "from":["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                "to":["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                "total_amount":"60.10253836",
                "spent_by_me":"60.10253836",
                "received_by_me":"60.00253836",
                "my_balance_change":"-0.1",
                "block_height":0,
                "timestamp":1566472936,
                "fee_details":{
                  "amount":"0.1"
                },
                "coin":"RICK",
                "internal_id":""
              }
      ''', 200));
      expect(await ApiProvider().postWithdraw(client, getWithdraw),
          const TypeMatcher<WithdrawResponse>());
    });

    test('returns a ErrorString if the http call success with a error',
        () async {
      when(client.post(url, body: getWithdrawToJson(getWithdraw)))
          .thenAnswer((_) async => http.Response('''
              {
                "error":"utxo:1295] Unsupported input fee type"
              }
      ''', 200));
      expect(await ApiProvider().postWithdraw(client, getWithdraw),
          const TypeMatcher<ErrorString>());
    });
  });

  group('get_trade_fee', () {
    final MockClient client = MockClient();

    final GetTradeFee getTradeFee = GetTradeFee(userpass: 'test', coin: 'BTC');

    test('returns a TradeFee if the http call completes successfully',
        () async {
      when(client.post(url, body: getTradeFeeToJson(getTradeFee)))
          .thenAnswer((_) async => http.Response('''
          {
            "result": {
              "amount": "0.00096041",
              "coin": "BTC"
            }
          }
      ''', 200));
      expect(
          await ApiProvider()
              .getTradeFee(client, Coin(abbr: 'BTC'), getTradeFee),
          const TypeMatcher<TradeFee>());
    });
  });
}
