import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/disable_coin.dart';
import 'package:komodo_dex/model/error_disable_coin_active_swap.dart';
import 'package:komodo_dex/model/error_disable_coin_order_is_matched.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_disable_coin.dart';
import 'package:komodo_dex/services/api_providers.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  const String url = 'http://localhost:7783';

  group('disableCoin', () {
    final GetDisableCoin getDisableCoin =
        GetDisableCoin(userpass: 'test', method: 'disable_coin', coin: 'KMD');

    test('returns a DisableCoin if the http call completes successfully',
        () async {
      final MockClient client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response(
              '{"result": {"cancelled_orders":["e5fc7c81-7574-4d3f-b64a-47227455d62a"],"coin":"RICK"}}',
              200));
      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<DisableCoin>());
    });

    test('throws an exception if the http call completes with an error', () {
      final MockClient client = MockClient();

      // Use Mockito to return an unsuccessful response when it calls the
      // provided http.Client.
      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
          ApiProvider().disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          throwsException);
    });

    test('returns a ErrorString if the http call completes with errors - coin is not enabled',
        () async {
      final MockClient client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      final GetDisableCoin getDisableCoin =
          GetDisableCoin(userpass: 'test', method: 'disable_coin', coin: 'KMD');

      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response(
              '{"error": "No such coin: RICK"}',
              200));

      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<ErrorString>());
    });

    test('returns a ErrorDisableCoinActiveSwap if the http call completes with errors - active swap is using the coin',
        () async {
      final MockClient client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      final GetDisableCoin getDisableCoin =
          GetDisableCoin(userpass: 'test', method: 'disable_coin', coin: 'KMD');

      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response(
              '{"error": "There\'re active swaps using RICK","swaps":["d88d0a0e-f8bd-40ab-8edd-fe20801ef349"]}',
              200));

      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<ErrorDisableCoinActiveSwap>());
    });

        test('returns a ErrorDisableCoin if the http call completes with error - the order is matched at the moment, but another order is cancelled',
        () async {
      final MockClient client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      final GetDisableCoin getDisableCoin =
          GetDisableCoin(userpass: 'test', method: 'disable_coin', coin: 'KMD');

      when(client.post(url, body: getDisableCoinToJson(getDisableCoin)))
          .thenAnswer((_) async => http.Response(
              '{"error":"There\'re currently matching orders using RICK","orders":{"matching": ["d88d0a0e-f8bd-40ab-8edd-fe20801ef349"],"cancelled":["c88d0a0e-f8bd-40ab-8edd-fe20801ef349"]}}',
              200));

      expect(
          await ApiProvider()
              .disableCoin(client, Coin(abbr: 'KMD'), getDisableCoin),
          const TypeMatcher<ErrorDisableCoinOrderIsMatched>());
    });
  });
}
