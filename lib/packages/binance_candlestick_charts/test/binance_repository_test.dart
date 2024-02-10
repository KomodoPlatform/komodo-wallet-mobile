import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../bloc/binance_repository.dart';

void main() {
  group('BinanceRepository', () {
    final BinanceRepository repository = BinanceRepository();

    test('getLegacyOhlcCandleData returns a valid map when successful',
        () async {
      // Prepare test data
      final symbol = 'eth-btc';
      final limit = 100;

      // Call the method
      final Map<String, dynamic> result =
          await repository.getLegacyOhlcCandleData(symbol);

      final Map<String, dynamic> resultMin =
          (result['60'] as List<Map<String, dynamic>>).first;
      print(resultMin);

      // Perform assertions
      expect(result, isA<Map<String, dynamic>>());
      expect(resultMin.containsKey('open'), true);
      expect(resultMin.containsKey('high'), true);
      expect(resultMin.containsKey('low'), true);
      expect(resultMin.containsKey('close'), true);
      expect(resultMin.containsKey('volume'), true);
    });

    test('getLegacyOhlcCandleData throws an exception when unsuccessful',
        () async {
      // Prepare test data
      final symbol = 'invalid_symbol/';
      final interval = '1m';
      final limit = 100;

      // Call the method and expect an exception to be thrown
      expect(
        () => repository.getLegacyOhlcCandleData(symbol),
        throwsException,
      );
    });
  });
}
