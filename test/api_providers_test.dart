import 'package:komodo_dex/model/active_coin.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/base_service.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_to_kick_start.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/model/error_disable_coin_order_is_matched.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_balance.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/get_cancel_order.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/model/get_orderbook.dart';
import 'package:komodo_dex/model/get_recent_swap.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/model/get_swap.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/get_tx_history.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/result.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/model/transactions.dart';
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
      expect(await ApiProvider().disableCoin(client, getDisableCoin),
          const TypeMatcher<DisableCoin>());
    });

    test('throws an exception if the http call completes with an error', () {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response('Not Found', 404));
      expect(
          ApiProvider().disableCoin(client, getDisableCoin), throwsException);
    });

    test(
        'returns a ErrorString if the http call completes with errors - coin is not enabled',
        () async {
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async =>
              http.Response('{"error": "No such coin: RICK"}', 200));
      expect(await ApiProvider().disableCoin(client, getDisableCoin),
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

      expect(await ApiProvider().disableCoin(client, getDisableCoin),
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

      expect(await ApiProvider().disableCoin(client, getDisableCoin),
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
      expect(await ApiProvider().getTradeFee(client, getTradeFee),
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
          .thenAnswer((_) async => http.Response('''
            {
              "tx_hash": "0b024ea6997e16387c0931de9f203d534c6b2b8500e4bda2df51a36b52a3ef33"
            }
      ''', 200));
      expect(
          await ApiProvider().postRawTransaction(client, getSendRawTransaction),
          const TypeMatcher<SendRawTransactionResponse>());
    });

    test('returns a ErrorString if the http result is tx_hash empty', () async {
      when(client.post(url,
              body: getSendRawTransactionToJson(getSendRawTransaction)))
          .thenAnswer((_) async => http.Response('''
            {
              "tx_hash": ""
            }
      ''', 200));
      expect(
          await ApiProvider().postRawTransaction(client, getSendRawTransaction),
          const TypeMatcher<ErrorString>());
    });

    test('returns a ErrorString if the http result is error', () async {
      when(client.post(url,
              body: getSendRawTransactionToJson(getSendRawTransaction)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "message"
            }
      ''', 200));
      expect(
          await ApiProvider().postRawTransaction(client, getSendRawTransaction),
          const TypeMatcher<ErrorString>());
    });
  });

  group('coins_needed_for_kick_start', () {
    final MockClient client = MockClient();

    final BaseService getRecentSwap = BaseService(userpass: 'test');

    test('returns a CoinToKickStart if the http call completes successfully',
        () async {
      when(client.post(url, body: baseServiceToJson(getRecentSwap)))
          .thenAnswer((_) async => http.Response('''
            { 
              "result": ["BTC", "KMD"] 
            }
      ''', 200));
      expect(await ApiProvider().getCoinToKickStart(client, getRecentSwap),
          const TypeMatcher<CoinToKickStart>());
    });
  });

  group('cancel_order', () {
    final MockClient client = MockClient();

    final GetCancelOrder body = GetCancelOrder(userpass: 'test');

    test('returns a ResultSuccess if the http call completes successfully',
        () async {
      when(client.post(url, body: getCancelOrderToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": "success"
            }
      ''', 200));
      expect(await ApiProvider().cancelOrder(client, body),
          const TypeMatcher<ResultSuccess>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getCancelOrderToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "Order with uuid 6a242691-6c05-474a-85c1-5b3f42278f42 is not found"
            }
      ''', 200));
      expect(await ApiProvider().cancelOrder(client, body),
          const TypeMatcher<ErrorString>());
    });
  });

  group('my_orders', () {
    final MockClient client = MockClient();

    final BaseService body = BaseService(userpass: 'test', method: 'my_orders');

    test('returns a Orders if the http call completes successfully', () async {
      when(client.post(url, body: baseServiceToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": {
                "maker_orders": {
                  "fedd5261-a57e-4cbf-80ac-b3507045e140": {
                    "base": "BEER",
                    "created_at": 1560529042434,
                    "available_amount": "1",
                    "cancellable": true,
                    "matches": {
                      "60aaacca-ed31-4633-9326-c9757ea4cf78": {
                        "connect": {
                          "dest_pub_key": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                          "maker_order_uuid": "fedd5261-a57e-4cbf-80ac-b3507045e140",
                          "method": "connect",
                          "sender_pubkey": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "taker_order_uuid": "60aaacca-ed31-4633-9326-c9757ea4cf78"
                        },
                        "connected": {
                          "dest_pub_key": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "maker_order_uuid": "fedd5261-a57e-4cbf-80ac-b3507045e140",
                          "method": "connected",
                          "sender_pubkey": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                          "taker_order_uuid": "60aaacca-ed31-4633-9326-c9757ea4cf78"
                        },
                        "last_updated": 1560529572571,
                        "request": {
                          "action": "Buy",
                          "base": "BEER",
                          "base_amount": "1",
                          "dest_pub_key": "0000000000000000000000000000000000000000000000000000000000000000",
                          "method": "request",
                          "rel": "PIZZA",
                          "rel_amount": "1",
                          "sender_pubkey": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "uuid": "60aaacca-ed31-4633-9326-c9757ea4cf78"
                        },
                        "reserved": {
                          "base": "BEER",
                          "base_amount": "1",
                          "dest_pub_key": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "maker_order_uuid": "fedd5261-a57e-4cbf-80ac-b3507045e140",
                          "method": "reserved",
                          "rel": "PIZZA",
                          "rel_amount": "1",
                          "sender_pubkey": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                          "taker_order_uuid": "60aaacca-ed31-4633-9326-c9757ea4cf78"
                        }
                      }
                    },
                    "max_base_vol": "1",
                    "min_base_vol": "0",
                    "price": "1",
                    "rel": "PIZZA",
                    "started_swaps": ["60aaacca-ed31-4633-9326-c9757ea4cf78"],
                    "uuid": "fedd5261-a57e-4cbf-80ac-b3507045e140"
                  }
                },
                "taker_orders": {
                  "45252de5-ea9f-44ae-8b48-85092a0c99ed": {
                    "created_at": 1560529048998,
                    "cancellable": true,
                    "matches": {
                      "15922925-cc46-4219-8cbd-613802e17797": {
                        "connect": {
                          "dest_pub_key": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "maker_order_uuid": "15922925-cc46-4219-8cbd-613802e17797",
                          "method": "connect",
                          "sender_pubkey": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                          "taker_order_uuid": "45252de5-ea9f-44ae-8b48-85092a0c99ed"
                        },
                        "connected": {
                          "dest_pub_key": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                          "maker_order_uuid": "15922925-cc46-4219-8cbd-613802e17797",
                          "method": "connected",
                          "sender_pubkey": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "taker_order_uuid": "45252de5-ea9f-44ae-8b48-85092a0c99ed"
                        },
                        "last_updated": 1560529049477,
                        "reserved": {
                          "base": "BEER",
                          "base_amount": "1",
                          "dest_pub_key": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                          "maker_order_uuid": "15922925-cc46-4219-8cbd-613802e17797",
                          "method": "reserved",
                          "rel": "ETOMIC",
                          "rel_amount": "1",
                          "sender_pubkey": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                          "taker_order_uuid": "45252de5-ea9f-44ae-8b48-85092a0c99ed"
                        }
                      }
                    },
                    "request": {
                      "action": "Buy",
                      "base": "BEER",
                      "base_amount": "1",
                      "dest_pub_key": "0000000000000000000000000000000000000000000000000000000000000000",
                      "method": "request",
                      "rel": "ETOMIC",
                      "rel_amount": "1",
                      "sender_pubkey": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                      "uuid": "45252de5-ea9f-44ae-8b48-85092a0c99ed"
                    }
                  }
                }
              }
            }
      ''', 200));
      expect(await ApiProvider().getMyOrders(client, body),
          const TypeMatcher<Orders>());
    });
  });

  group('my_recent_swaps', () {
    final MockClient client = MockClient();

    final GetRecentSwap body =
        GetRecentSwap(userpass: 'test', method: 'my_recent_swaps');

    test('returns a RecentSwaps if the http call completes successfully',
        () async {
      when(client.post(url, body: getRecentSwapToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": {
                "from_uuid": "e299c6ece7a7ddc42444eda64d46b163eaa992da65ce6de24eb812d715184e4c",
                "limit": 2,
                "skipped": 1,
                "swaps": [
                  {
                    "error_events": [
                      "StartFailed",
                      "NegotiateFailed",
                      "TakerFeeValidateFailed",
                      "MakerPaymentTransactionFailed",
                      "MakerPaymentDataSendFailed",
                      "TakerPaymentValidateFailed",
                      "TakerPaymentSpendFailed",
                      "MakerPaymentRefunded",
                      "MakerPaymentRefundFailed"
                    ],
                    "events": [
                      {
                        "event": {
                          "data": {
                            "lock_duration": 7800,
                            "maker_amount": "1",
                            "maker_coin": "BEER",
                            "maker_coin_start_block": 154221,
                            "maker_payment_confirmations": 1,
                            "maker_payment_lock": 1561545442,
                            "my_persistent_pub": "02031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3",
                            "secret": "ea774bc94dce44c138920c6e9255e31d5645e60c0b64e9a059ab025f1dd2fdc6",
                            "started_at": 1561529842,
                            "taker": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                            "taker_amount": "1",
                            "taker_coin": "PIZZA",
                            "taker_coin_start_block": 141363,
                            "taker_payment_confirmations": 1,
                            "uuid": "6bf6e313-e610-4a9a-ba8c-57fc34a124aa"
                          },
                          "type": "Started"
                        },
                        "timestamp": 1561529842866
                      },
                      {
                        "event": {
                          "data": {
                            "taker_payment_locktime": 1561537641,
                            "taker_pubkey": "02631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640"
                          },
                          "type": "Negotiated"
                        },
                        "timestamp": 1561529883208
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 141364,
                            "coin": "PIZZA",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh"],
                            "internal_id": "a91469546211cc910fbe4a1f4668ab0353765d3d0cb03f4a67bff9326991f682",
                            "my_balance_change": "0",
                            "received_by_me": "0",
                            "spent_by_me": "0",
                            "timestamp": 1561529907,
                            "to": [
                              "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                              "RThtXup6Zo7LZAi8kRWgjAyi1s4u6U9Cpf"
                            ],
                            "total_amount": "0.002",
                            "tx_hash": "a91469546211cc910fbe4a1f4668ab0353765d3d0cb03f4a67bff9326991f682",
                            "tx_hex": "0400008085202f89021c7eeec33f8eb5ff2ed6c3d09e40e04b05a9674ea2feefcc12de3f9dcc16aff8000000006b483045022100e18e3d1afa8a24ecec82c92bfc05c119bfacdbb71b5f5663a4b96cc2a41ab269022017a79a1a1f6e0220d8fa1d2cf3b1c9788272f1ad18e4987b8f1cd4418acaa5b0012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff6a0d321eb52c3c7165adf80f83b15b7a5caa3a0dfa87746239021600d47fb43e000000006b483045022100937ed900e084d57d5e3341499fc66c5574884ca71cd4331fa696c8b7a517591b02201f5f851f94c3ca0ffb4789f1af22cb95dc83564e127ed7d23f1129eb2b981a2f012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff02bcf60100000000001976a914ca1e04745e8ca0c60d8c5881531d51bec470743f88ac9c120100000000001976a91464ae8510aac9546d5e7704e31ce177451386455588ac2f0e135d000000000000000000000000000000"
                          },
                          "type": "TakerFeeValidated"
                        },
                        "timestamp": 1561529927879
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 0,
                            "coin": "BEER",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                            "internal_id": "efa90a2918e6793c8a2725c06ee34d0fa76c43bc85e680be195414e7aee36154",
                            "my_balance_change": "-1.00001",
                            "received_by_me": "0.0285517",
                            "spent_by_me": "1.0285617",
                            "timestamp": 0,
                            "to": [
                              "R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW",
                              "bKuQbg7vgFR1C25vPqMq8ePnB25cUEAGpo"
                            ],
                            "total_amount": "1.0285617",
                            "tx_hash": "efa90a2918e6793c8a2725c06ee34d0fa76c43bc85e680be195414e7aee36154",
                            "tx_hex": "0400008085202f890cdcd071edda0d5f489b0be9c8b521ad608bb6d7f43f6e7a491843e7a4d0078f85000000006b483045022100fbc3bd09f8e1821ed671d1b1d2ed355833fb42c0bc435fef2da5c5b0a980b9a002204ef92b35576069d640ca0ac08f46645e5ade36afd5f19fb6aad19cfc9fb221fb012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffe6ae2a3ce221a6612d9e640bdbe10a2e477b3bc68a1aeee4a6784cb18648a785010000006a47304402202000a7e60ae2ce1529247875623ef2c5b42448dcaeac8de0f8f0e2f8e5bd8a6b0220426321a004b793172014f522efbca77a3dc92e86ce0a75330d8ceb83072ad4e7012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff9335553edcbac9559cae517a3e25b880a48fabf661c4ac338394972eef4572da000000006b4830450221008ded7230f2fb37a42b94f96174ec192baf4cd9e9e68fb9b6cf0463a36a6093e00220538de51ceda1617f3964a2350802377940fdfa018cc1043d77c66081b1cab0c4012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3fffffffff91b5d3733877f84108de77fec46bee156766e1a6837fa7b580ccbc3905acb14000000006b483045022100d07cf1fd20e07aafdc942ba56f6b45baee61b93145a2bdba391e2cdb8024bf15022056ea8183990703ef05018df2fe8bd5ec678ec0f9207b0283292b2cdafc5e1e0c012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff147870387ca938b2b6e7daa96ba2496014f125c0e4e576273ef36ee8186c415a000000006a47304402204c5b15b641d7e34444456d2ea6663bdc8bd8216e309a7220814474f346b8425e0220634d1dd943b416b7a807704d7f7a3d46a60d88ef4e20734588a0b302c55fa82d012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffd2b954ae9b4a61fad9f7bc956d24e38d7b6fe313da824bd3bd91287d5a6b49d9000000006b483045022100a7387d9ab7b2c92d3cbce525e96ffac5ae3ef14f848661741ada0db17715c4a002202c1417d5e3e04b1a2d1774a83bb8d5aa1c0536c100138123089fa69921b5d976012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff28792a2e26d9d7be0467fac52b12ece67410b23eea845008257979bd87d083e3000000006a473044022027c40517c33cd3202d4310cfd2c75f38e6d7804b255fc3838a32ea26e5a3cb0002202b4399e1d7e655b64f699318f2bfbdced49f064ee54e9d6a678668fce51caf96012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffa8bf797bacd213b74a9977ae1b956afe3af33a1ee94324e010a16db891a07441000000006a473044022004cbb1d970b9f02c578b5c1d7de33361581eebc19c3cd8d2e50b0211ca4ef13702200c93b9fe5428055b6274dc8e52073c3e87f5b5e4206134d745928ccfc9393919012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff2b6fd82c9a68111b67ad85a614a6ecb50f7b6eac3d21d8ebefd9a6065cdf5729000000006b483045022100fdff16c595c7b4a9b4fc1e445b565f7b29fe5b7a08f79291b0ff585c7b72ac2902200c694aa124013bd419ce2349f15d10435827868d35db939b9d3c344d16e78420012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff6a5468dd8c83553dc51022f2a2fb772cf91c8607dc2ca1b8f203ac534612ab29000000006b483045022100ba7cc79e7ae3720238bfc5caa225dc8017d6a0d1cb1ec66abaf724fd20b3b7ab02206e8c942756604af0f63b74af495a9b3b7f4a44c489267f69a14cf2b1b953f46e012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff5f9f48a91d343fd5aef1d85f00850070931459ab256697afb728d1c81c1fa1d2000000006a47304402200ec85fc66f963e7504eb27361a4b4bb17de60e459da414fdc3962476de636134022056b62c15cf7f9b4e7d4e11c03e4e541dd348919b8c55efa4f1927e2fdd5ae8ea012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffee1f455924d3167e7f7abf452c1856e9abdcfe27dc889942dd249cb376169d38000000006b48304502210089274eed807c5d23d819f6dfa8a358a9748e56f2080be4396ef77bb19d91b17402207fc7b22c879534fffe0eeaaec8fc284e22c2756f380c05ea57b881a96b09f3af012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0200e1f5050000000017a9144eb3a361d8a15d7f6a8ef9d1cf44962a90c44d548702912b00000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac490e135d000000000000000000000000000000"
                          },
                          "type": "MakerPaymentSent"
                        },
                        "timestamp": 1561529938879
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 141365,
                            "coin": "PIZZA",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh"],
                            "internal_id": "7e0e38e31dbe80792ef320b8c0a7cb9259127427ef8c2fca1d796f24484046a5",
                            "my_balance_change": "0",
                            "received_by_me": "0",
                            "spent_by_me": "0",
                            "timestamp": 1561529960,
                            "to": [
                              "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                              "bUN5nesdt1xsAjCtAaYUnNbQhGqUWwQT1Q"
                            ],
                            "total_amount": "1.01999523",
                            "tx_hash": "7e0e38e31dbe80792ef320b8c0a7cb9259127427ef8c2fca1d796f24484046a5",
                            "tx_hex": "0400008085202f892082f6916932f9bf674a3fb00c3d5d765303ab68461f4abe0f91cc1162546914a9010000006b483045022100999b8bb0224476b5c344a466d0051ec7a8c312574ad8956a4177a42625cb86e302205a6664396bff3f2e6fe57adb7e082a26d1b8da9ee77b3fc24aa4148fdd5c84db012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffcad29a146b81bcaa44744efbec5149b6e3ca32bace140f75ad5794288d5bff6c000000006b483045022100b4dbfe88561c201fb8fbaf5bbf5bc0985893c909429c579425da84b02d23cc12022075f1e1e3eba38d167a6e84aac23faee5a2eb0799511e647213cee168529d4e5d012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffa13eeacd04b3e26ae3f41530b560c615dafa0fd4235cc5b22d48ab97e7c3399c000000006a47304402201158306fe668cbf56ad3f586dc83c1cda9efab44cef46da6bc0fe242292c85ed02201d622fe283410320e760233ae81dc53df65406b09fd07f8649f1775689219c35012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff4352b9f1f01dde4209b9e91076a3cfcabdaa23d9d5a313abfe7edb67ee4273e3000000006b483045022100825242fb3c6d460580016e93718ae1f43917e53abcc1558a64a6ab6f406763dd0220543936ce4c725e5e9f03831274a8475b535171bb29e1919fcf52ba2a9c85a553012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffcc0fa94b5973c893e61d470ae3982b0bedfd29cb0da2c60a362de438598f108c000000006b4830450221008c70a8e10ca37819e5a4d9783366e729e690d78f2fdd8a1f4812ddc14ec7d6ad022035ba8cb4d4e50684107f8af5c184582687b5d7dfda5d9be1bd45e45749c77f08012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffb0bd3bb9fedb7bbf49ca1612c955ba6095202186cef5be6952aed3dd32da4268000000006a4730440220592216d63c199faa587a4a6cbe11ca26027368a116b50818ce30eced59ca887202201bcafcf88f9f2632151596732f839d77cbe2f2243822c8551faffecc90b5dc19012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff65cf2831fc200e55aaacbe0881ad0edfb298ee6d4421b08b048aecc151716bd1000000006a47304402202032eb1ccebc3be4b94bae343d1d168e87040d2d20977c47d073d6bf490ef6c00220067656e00c4b8930167c54078609925cec7b893a52bcb9304e6b2602f564413e012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffeaf67880bee214acecc74b12f648c1014d6394c4abf99832d408981bb460e999000000006b483045022100b9ae1cc824149220ac517298e6f21c26939485b31d0ae19d97d986c5f8f34e4502200a90578cf2c1835dbea00484af1f225711c255f1d0a3208f2e4f1154f0db2c9a012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffad089c3fe7987a44f150f34b7ac66972de76dd84c739bdeddf360ab029dfd4d6000000006a473044022015f0386ed67a61626fbe5ae79e0d39d38e7b4072b648e8a26e23adadc0a8e5bc02202398188fa2feb26994e5c1e7e758788de3d5f0f0096f956a0cd58804710bea6a012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffd6c66730546c62dd003b5af1f1e5ecfd339c62db0169c1d499584e09a8a9b288000000006b4830450221008d4c73f0e3c9d913ba32fd864167649242e3e891412ab80bdd3f7ff43a238ee20220602738e98008b146256b51d0df99e222aa165f2ce351241ebc23d8a098e2b0db012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff12d9eff354f46cbd4446a0bff27a6a635ff5b1dc8a5dd8b0178bb5f89c9ec080000000006b48304502210098d3349ba9b13560748949933d2704663a5ab52cdc804afa1ac4da3e5992e0a002201525d7ad8466ad260219f3873fb7781addbd363f91e8063bfa86c7ed4e385b84012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff69e16767806ea5f069b7d46674f7aa747fcc6e541189ce7fcf92edcfd7642ff4000000006b4830450221008a5ebfe904c87f21947a44d8418190be5893993a683fde0f96df8a9487923da002205be1bbd8b518ba2f303cae23bc20806e84ffbba6a03f032385b15edb8df107f4012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640fffffffff4fbabd508178f553e676d67ce325796b03aa249b41a23c681c1ad9dedb45ae7000000006a47304402207cea6824abe1ce35e18954b858d45243e2cb57d27d782adc5b6b07ebd21a02d7022007ba0469b298c4b1a7c4a148fa16bae93d28593b34e197c10ac0d1faf9cc1bfa012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff14867aa59932d895be607fb7398f5594e39d9fa2e1c7daaed7b1390dbfdddcab000000006b4830450221009fb6e1885a3658c593809f95ecd2049f8ef9e00379686ac236b17312c9613d4c0220709fc50c9a920a19254389944db366c354708c19885d2479d9968fda0848f9f7012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff75777c692daaa21d216a1a2a7059203becfcdcf6793aa1259cdd7aadec957ab6000000006a47304402202945019860abf9b80e71f340320d114846efa4d2780ce12513e3983fb4d3f15b022019be008fb7368e3f1f022924dc7af1138b94041f46084dd27768bc8cacd1529f012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffca037b85742e93df4eef8e8ac3b8531321c8a8e21a4a941360866ea57a973665000000006a4730440220760283a7828edcc53671fc73e29c30cdc64d60d300292761d39730f0d09f94c202201e026293e3891a6fe46e40cd21778a41e21641a261a7fbf3bf75b034d9c788d9012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffa68edd030b4307ad87bfeff96a6db5b3ddd1a0901c488a4fe4d2093531896d75000000006b48304502210091a41e16b2c27d7ef6077e8de9df692b6013e61d72798ff9f7eba7fc983cdb65022034de29a0fb22a339e8044349913915444ab420772ab0ab423e44cfe073cb4e70012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff8c952791181993a7512e48d098a06e6197c993b83241a4bf1330c0e95f2c304d000000006b483045022100fa14b9301feb056f6e6b10446a660525cc1ff3e191b0c45f9e12dcd4f142422c02203f4a94f2a9d3ec0b74fac2156dd9b1addb8fa5b9a1cfc9e34b0802e88b1cbfa3012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff32bc4d014542abf328fecff29b9f4c243c3dd295fe42524b20bf591a3ddc26a1000000006a47304402206f92c4da6651c8959f7aed61608d26b9e46f5c1d69f4fc6e592b1f552b6067f102201c8cc221eac731867d15d483cc83322dba2f14f31d3efb26be937a68ad772394012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffbb3877248c26b23023d7dbb83a5f8293c65c5bff4ac47935a4a31248cefffd91000000006a47304402205bab19ad082a1918e18ccb6462edc263196fb88c8fdfd6bd07a0cf031a4637810220371a621c1bdc6b957db2447a92dcf87b0309653a2db480c9ed623f34a6e6d8a9012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff6415b7356c94609b9a7a7eb06e4c306896767abbc11399779f952fb9ae197059000000006b483045022100e2d038dbb9a873f5a58ec7901d6a7e79f1b404afea3d852056f4d0746cfb821102207fb274947b10d467cd71aa948e9a50f5f4430b661b27afc347efd9d6cc409d9c012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff1aeefdf80ec8a07d657ca64a2c0aa465f58e6284755c9a263c5a807be43b4b81000000006a47304402206e7ff765ba47a8785008f64f49c8e73232d582b2b2d0a49be0880c2557de8f8602206448423a6a37ad9740eb316513b31f73599ae14f65623709fb5443ae609f3e2e012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff3c091681df17b46f280bc9d8011c1bb31397637ce945b393f70380f8cd0a8b0d010000006a47304402206ca8717000f3086d364318f56d52e2369c40b88a1cb86455a8db262b4816698a02206711caf453bfda6b1b3542e27e68c3180f92f0548326d74e30b3ed18cd2c2353012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff91f32d98b581def165495aff6b69530e1f3de7f68fabfeb93730cf9793bbcd2a000000006a47304402200a8cd5e29ee7ff136772ea1789a39a027eaa1cd92f90f9d57fd8cf77202251f402203dd2bc282a838a5730e840a0d22b4f0edbe3cb2da00466c66bc2b5c66fc8b032012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff854d9226c28a1f5fe440e08f41000f3547f304ecf9cc010d0b5bc845ef1f039a000000006b483045022100fe6cce49975cc78af1c394bc02d995710833ba08cf7f8dd5f99add2cc7db26c40220793491309c215d8314a1c142bef7ec6b9a397249bec1c00a0a5ab47dfc1208b6012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff593bc907aa71f3b0f7aa8c48bb5f650595e65a5a733a9601a8374ed978eec9a7000000006a47304402206362ae3c4cf1a19ba0e43424b03af542077b49761172c1ad26d802f54b1b6ca602206bc7edb655bb0024c0e48c1f4c18c8864f8d1ce59ae55cd81dc0bd1234430691012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff3b9da8c5ab0c0cd6b40f602ea6ed8e36a48034b182b9d1a77ffebd15fe203b94000000006b483045022100f8610eae25899663cb5fa9a4575d937da57cdfd41958794bbb4c02f8bed75da40220262d40e019ec3a57b252f4150d509cce6f8a2dbd83184a9fc2ed56aba8018b15012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff0897c8a57e15e7f3893b195d65cf6c6001b29c8c9734213d7a3131f57b9eca2e000000006b483045022100c485cbd6408cf0759bcf23c4154249882934b522a93c6b49e62412305bf7646902201cc4b668af4bb22fe57c32c4d34e822bceb12f6bd6923afdabf4894752a56ec3012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffffdc7000f7c45b62960623fa3a277e8a55348a4fe4936fef1224b6953434a249000000006b4830450221008a51a9c26f475d5c0838afe9d51524f95adfb21a9b0a02eae31cb01dc0a31fab022071c5492fbc7270731d4a4947a69398bf99dd28c65bb69d19910bf53a515274c8012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff10ec2af7e31ca28e27177215904d9a59abf80f0652b24e3f749f14fb7b2264ec000000006b483045022100fe4269f8f5ca53ebcff6fb782142a6228f0e50498a531b7a9c0d54768af9854102207cc740a9ea359569b49d69a94215ce3e23aeda5779cebc434ad3d608e1752990012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff5e3830c088dd6ea412d778b0a700ef27c183cf03e19f3d6f71bc5eaf53b2c22e000000006b4830450221009788a7e7f2407ba2f7c504091fbdf8f8498367781e8a357616d68e2a6770b4e70220518c92f5fb21e6bfd7d870a783b2a5572ce003f2dbb237ec59df419c9a148966012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff51630ccb0ad32b24cc7ae1b3602950ba518dca6aa65ef560e57f08c23eed8d80000000006a47304402201aa556153ffeb13aa674353bf88c04a7af15c7eb32e1a835464e4b613c31dc2802200395858c29a46e9108de1f90b401ee26c296388b4073143b63f849b2cce461af012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff0200e1f5050000000017a914ab802c4d644be63fd1a72834ff63b650d6b5353987bb7e1e00000000001976a91464ae8510aac9546d5e7704e31ce177451386455588ac680e135d000000000000000000000000000000"
                          },
                          "type": "TakerPaymentReceived"
                        },
                        "timestamp": 1561529998938
                      },
                      {
                        "event": {
                          "type": "TakerPaymentWaitConfirmStarted"
                        },
                        "timestamp": 1561529998941
                      },
                      {
                        "event": {
                          "type": "TakerPaymentValidatedAndConfirmed"
                        },
                        "timestamp": 1561530000859
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 0,
                            "coin": "PIZZA",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["bUN5nesdt1xsAjCtAaYUnNbQhGqUWwQT1Q"],
                            "internal_id": "235f8e7ab3c9515a17fe8ee721ef971bbee273eb90baf70788edda7b73138c86",
                            "my_balance_change": "0.99999",
                            "received_by_me": "0.99999",
                            "spent_by_me": "0",
                            "timestamp": 0,
                            "to": ["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                            "total_amount": "1",
                            "tx_hash": "235f8e7ab3c9515a17fe8ee721ef971bbee273eb90baf70788edda7b73138c86",
                            "tx_hex": "0400008085202f8901a5464048246f791dca2f8cef2774125992cba7c0b820f32e7980be1de3380e7e00000000d8483045022100beca668a946fcad98da64cc56fa04edd58b4c239aa1362b4453857cc2e0042c90220606afb6272ef0773185ade247775103e715e85797816fbc204ec5128ac10a4b90120ea774bc94dce44c138920c6e9255e31d5645e60c0b64e9a059ab025f1dd2fdc6004c6b6304692c135db1752102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac6782012088a914eb78e2f0cf001ed7dc69276afd37b25c4d6bb491882102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac68ffffffff0118ddf505000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac8000135d000000000000000000000000000000"
                          },
                          "type": "TakerPaymentSpent"
                        },
                        "timestamp": 1561530003429
                      },
                      {
                        "event": {
                          "type": "Finished"
                        },
                        "timestamp": 1561530003433
                      }
                    ],
                    "my_info": {
                      "my_amount": "1",
                      "my_coin": "BEER",
                      "other_amount": "1",
                      "other_coin": "PIZZA",
                      "started_at": 1561529842
                    },
                    "success_events": [
                      "Started",
                      "Negotiated",
                      "TakerFeeValidated",
                      "MakerPaymentSent",
                      "TakerPaymentReceived",
                      "TakerPaymentWaitConfirmStarted",
                      "TakerPaymentValidatedAndConfirmed",
                      "TakerPaymentSpent",
                      "Finished"
                    ],
                    "type": "Maker",
                    "uuid": "6bf6e313-e610-4a9a-ba8c-57fc34a124aa"
                  },
                  {
                    "error_events": [
                      "StartFailed",
                      "NegotiateFailed",
                      "TakerFeeSendFailed",
                      "MakerPaymentValidateFailed",
                      "TakerPaymentTransactionFailed",
                      "TakerPaymentDataSendFailed",
                      "TakerPaymentWaitForSpendFailed",
                      "MakerPaymentSpendFailed",
                      "TakerPaymentRefunded",
                      "TakerPaymentRefundFailed"
                    ],
                    "events": [
                      {
                        "event": {
                          "data": {
                            "lock_duration": 31200,
                            "maker": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                            "maker_amount": "0.01",
                            "maker_coin": "BEER",
                            "maker_coin_start_block": 154187,
                            "maker_payment_confirmations": 1,
                            "maker_payment_wait": 1561492367,
                            "my_persistent_pub": "02031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3",
                            "started_at": 1561481967,
                            "taker_amount": "0.01",
                            "taker_coin": "BCH",
                            "taker_coin_start_block": 588576,
                            "taker_payment_confirmations": 1,
                            "taker_payment_lock": 1561513167,
                            "uuid": "491df802-43c3-4c73-85ef-1c4c49315ac6"
                          },
                          "type": "Started"
                        },
                        "timestamp": 1561481968393
                      },
                      {
                        "event": {
                          "data": {
                            "maker_payment_locktime": 1561544367,
                            "maker_pubkey": "02631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640",
                            "secret_hash": "ba5128bcca5a2f7d2310054fb8ec51b80f352ef3"
                          },
                          "type": "Negotiated"
                        },
                        "timestamp": 1561482029079
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 0,
                            "coin": "BCH",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji"],
                            "internal_id": "9dd7c0c8124315d7884fb0c7bf8dbfd3f3bd185c62a2ee42dfbc1e3b74f21a0e",
                            "my_balance_change": "0.00002287",
                            "received_by_me": "0.0155402",
                            "spent_by_me": "0.01556307",
                            "timestamp": 0,
                            "to": [
                              "1KRhTPvoxyJmVALwHFXZdeeWFbcJSbkFPu",
                              "1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji"
                            ],
                            "total_amount": "0.01556307",
                            "tx_hash": "9dd7c0c8124315d7884fb0c7bf8dbfd3f3bd185c62a2ee42dfbc1e3b74f21a0e",
                            "tx_hex": "0100000001f1beda7feba9fa5c52aa38027587db50b6428bbbcc053cd4ab17461fb00b89d1000000006a473044022004ad0330210e20dea416c3ff442e50dc59970c5d1a8b4d0a7d5cc61a2edc701602204459e1ee6774f1ba8258322fff72e1e1acddeb7aed2f75657458aa3deecc9465412102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0207050000000000001976a914ca1e04745e8ca0c60d8c5881531d51bec470743f88ac64b61700000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac2d53125d"
                          },
                          "type": "TakerFeeSent"
                        },
                        "timestamp": 1561482032294
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 154190,
                            "coin": "BEER",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh"],
                            "internal_id": "ba36c890785e3e9d4b853310ad4d79ce8175e7c4184a398128b37339321672f4",
                            "my_balance_change": "0",
                            "received_by_me": "0",
                            "spent_by_me": "0",
                            "timestamp": 1561482056,
                            "to": [
                              "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                              "bF2S8qwenfVZbvUU6dWyV3oXMxEP7sHLbr"
                            ],
                            "total_amount": "0.99999",
                            "tx_hash": "ba36c890785e3e9d4b853310ad4d79ce8175e7c4184a398128b37339321672f4",
                            "tx_hex": "0400008085202f890197f703d245127e5b88471791f2820d29152046f4be133907afa8ac5542911190000000006b48304502210090e1c52aa2eba12b7c71fceab83b77f1456830a3dee1b956a831ecee5b5b353602205353a48c0129eae44b7c06a1f1651b9ceb8642374a1d5224a1e907240a978ad2012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff0240420f000000000017a914192f34528c6c8cd11eefebec27f195f3894eb11187f096e605000000001976a91464ae8510aac9546d5e7704e31ce177451386455588ac4353125d000000000000000000000000000000"
                          },
                          "type": "MakerPaymentReceived"
                        },
                        "timestamp": 1561482073479
                      },
                      {
                        "event": {
                          "type": "MakerPaymentWaitConfirmStarted"
                        },
                        "timestamp": 1561482073482
                      },
                      {
                        "event": {
                          "type": "MakerPaymentValidatedAndConfirmed"
                        },
                        "timestamp": 1561482074296
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 0,
                            "coin": "BCH",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji"],
                            "internal_id": "bc98def88d93c270ae3cdb8a098d1b939ca499bf98f7a22b97be36bca13cdbc7",
                            "my_balance_change": "-0.01001",
                            "received_by_me": "0.0055302",
                            "spent_by_me": "0.0155402",
                            "timestamp": 0,
                            "to": [
                              "1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji",
                              "31k5nkp5G9QHq3zZFFba6Kq3m5FEHstkrd"
                            ],
                            "total_amount": "0.0155402",
                            "tx_hash": "bc98def88d93c270ae3cdb8a098d1b939ca499bf98f7a22b97be36bca13cdbc7",
                            "tx_hex": "01000000010e1af2743b1ebcdf42eea2625c18bdf3d3bf8dbfc7b04f88d7154312c8c0d79d010000006a4730440220030266d6d6435a4772cce2cebd91b6d4afffb920e23e9bc761434f105349cda002202335a050e2f28e4ca28862868141d3d7b553f3d30bceb83724ad70a32d04b0bd412102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0240420f000000000017a9140094798ed4100852f10a9ad85990f19b364f4c2d873c700800000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac5a53125d"
                          },
                          "type": "TakerPaymentSent"
                        },
                        "timestamp": 1561482078908
                      },
                      {
                        "event": {
                          "data": {
                            "secret": "66ed6c24bbb4892634eac4ce1e1ad0627d6379da4443b8d656b64d49ef2aa7a3",
                            "transaction": {
                              "block_height": 0,
                              "coin": "BCH",
                              "fee_details": {
                                "amount": "0.00001"
                              },
                              "from": ["31k5nkp5G9QHq3zZFFba6Kq3m5FEHstkrd"],
                              "internal_id": "eec643315d4495aa5feb5062344fe2474223dc0f231b610afd336f908ae99ebc",
                              "my_balance_change": "0",
                              "received_by_me": "0",
                              "spent_by_me": "0",
                              "timestamp": 0,
                              "to": ["1ABMe2m1XphME4gaZNcjQFdJc6ttu2Gbz2"],
                              "total_amount": "0.01",
                              "tx_hash": "eec643315d4495aa5feb5062344fe2474223dc0f231b610afd336f908ae99ebc",
                              "tx_hex": "0100000001c7db3ca1bc36be972ba2f798bf99a49c931b8d098adb3cae70c2938df8de98bc00000000d747304402202e344f8c61f2f49f4d620d687d02448cfba631a8ce8c0f8ee774da177230a75902201f4a175e7fa40f26896f522b5c51c7c0485e0ad18d3221c885e8b96b52ed1cab412066ed6c24bbb4892634eac4ce1e1ad0627d6379da4443b8d656b64d49ef2aa7a3004c6b6304cfcc125db1752102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac6782012088a914ba5128bcca5a2f7d2310054fb8ec51b80f352ef3882102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac68ffffffff01583e0f00000000001976a91464ae8510aac9546d5e7704e31ce177451386455588acfd49125d"
                            }
                          },
                          "type": "TakerPaymentSpent"
                        },
                        "timestamp": 1561483355081
                      },
                      {
                        "event": {
                          "data": {
                            "block_height": 0,
                            "coin": "BEER",
                            "fee_details": {
                              "amount": "0.00001"
                            },
                            "from": ["bF2S8qwenfVZbvUU6dWyV3oXMxEP7sHLbr"],
                            "internal_id": "858f07d0a4e74318497a6e3ff4d7b68b60ad21b5c8e90b9b485f0ddaed71d0dc",
                            "my_balance_change": "0.00999",
                            "received_by_me": "0.00999",
                            "spent_by_me": "0",
                            "timestamp": 0,
                            "to": ["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                            "total_amount": "0.01",
                            "tx_hash": "858f07d0a4e74318497a6e3ff4d7b68b60ad21b5c8e90b9b485f0ddaed71d0dc",
                            "tx_hex": "0400008085202f8901f47216323973b32881394a18c4e77581ce794dad1033854b9d3e5e7890c836ba00000000d8483045022100847a65faed4bea33c5cbccff2bee7c1292871a3b130bd2f23e696bd80c07365f02202039ea02b4463afd4f1e2b20b348d64b40aaea165f8dfb483293e2b368d536fe012066ed6c24bbb4892634eac4ce1e1ad0627d6379da4443b8d656b64d49ef2aa7a3004c6b6304af46135db1752102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac6782012088a914ba5128bcca5a2f7d2310054fb8ec51b80f352ef3882102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac68ffffffff01583e0f00000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac4b4a125d000000000000000000000000000000"
                          },
                          "type": "MakerPaymentSpent"
                        },
                        "timestamp": 1561483358319
                      },
                      {
                        "event": {
                          "type": "Finished"
                        },
                        "timestamp": 1561483358321
                      }
                    ],
                    "my_info": {
                      "my_amount": "0.01",
                      "my_coin": "BCH",
                      "other_amount": "0.01",
                      "other_coin": "BEER",
                      "started_at": 1561481967
                    },
                    "success_events": [
                      "Started",
                      "Negotiated",
                      "TakerFeeSent",
                      "MakerPaymentReceived",
                      "MakerPaymentWaitConfirmStarted",
                      "MakerPaymentValidatedAndConfirmed",
                      "TakerPaymentSent",
                      "TakerPaymentSpent",
                      "MakerPaymentSpent",
                      "Finished"
                    ],
                    "type": "Taker",
                    "uuid": "491df802-43c3-4c73-85ef-1c4c49315ac6"
                  }
                ],
                "total": 49
              }
            }
      ''', 200));
      expect(await ApiProvider().getRecentSwaps(client, body),
          const TypeMatcher<RecentSwaps>());
    });
  });

  group('my_tx_history', () {
    final MockClient client = MockClient();

    final GetTxHistory body = GetTxHistory(userpass: 'test');

    test('returns a Transactions if the http call completes successfully',
        () async {
      when(client.post(url, body: getTxHistoryToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result":{
                "current_block":172418,
                "from_id":null,
                "limit":1,
                "skipped":0,
                "sync_status":{
                  "additional_info":{
                    "transactions_left":126
                  },
                  "state":"InProgress"
                },
                "total":5915,
                "transactions":[
                  {
                    "block_height":172409,
                    "coin":"ETOMIC",
                    "confirmations":10,
                    "fee_details":{
                      "amount":"0.00001"
                    },
                    "from":[
                      "R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"
                    ],
                    "internal_id":"903e5d71b8717205314a71055fe8bbb868e7b76d001fbe813a34bd71ff131e93",
                    "my_balance_change":"-0.10001",
                    "received_by_me":"0.8998513",
                    "spent_by_me":"0.9998613",
                    "timestamp":1566539526,
                    "to":[
                      "R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW",
                      "bJrMTiiRiLHJHc6RKQgesKTg1o9VVuKwT5"
                    ],
                    "total_amount":"0.9998613",
                    "tx_hash":"903e5d71b8717205314a71055fe8bbb868e7b76d001fbe813a34bd71ff131e93",
                    "tx_hex":"0400008085202f8901a242dc691de64c732e823ed0a4d8cfa6a230f8e31bc9bd21499009f1a90b855a010000006b483045022100d83113119004ac0504f812a853a831039dfc4b0bc1cb863d2c7a94c0670f07e902206af87b846b18c0d5e38bd874d43918e0400e4b6b838ab0793f5976843daa20cd012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff02809698000000000017a9144327a5516b28f66249576c18d15debf6dfbd1124876a105d05000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac047f5f5d000000000000000000000000000000"
                  }
                ]
              }
            }
      ''', 200));
      expect(await ApiProvider().getTransactions(client, body),
          const TypeMatcher<Transactions>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getTxHistoryToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "lp_coins:1011] from_id 1d5c1b67f8ebd3fc480e25a1d60791bece278f5d1245c5f9474c91a142fee8e2 is not found"
            }
      ''', 200));
      expect(await ApiProvider().getTransactions(client, body),
          const TypeMatcher<ErrorString>());
    });
  });

  group('setprice', () {
    final MockClient client = MockClient();

    final GetSetPrice body = GetSetPrice(userpass: 'test');

    test('returns a SetPriceResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getSetPriceToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": {
                "base": "BASE",
                "rel": "REL",
                "max_base_vol": "1",
                "min_base_vol": "0",
                "created_at": 1559052299258,
                "matches": {},
                "price": "1",
                "started_swaps": [],
                "uuid": "6a242691-6c05-474a-85c1-5b3f42278f41"
              }
            }
      ''', 200));
      expect(await ApiProvider().postSetPrice(client, body),
          const TypeMatcher<SetPriceResponse>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getSetPriceToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "Rel coin REL is not found"
            }
      ''', 200));
      expect(await ApiProvider().postSetPrice(client, body),
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

    test('returns a ActiveCoin if the http call completes successfully',
        () async {
      when(client.post(url,
              body: ApiProvider().getBodyActiveCoin(coinToActiveERC)))
          .thenAnswer((_) async => http.Response('''
            {
              "coin": "HELLOWORLD",
              "address": "RQNUR7qLgPUgZxYbvU9x5Kw93f6LU898CQ",
              "balance": "10",
              "locked_by_swaps": "0",
              "required_confirmations":1,
              "result": "success"
            }
      ''', 200));
      expect(await ApiProvider().activeCoin(client, coinToActiveERC),
          const TypeMatcher<ActiveCoin>());
    });

    test('returns a ActiveCoin if the http call completes successfully',
        () async {
      when(client.post(url,
              body: ApiProvider().getBodyActiveCoin(coinToActive)))
          .thenAnswer((_) async => http.Response('''
            {
              "coin": "HELLOWORLD",
              "address": "RQNUR7qLgPUgZxYbvU9x5Kw93f6LU898CQ",
              "balance": "10",
              "locked_by_swaps": "0",
              "required_confirmations":1,
              "result": "success"
            }
      ''', 200));
      expect(await ApiProvider().activeCoin(client, coinToActive),
          const TypeMatcher<ActiveCoin>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url,
              body: ApiProvider().getBodyActiveCoin(coinToActive)))
          .thenAnswer((_) async => http.Response('''
            {
              "error":"lp_coins:943] lp_coins:693] mm2 param is not set neither in coins config nor enable request, assuming that coin is not supported"
            }
      ''', 200));
      expect(await ApiProvider().activeCoin(client, coinToActive),
          const TypeMatcher<ErrorString>());
    });
  });

  group('postSell', () {
    final MockClient client = MockClient();

    final GetBuySell body = GetBuySell(userpass: 'test', method: 'sell');

    test('returns a BuyResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": {
                "action": "Sell",
                "base": "BASE",
                "base_amount": "1",
                "dest_pub_key": "0000000000000000000000000000000000000000000000000000000000000000",
                "method": "request",
                "rel": "REL",
                "rel_amount": "1",
                "sender_pubkey": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                "uuid": "d14452bb-e82d-44a0-86b0-10d4cdcb8b24"
              }
            }
      ''', 200));
      expect(await ApiProvider().postSell(client, body),
          const TypeMatcher<BuyResponse>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "rpc:278] utxo:884] BASE balance 12.88892991 is too low, required 21.15"
            }
      ''', 200));
      expect(await ApiProvider().postSell(client, body),
          const TypeMatcher<ErrorString>());
    });
  });

  group('postBuy', () {
    final MockClient client = MockClient();

    final GetBuySell body = GetBuySell(userpass: 'test', method: 'buy');

    test('returns a BuyResponse if the http call completes successfully',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": {
                "action": "Buy",
                "base": "BASE",
                "base_amount": "1",
                "dest_pub_key": "0000000000000000000000000000000000000000000000000000000000000000",
                "method": "request",
                "rel": "REL",
                "rel_amount": "1",
                "sender_pubkey": "c213230771ebff769c58ade63e8debac1b75062ead66796c8d793594005f3920",
                "uuid": "d14452bb-e82d-44a0-86b0-10d4cdcb8b24"
              }
            }
      ''', 200));
      expect(await ApiProvider().postBuy(client, body),
          const TypeMatcher<BuyResponse>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBuyToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "rpc:278] utxo:884] BASE balance 12.88892991 is too low, required 21.15"
            }
      ''', 200));
      expect(await ApiProvider().postBuy(client, body),
          const TypeMatcher<ErrorString>());
    });
  });

  group('my_balance', () {
    final MockClient client = MockClient();

    final GetBalance body = GetBalance(userpass: 'test');

    test('returns a Balance if the http call completes successfully', () async {
      when(client.post(url, body: getBalanceToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "address":"R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW",
              "balance":"60.00253836",
              "coin":"HELLOWORLD",
              "locked_by_swaps":"0"
            }
      ''', 200));
      expect(await ApiProvider().getBalance(client, body),
          const TypeMatcher<Balance>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getBalanceToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "some error description"
            }
      ''', 200));
      expect(await ApiProvider().getBalance(client, body),
          const TypeMatcher<ErrorString>());
    });
  });

  group('orderbook', () {
    final MockClient client = MockClient();

    final GetOrderbook body = GetOrderbook(userpass: 'test');

    test('returns a Balance if the http call completes successfully', () async {
      when(client.post(url, body: getOrderbookToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "bids": [],
              "numbids": 0,
              "biddepth": 0,
              "asks": [
                {
                  "coin": "HELLO",
                  "address": "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                  "price": "0.89999998",
                  "numutxos": 0,
                  "avevolume": 0,
                  "maxvolume": 10855.85028615,
                  "depth": 0,
                  "pubkey": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                  "age": 11,
                  "zcredits": 0
                }
              ],
              "numasks": 1,
              "askdepth": 0,
              "base": "HELLO",
              "rel": "WORLD",
              "timestamp": 1549327944,
              "netid": 9999
            }
      ''', 200));
      expect(await ApiProvider().getOrderbook(client, body),
          const TypeMatcher<Orderbook>());
    });
  });

  group('my_swap_status', () {
    final MockClient client = MockClient();

    final GetSwap body = GetSwap(userpass: 'test');

    test('returns a Swap if the http call completes successfully (Taker swap)',
        () async {
      when(client.post(url, body: getSwapToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "result": {
                "error_events": [
                  "StartFailed",
                  "NegotiateFailed",
                  "TakerFeeSendFailed",
                  "MakerPaymentValidateFailed",
                  "TakerPaymentTransactionFailed",
                  "TakerPaymentDataSendFailed",
                  "TakerPaymentWaitForSpendFailed",
                  "MakerPaymentSpendFailed",
                  "TakerPaymentRefunded",
                  "TakerPaymentRefundFailed"
                ],
                "events": [
                  {
                    "event": {
                      "data": {
                        "lock_duration": 31200,
                        "maker": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                        "maker_amount": "0.01",
                        "maker_coin": "BEER",
                        "maker_coin_start_block": 154187,
                        "maker_payment_confirmations": 1,
                        "maker_payment_wait": 1561492367,
                        "my_persistent_pub": "02031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3",
                        "started_at": 1561481967,
                        "taker_amount": "0.01",
                        "taker_coin": "BCH",
                        "taker_coin_start_block": 588576,
                        "taker_payment_confirmations": 1,
                        "taker_payment_lock": 1561513167,
                        "uuid": "491df802-43c3-4c73-85ef-1c4c49315ac6"
                      },
                      "type": "Started"
                    },
                    "timestamp": 1561481968393
                  },
                  {
                    "event": {
                      "data": {
                        "maker_payment_locktime": 1561544367,
                        "maker_pubkey": "02631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640",
                        "secret_hash": "ba5128bcca5a2f7d2310054fb8ec51b80f352ef3"
                      },
                      "type": "Negotiated"
                    },
                    "timestamp": 1561482029079
                  },
                  {
                    "event": {
                      "data": {
                        "block_height": 0,
                        "coin": "BCH",
                        "fee_details": {
                          "amount": "0.00001"
                        },
                        "from": ["1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji"],
                        "internal_id": "9dd7c0c8124315d7884fb0c7bf8dbfd3f3bd185c62a2ee42dfbc1e3b74f21a0e",
                        "my_balance_change": "0.00002287",
                        "received_by_me": "0.0155402",
                        "spent_by_me": "0.01556307",
                        "timestamp": 0,
                        "to": [
                          "1KRhTPvoxyJmVALwHFXZdeeWFbcJSbkFPu",
                          "1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji"
                        ],
                        "total_amount": "0.01556307",
                        "tx_hash": "9dd7c0c8124315d7884fb0c7bf8dbfd3f3bd185c62a2ee42dfbc1e3b74f21a0e",
                        "tx_hex": "0100000001f1beda7feba9fa5c52aa38027587db50b6428bbbcc053cd4ab17461fb00b89d1000000006a473044022004ad0330210e20dea416c3ff442e50dc59970c5d1a8b4d0a7d5cc61a2edc701602204459e1ee6774f1ba8258322fff72e1e1acddeb7aed2f75657458aa3deecc9465412102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0207050000000000001976a914ca1e04745e8ca0c60d8c5881531d51bec470743f88ac64b61700000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac2d53125d"
                      },
                      "type": "TakerFeeSent"
                    },
                    "timestamp": 1561482032294
                  },
                  {
                    "event": {
                      "data": {
                        "block_height": 154190,
                        "coin": "BEER",
                        "fee_details": {
                          "amount": "0.00001"
                        },
                        "from": ["RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh"],
                        "internal_id": "ba36c890785e3e9d4b853310ad4d79ce8175e7c4184a398128b37339321672f4",
                        "my_balance_change": "0",
                        "received_by_me": "0",
                        "spent_by_me": "0",
                        "timestamp": 1561482056,
                        "to": [
                          "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                          "bF2S8qwenfVZbvUU6dWyV3oXMxEP7sHLbr"
                        ],
                        "total_amount": "0.99999",
                        "tx_hash": "ba36c890785e3e9d4b853310ad4d79ce8175e7c4184a398128b37339321672f4",
                        "tx_hex": "0400008085202f890197f703d245127e5b88471791f2820d29152046f4be133907afa8ac5542911190000000006b48304502210090e1c52aa2eba12b7c71fceab83b77f1456830a3dee1b956a831ecee5b5b353602205353a48c0129eae44b7c06a1f1651b9ceb8642374a1d5224a1e907240a978ad2012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff0240420f000000000017a914192f34528c6c8cd11eefebec27f195f3894eb11187f096e605000000001976a91464ae8510aac9546d5e7704e31ce177451386455588ac4353125d000000000000000000000000000000"
                      },
                      "type": "MakerPaymentReceived"
                    },
                    "timestamp": 1561482073479
                  },
                  {
                    "event": {
                      "type": "MakerPaymentWaitConfirmStarted"
                    },
                    "timestamp": 1561482073482
                  },
                  {
                    "event": {
                      "type": "MakerPaymentValidatedAndConfirmed"
                    },
                    "timestamp": 1561482074296
                  },
                  {
                    "event": {
                      "data": {
                        "block_height": 0,
                        "coin": "BCH",
                        "fee_details": {
                          "amount": "0.00001"
                        },
                        "from": ["1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji"],
                        "internal_id": "bc98def88d93c270ae3cdb8a098d1b939ca499bf98f7a22b97be36bca13cdbc7",
                        "my_balance_change": "-0.01001",
                        "received_by_me": "0.0055302",
                        "spent_by_me": "0.0155402",
                        "timestamp": 0,
                        "to": [
                          "1WxswvLF2HdaDr4k77e92VjaXuPQA8Uji",
                          "31k5nkp5G9QHq3zZFFba6Kq3m5FEHstkrd"
                        ],
                        "total_amount": "0.0155402",
                        "tx_hash": "bc98def88d93c270ae3cdb8a098d1b939ca499bf98f7a22b97be36bca13cdbc7",
                        "tx_hex": "01000000010e1af2743b1ebcdf42eea2625c18bdf3d3bf8dbfc7b04f88d7154312c8c0d79d010000006a4730440220030266d6d6435a4772cce2cebd91b6d4afffb920e23e9bc761434f105349cda002202335a050e2f28e4ca28862868141d3d7b553f3d30bceb83724ad70a32d04b0bd412102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0240420f000000000017a9140094798ed4100852f10a9ad85990f19b364f4c2d873c700800000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac5a53125d"
                      },
                      "type": "TakerPaymentSent"
                    },
                    "timestamp": 1561482078908
                  },
                  {
                    "event": {
                      "data": {
                        "secret": "66ed6c24bbb4892634eac4ce1e1ad0627d6379da4443b8d656b64d49ef2aa7a3",
                        "transaction": {
                          "block_height": 0,
                          "coin": "BCH",
                          "fee_details": {
                            "amount": "0.00001"
                          },
                          "from": ["31k5nkp5G9QHq3zZFFba6Kq3m5FEHstkrd"],
                          "internal_id": "eec643315d4495aa5feb5062344fe2474223dc0f231b610afd336f908ae99ebc",
                          "my_balance_change": "0",
                          "received_by_me": "0",
                          "spent_by_me": "0",
                          "timestamp": 0,
                          "to": ["1ABMe2m1XphME4gaZNcjQFdJc6ttu2Gbz2"],
                          "total_amount": "0.01",
                          "tx_hash": "eec643315d4495aa5feb5062344fe2474223dc0f231b610afd336f908ae99ebc",
                          "tx_hex": "0100000001c7db3ca1bc36be972ba2f798bf99a49c931b8d098adb3cae70c2938df8de98bc00000000d747304402202e344f8c61f2f49f4d620d687d02448cfba631a8ce8c0f8ee774da177230a75902201f4a175e7fa40f26896f522b5c51c7c0485e0ad18d3221c885e8b96b52ed1cab412066ed6c24bbb4892634eac4ce1e1ad0627d6379da4443b8d656b64d49ef2aa7a3004c6b6304cfcc125db1752102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac6782012088a914ba5128bcca5a2f7d2310054fb8ec51b80f352ef3882102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac68ffffffff01583e0f00000000001976a91464ae8510aac9546d5e7704e31ce177451386455588acfd49125d"
                        }
                      },
                      "type": "TakerPaymentSpent"
                    },
                    "timestamp": 1561483355081
                  },
                  {
                    "event": {
                      "data": {
                        "block_height": 0,
                        "coin": "BEER",
                        "fee_details": {
                          "amount": "0.00001"
                        },
                        "from": ["bF2S8qwenfVZbvUU6dWyV3oXMxEP7sHLbr"],
                        "internal_id": "858f07d0a4e74318497a6e3ff4d7b68b60ad21b5c8e90b9b485f0ddaed71d0dc",
                        "my_balance_change": "0.00999",
                        "received_by_me": "0.00999",
                        "spent_by_me": "0",
                        "timestamp": 0,
                        "to": ["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                        "total_amount": "0.01",
                        "tx_hash": "858f07d0a4e74318497a6e3ff4d7b68b60ad21b5c8e90b9b485f0ddaed71d0dc",
                        "tx_hex": "0400008085202f8901f47216323973b32881394a18c4e77581ce794dad1033854b9d3e5e7890c836ba00000000d8483045022100847a65faed4bea33c5cbccff2bee7c1292871a3b130bd2f23e696bd80c07365f02202039ea02b4463afd4f1e2b20b348d64b40aaea165f8dfb483293e2b368d536fe012066ed6c24bbb4892634eac4ce1e1ad0627d6379da4443b8d656b64d49ef2aa7a3004c6b6304af46135db1752102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac6782012088a914ba5128bcca5a2f7d2310054fb8ec51b80f352ef3882102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac68ffffffff01583e0f00000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac4b4a125d000000000000000000000000000000"
                      },
                      "type": "MakerPaymentSpent"
                    },
                    "timestamp": 1561483358319
                  },
                  {
                    "event": {
                      "type": "Finished"
                    },
                    "timestamp": 1561483358321
                  }
                ],
                "my_info": {
                  "my_amount": "0.01",
                  "my_coin": "BCH",
                  "other_amount": "0.01",
                  "other_coin": "BEER",
                  "started_at": 1561481967
                },
                "success_events": [
                  "Started",
                  "Negotiated",
                  "TakerFeeSent",
                  "MakerPaymentReceived",
                  "MakerPaymentWaitConfirmStarted",
                  "MakerPaymentValidatedAndConfirmed",
                  "TakerPaymentSent",
                  "TakerPaymentSpent",
                  "MakerPaymentSpent",
                  "Finished"
                ],
                "type": "Taker",
                "uuid": "491df802-43c3-4c73-85ef-1c4c49315ac6"
              }
            }
      ''', 200));
      expect(await ApiProvider().getSwapStatus(client, body),
          const TypeMatcher<Swap>());
    });

    test('returns a Swap if the http call completes successfully (Maker swap)',
        () async {
      when(client.post(url, body: getSwapToJson(body)))
          .thenAnswer((_) async => http.Response('''
          {
            "result": {
              "error_events": [
                "StartFailed",
                "NegotiateFailed",
                "TakerFeeValidateFailed",
                "MakerPaymentTransactionFailed",
                "MakerPaymentDataSendFailed",
                "TakerPaymentValidateFailed",
                "TakerPaymentSpendFailed",
                "MakerPaymentRefunded",
                "MakerPaymentRefundFailed"
              ],
              "events": [
                {
                  "event": {
                    "data": {
                      "lock_duration": 7800,
                      "maker_amount": "1",
                      "maker_coin": "BEER",
                      "maker_coin_start_block": 154221,
                      "maker_payment_confirmations": 1,
                      "maker_payment_lock": 1561545442,
                      "my_persistent_pub": "02031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3",
                      "secret": "ea774bc94dce44c138920c6e9255e31d5645e60c0b64e9a059ab025f1dd2fdc6",
                      "started_at": 1561529842,
                      "taker": "5a2f1c468b7083c4f7649bf68a50612ffe7c38b1d62e1ece3829ca88e7e7fd12",
                      "taker_amount": "1",
                      "taker_coin": "PIZZA",
                      "taker_coin_start_block": 141363,
                      "taker_payment_confirmations": 1,
                      "uuid": "6bf6e313-e610-4a9a-ba8c-57fc34a124aa"
                    },
                    "type": "Started"
                  },
                  "timestamp": 1561529842866
                },
                {
                  "event": {
                    "data": {
                      "taker_payment_locktime": 1561537641,
                      "taker_pubkey": "02631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640"
                    },
                    "type": "Negotiated"
                  },
                  "timestamp": 1561529883208
                },
                {
                  "event": {
                    "data": {
                      "block_height": 141364,
                      "coin": "PIZZA",
                      "fee_details": {
                        "amount": "0.00001"
                      },
                      "from": ["RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh"],
                      "internal_id": "a91469546211cc910fbe4a1f4668ab0353765d3d0cb03f4a67bff9326991f682",
                      "my_balance_change": "0",
                      "received_by_me": "0",
                      "spent_by_me": "0",
                      "timestamp": 1561529907,
                      "to": [
                        "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                        "RThtXup6Zo7LZAi8kRWgjAyi1s4u6U9Cpf"
                      ],
                      "total_amount": "0.002",
                      "tx_hash": "a91469546211cc910fbe4a1f4668ab0353765d3d0cb03f4a67bff9326991f682",
                      "tx_hex": "0400008085202f89021c7eeec33f8eb5ff2ed6c3d09e40e04b05a9674ea2feefcc12de3f9dcc16aff8000000006b483045022100e18e3d1afa8a24ecec82c92bfc05c119bfacdbb71b5f5663a4b96cc2a41ab269022017a79a1a1f6e0220d8fa1d2cf3b1c9788272f1ad18e4987b8f1cd4418acaa5b0012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff6a0d321eb52c3c7165adf80f83b15b7a5caa3a0dfa87746239021600d47fb43e000000006b483045022100937ed900e084d57d5e3341499fc66c5574884ca71cd4331fa696c8b7a517591b02201f5f851f94c3ca0ffb4789f1af22cb95dc83564e127ed7d23f1129eb2b981a2f012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff02bcf60100000000001976a914ca1e04745e8ca0c60d8c5881531d51bec470743f88ac9c120100000000001976a91464ae8510aac9546d5e7704e31ce177451386455588ac2f0e135d000000000000000000000000000000"
                    },
                    "type": "TakerFeeValidated"
                  },
                  "timestamp": 1561529927879
                },
                {
                  "event": {
                    "data": {
                      "block_height": 0,
                      "coin": "BEER",
                      "fee_details": {
                        "amount": "0.00001"
                      },
                      "from": ["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                      "internal_id": "efa90a2918e6793c8a2725c06ee34d0fa76c43bc85e680be195414e7aee36154",
                      "my_balance_change": "-1.00001",
                      "received_by_me": "0.0285517",
                      "spent_by_me": "1.0285617",
                      "timestamp": 0,
                      "to": [
                        "R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW",
                        "bKuQbg7vgFR1C25vPqMq8ePnB25cUEAGpo"
                      ],
                      "total_amount": "1.0285617",
                      "tx_hash": "efa90a2918e6793c8a2725c06ee34d0fa76c43bc85e680be195414e7aee36154",
                      "tx_hex": "0400008085202f890cdcd071edda0d5f489b0be9c8b521ad608bb6d7f43f6e7a491843e7a4d0078f85000000006b483045022100fbc3bd09f8e1821ed671d1b1d2ed355833fb42c0bc435fef2da5c5b0a980b9a002204ef92b35576069d640ca0ac08f46645e5ade36afd5f19fb6aad19cfc9fb221fb012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffe6ae2a3ce221a6612d9e640bdbe10a2e477b3bc68a1aeee4a6784cb18648a785010000006a47304402202000a7e60ae2ce1529247875623ef2c5b42448dcaeac8de0f8f0e2f8e5bd8a6b0220426321a004b793172014f522efbca77a3dc92e86ce0a75330d8ceb83072ad4e7012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff9335553edcbac9559cae517a3e25b880a48fabf661c4ac338394972eef4572da000000006b4830450221008ded7230f2fb37a42b94f96174ec192baf4cd9e9e68fb9b6cf0463a36a6093e00220538de51ceda1617f3964a2350802377940fdfa018cc1043d77c66081b1cab0c4012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3fffffffff91b5d3733877f84108de77fec46bee156766e1a6837fa7b580ccbc3905acb14000000006b483045022100d07cf1fd20e07aafdc942ba56f6b45baee61b93145a2bdba391e2cdb8024bf15022056ea8183990703ef05018df2fe8bd5ec678ec0f9207b0283292b2cdafc5e1e0c012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff147870387ca938b2b6e7daa96ba2496014f125c0e4e576273ef36ee8186c415a000000006a47304402204c5b15b641d7e34444456d2ea6663bdc8bd8216e309a7220814474f346b8425e0220634d1dd943b416b7a807704d7f7a3d46a60d88ef4e20734588a0b302c55fa82d012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffd2b954ae9b4a61fad9f7bc956d24e38d7b6fe313da824bd3bd91287d5a6b49d9000000006b483045022100a7387d9ab7b2c92d3cbce525e96ffac5ae3ef14f848661741ada0db17715c4a002202c1417d5e3e04b1a2d1774a83bb8d5aa1c0536c100138123089fa69921b5d976012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff28792a2e26d9d7be0467fac52b12ece67410b23eea845008257979bd87d083e3000000006a473044022027c40517c33cd3202d4310cfd2c75f38e6d7804b255fc3838a32ea26e5a3cb0002202b4399e1d7e655b64f699318f2bfbdced49f064ee54e9d6a678668fce51caf96012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffa8bf797bacd213b74a9977ae1b956afe3af33a1ee94324e010a16db891a07441000000006a473044022004cbb1d970b9f02c578b5c1d7de33361581eebc19c3cd8d2e50b0211ca4ef13702200c93b9fe5428055b6274dc8e52073c3e87f5b5e4206134d745928ccfc9393919012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff2b6fd82c9a68111b67ad85a614a6ecb50f7b6eac3d21d8ebefd9a6065cdf5729000000006b483045022100fdff16c595c7b4a9b4fc1e445b565f7b29fe5b7a08f79291b0ff585c7b72ac2902200c694aa124013bd419ce2349f15d10435827868d35db939b9d3c344d16e78420012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff6a5468dd8c83553dc51022f2a2fb772cf91c8607dc2ca1b8f203ac534612ab29000000006b483045022100ba7cc79e7ae3720238bfc5caa225dc8017d6a0d1cb1ec66abaf724fd20b3b7ab02206e8c942756604af0f63b74af495a9b3b7f4a44c489267f69a14cf2b1b953f46e012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff5f9f48a91d343fd5aef1d85f00850070931459ab256697afb728d1c81c1fa1d2000000006a47304402200ec85fc66f963e7504eb27361a4b4bb17de60e459da414fdc3962476de636134022056b62c15cf7f9b4e7d4e11c03e4e541dd348919b8c55efa4f1927e2fdd5ae8ea012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffffee1f455924d3167e7f7abf452c1856e9abdcfe27dc889942dd249cb376169d38000000006b48304502210089274eed807c5d23d819f6dfa8a358a9748e56f2080be4396ef77bb19d91b17402207fc7b22c879534fffe0eeaaec8fc284e22c2756f380c05ea57b881a96b09f3af012102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ffffffff0200e1f5050000000017a9144eb3a361d8a15d7f6a8ef9d1cf44962a90c44d548702912b00000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac490e135d000000000000000000000000000000"
                    },
                    "type": "MakerPaymentSent"
                  },
                  "timestamp": 1561529938879
                },
                {
                  "event": {
                    "data": {
                      "block_height": 141365,
                      "coin": "PIZZA",
                      "fee_details": {
                        "amount": "0.00001"
                      },
                      "from": ["RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh"],
                      "internal_id": "7e0e38e31dbe80792ef320b8c0a7cb9259127427ef8c2fca1d796f24484046a5",
                      "my_balance_change": "0",
                      "received_by_me": "0",
                      "spent_by_me": "0",
                      "timestamp": 1561529960,
                      "to": [
                        "RJTYiYeJ8eVvJ53n2YbrVmxWNNMVZjDGLh",
                        "bUN5nesdt1xsAjCtAaYUnNbQhGqUWwQT1Q"
                      ],
                      "total_amount": "1.01999523",
                      "tx_hash": "7e0e38e31dbe80792ef320b8c0a7cb9259127427ef8c2fca1d796f24484046a5",
                      "tx_hex": "0400008085202f892082f6916932f9bf674a3fb00c3d5d765303ab68461f4abe0f91cc1162546914a9010000006b483045022100999b8bb0224476b5c344a466d0051ec7a8c312574ad8956a4177a42625cb86e302205a6664396bff3f2e6fe57adb7e082a26d1b8da9ee77b3fc24aa4148fdd5c84db012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffcad29a146b81bcaa44744efbec5149b6e3ca32bace140f75ad5794288d5bff6c000000006b483045022100b4dbfe88561c201fb8fbaf5bbf5bc0985893c909429c579425da84b02d23cc12022075f1e1e3eba38d167a6e84aac23faee5a2eb0799511e647213cee168529d4e5d012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffa13eeacd04b3e26ae3f41530b560c615dafa0fd4235cc5b22d48ab97e7c3399c000000006a47304402201158306fe668cbf56ad3f586dc83c1cda9efab44cef46da6bc0fe242292c85ed02201d622fe283410320e760233ae81dc53df65406b09fd07f8649f1775689219c35012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff4352b9f1f01dde4209b9e91076a3cfcabdaa23d9d5a313abfe7edb67ee4273e3000000006b483045022100825242fb3c6d460580016e93718ae1f43917e53abcc1558a64a6ab6f406763dd0220543936ce4c725e5e9f03831274a8475b535171bb29e1919fcf52ba2a9c85a553012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffcc0fa94b5973c893e61d470ae3982b0bedfd29cb0da2c60a362de438598f108c000000006b4830450221008c70a8e10ca37819e5a4d9783366e729e690d78f2fdd8a1f4812ddc14ec7d6ad022035ba8cb4d4e50684107f8af5c184582687b5d7dfda5d9be1bd45e45749c77f08012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffb0bd3bb9fedb7bbf49ca1612c955ba6095202186cef5be6952aed3dd32da4268000000006a4730440220592216d63c199faa587a4a6cbe11ca26027368a116b50818ce30eced59ca887202201bcafcf88f9f2632151596732f839d77cbe2f2243822c8551faffecc90b5dc19012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff65cf2831fc200e55aaacbe0881ad0edfb298ee6d4421b08b048aecc151716bd1000000006a47304402202032eb1ccebc3be4b94bae343d1d168e87040d2d20977c47d073d6bf490ef6c00220067656e00c4b8930167c54078609925cec7b893a52bcb9304e6b2602f564413e012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffeaf67880bee214acecc74b12f648c1014d6394c4abf99832d408981bb460e999000000006b483045022100b9ae1cc824149220ac517298e6f21c26939485b31d0ae19d97d986c5f8f34e4502200a90578cf2c1835dbea00484af1f225711c255f1d0a3208f2e4f1154f0db2c9a012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffad089c3fe7987a44f150f34b7ac66972de76dd84c739bdeddf360ab029dfd4d6000000006a473044022015f0386ed67a61626fbe5ae79e0d39d38e7b4072b648e8a26e23adadc0a8e5bc02202398188fa2feb26994e5c1e7e758788de3d5f0f0096f956a0cd58804710bea6a012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffd6c66730546c62dd003b5af1f1e5ecfd339c62db0169c1d499584e09a8a9b288000000006b4830450221008d4c73f0e3c9d913ba32fd864167649242e3e891412ab80bdd3f7ff43a238ee20220602738e98008b146256b51d0df99e222aa165f2ce351241ebc23d8a098e2b0db012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff12d9eff354f46cbd4446a0bff27a6a635ff5b1dc8a5dd8b0178bb5f89c9ec080000000006b48304502210098d3349ba9b13560748949933d2704663a5ab52cdc804afa1ac4da3e5992e0a002201525d7ad8466ad260219f3873fb7781addbd363f91e8063bfa86c7ed4e385b84012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff69e16767806ea5f069b7d46674f7aa747fcc6e541189ce7fcf92edcfd7642ff4000000006b4830450221008a5ebfe904c87f21947a44d8418190be5893993a683fde0f96df8a9487923da002205be1bbd8b518ba2f303cae23bc20806e84ffbba6a03f032385b15edb8df107f4012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640fffffffff4fbabd508178f553e676d67ce325796b03aa249b41a23c681c1ad9dedb45ae7000000006a47304402207cea6824abe1ce35e18954b858d45243e2cb57d27d782adc5b6b07ebd21a02d7022007ba0469b298c4b1a7c4a148fa16bae93d28593b34e197c10ac0d1faf9cc1bfa012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff14867aa59932d895be607fb7398f5594e39d9fa2e1c7daaed7b1390dbfdddcab000000006b4830450221009fb6e1885a3658c593809f95ecd2049f8ef9e00379686ac236b17312c9613d4c0220709fc50c9a920a19254389944db366c354708c19885d2479d9968fda0848f9f7012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff75777c692daaa21d216a1a2a7059203becfcdcf6793aa1259cdd7aadec957ab6000000006a47304402202945019860abf9b80e71f340320d114846efa4d2780ce12513e3983fb4d3f15b022019be008fb7368e3f1f022924dc7af1138b94041f46084dd27768bc8cacd1529f012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffca037b85742e93df4eef8e8ac3b8531321c8a8e21a4a941360866ea57a973665000000006a4730440220760283a7828edcc53671fc73e29c30cdc64d60d300292761d39730f0d09f94c202201e026293e3891a6fe46e40cd21778a41e21641a261a7fbf3bf75b034d9c788d9012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffa68edd030b4307ad87bfeff96a6db5b3ddd1a0901c488a4fe4d2093531896d75000000006b48304502210091a41e16b2c27d7ef6077e8de9df692b6013e61d72798ff9f7eba7fc983cdb65022034de29a0fb22a339e8044349913915444ab420772ab0ab423e44cfe073cb4e70012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff8c952791181993a7512e48d098a06e6197c993b83241a4bf1330c0e95f2c304d000000006b483045022100fa14b9301feb056f6e6b10446a660525cc1ff3e191b0c45f9e12dcd4f142422c02203f4a94f2a9d3ec0b74fac2156dd9b1addb8fa5b9a1cfc9e34b0802e88b1cbfa3012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff32bc4d014542abf328fecff29b9f4c243c3dd295fe42524b20bf591a3ddc26a1000000006a47304402206f92c4da6651c8959f7aed61608d26b9e46f5c1d69f4fc6e592b1f552b6067f102201c8cc221eac731867d15d483cc83322dba2f14f31d3efb26be937a68ad772394012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffbb3877248c26b23023d7dbb83a5f8293c65c5bff4ac47935a4a31248cefffd91000000006a47304402205bab19ad082a1918e18ccb6462edc263196fb88c8fdfd6bd07a0cf031a4637810220371a621c1bdc6b957db2447a92dcf87b0309653a2db480c9ed623f34a6e6d8a9012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff6415b7356c94609b9a7a7eb06e4c306896767abbc11399779f952fb9ae197059000000006b483045022100e2d038dbb9a873f5a58ec7901d6a7e79f1b404afea3d852056f4d0746cfb821102207fb274947b10d467cd71aa948e9a50f5f4430b661b27afc347efd9d6cc409d9c012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff1aeefdf80ec8a07d657ca64a2c0aa465f58e6284755c9a263c5a807be43b4b81000000006a47304402206e7ff765ba47a8785008f64f49c8e73232d582b2b2d0a49be0880c2557de8f8602206448423a6a37ad9740eb316513b31f73599ae14f65623709fb5443ae609f3e2e012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff3c091681df17b46f280bc9d8011c1bb31397637ce945b393f70380f8cd0a8b0d010000006a47304402206ca8717000f3086d364318f56d52e2369c40b88a1cb86455a8db262b4816698a02206711caf453bfda6b1b3542e27e68c3180f92f0548326d74e30b3ed18cd2c2353012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff91f32d98b581def165495aff6b69530e1f3de7f68fabfeb93730cf9793bbcd2a000000006a47304402200a8cd5e29ee7ff136772ea1789a39a027eaa1cd92f90f9d57fd8cf77202251f402203dd2bc282a838a5730e840a0d22b4f0edbe3cb2da00466c66bc2b5c66fc8b032012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff854d9226c28a1f5fe440e08f41000f3547f304ecf9cc010d0b5bc845ef1f039a000000006b483045022100fe6cce49975cc78af1c394bc02d995710833ba08cf7f8dd5f99add2cc7db26c40220793491309c215d8314a1c142bef7ec6b9a397249bec1c00a0a5ab47dfc1208b6012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff593bc907aa71f3b0f7aa8c48bb5f650595e65a5a733a9601a8374ed978eec9a7000000006a47304402206362ae3c4cf1a19ba0e43424b03af542077b49761172c1ad26d802f54b1b6ca602206bc7edb655bb0024c0e48c1f4c18c8864f8d1ce59ae55cd81dc0bd1234430691012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff3b9da8c5ab0c0cd6b40f602ea6ed8e36a48034b182b9d1a77ffebd15fe203b94000000006b483045022100f8610eae25899663cb5fa9a4575d937da57cdfd41958794bbb4c02f8bed75da40220262d40e019ec3a57b252f4150d509cce6f8a2dbd83184a9fc2ed56aba8018b15012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff0897c8a57e15e7f3893b195d65cf6c6001b29c8c9734213d7a3131f57b9eca2e000000006b483045022100c485cbd6408cf0759bcf23c4154249882934b522a93c6b49e62412305bf7646902201cc4b668af4bb22fe57c32c4d34e822bceb12f6bd6923afdabf4894752a56ec3012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffffffdc7000f7c45b62960623fa3a277e8a55348a4fe4936fef1224b6953434a249000000006b4830450221008a51a9c26f475d5c0838afe9d51524f95adfb21a9b0a02eae31cb01dc0a31fab022071c5492fbc7270731d4a4947a69398bf99dd28c65bb69d19910bf53a515274c8012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff10ec2af7e31ca28e27177215904d9a59abf80f0652b24e3f749f14fb7b2264ec000000006b483045022100fe4269f8f5ca53ebcff6fb782142a6228f0e50498a531b7a9c0d54768af9854102207cc740a9ea359569b49d69a94215ce3e23aeda5779cebc434ad3d608e1752990012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff5e3830c088dd6ea412d778b0a700ef27c183cf03e19f3d6f71bc5eaf53b2c22e000000006b4830450221009788a7e7f2407ba2f7c504091fbdf8f8498367781e8a357616d68e2a6770b4e70220518c92f5fb21e6bfd7d870a783b2a5572ce003f2dbb237ec59df419c9a148966012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff51630ccb0ad32b24cc7ae1b3602950ba518dca6aa65ef560e57f08c23eed8d80000000006a47304402201aa556153ffeb13aa674353bf88c04a7af15c7eb32e1a835464e4b613c31dc2802200395858c29a46e9108de1f90b401ee26c296388b4073143b63f849b2cce461af012102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ffffffff0200e1f5050000000017a914ab802c4d644be63fd1a72834ff63b650d6b5353987bb7e1e00000000001976a91464ae8510aac9546d5e7704e31ce177451386455588ac680e135d000000000000000000000000000000"
                    },
                    "type": "TakerPaymentReceived"
                  },
                  "timestamp": 1561529998938
                },
                {
                  "event": {
                    "type": "TakerPaymentWaitConfirmStarted"
                  },
                  "timestamp": 1561529998941
                },
                {
                  "event": {
                    "type": "TakerPaymentValidatedAndConfirmed"
                  },
                  "timestamp": 1561530000859
                },
                {
                  "event": {
                    "data": {
                      "block_height": 0,
                      "coin": "PIZZA",
                      "fee_details": {
                        "amount": "0.00001"
                      },
                      "from": ["bUN5nesdt1xsAjCtAaYUnNbQhGqUWwQT1Q"],
                      "internal_id": "235f8e7ab3c9515a17fe8ee721ef971bbee273eb90baf70788edda7b73138c86",
                      "my_balance_change": "0.99999",
                      "received_by_me": "0.99999",
                      "spent_by_me": "0",
                      "timestamp": 0,
                      "to": ["R9o9xTocqr6CeEDGDH6mEYpwLoMz6jNjMW"],
                      "total_amount": "1",
                      "tx_hash": "235f8e7ab3c9515a17fe8ee721ef971bbee273eb90baf70788edda7b73138c86",
                      "tx_hex": "0400008085202f8901a5464048246f791dca2f8cef2774125992cba7c0b820f32e7980be1de3380e7e00000000d8483045022100beca668a946fcad98da64cc56fa04edd58b4c239aa1362b4453857cc2e0042c90220606afb6272ef0773185ade247775103e715e85797816fbc204ec5128ac10a4b90120ea774bc94dce44c138920c6e9255e31d5645e60c0b64e9a059ab025f1dd2fdc6004c6b6304692c135db1752102631dcf1d4b1b693aa8c2751afc68e4794b1e5996566cfc701a663f8b7bbbe640ac6782012088a914eb78e2f0cf001ed7dc69276afd37b25c4d6bb491882102031d4256c4bc9f99ac88bf3dba21773132281f65f9bf23a59928bce08961e2f3ac68ffffffff0118ddf505000000001976a91405aab5342166f8594baf17a7d9bef5d56744332788ac8000135d000000000000000000000000000000"
                    },
                    "type": "TakerPaymentSpent"
                  },
                  "timestamp": 1561530003429
                },
                {
                  "event": {
                    "type": "Finished"
                  },
                  "timestamp": 1561530003433
                }
              ],
              "my_info": {
                "my_amount": "1",
                "my_coin": "BEER",
                "other_amount": "1",
                "other_coin": "PIZZA",
                "started_at": 1561529842
              },
              "success_events": [
                "Started",
                "Negotiated",
                "TakerFeeValidated",
                "MakerPaymentSent",
                "TakerPaymentReceived",
                "TakerPaymentWaitConfirmStarted",
                "TakerPaymentValidatedAndConfirmed",
                "TakerPaymentSpent",
                "Finished"
              ],
              "type": "Maker",
              "uuid": "6bf6e313-e610-4a9a-ba8c-57fc34a124aa"
            }
          }
      ''', 200));
      expect(await ApiProvider().getSwapStatus(client, body),
          const TypeMatcher<Swap>());
    });

    test('returns a ErrorString if the http call completes with error',
        () async {
      when(client.post(url, body: getSwapToJson(body)))
          .thenAnswer((_) async => http.Response('''
            {
              "error": "swap data is not found"
            }
      ''', 200));
      expect(await ApiProvider().getSwapStatus(client, body),
          const TypeMatcher<ErrorString>());
    });
  });
}
