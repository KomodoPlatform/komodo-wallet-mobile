import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_dex/utils/utils.dart';

void main() {
  group('removeBlockchainPrefix', () {
    test('removes blockchain prefix from address', () {
      const String address = 'eth:0x1234567890abcdef';
      final String result = removeBlockchainPrefix(address);
      expect(result, '0x1234567890abcdef');
    });

    test('removes blackcoin prefix from address', () {
      const String address = 'blackcoin:B8Q9aZ4Mz1ZwWYaknJdZ8t3Z6z9F3Fz1Zz';
      final String result = removeBlockchainPrefix(address);
      expect(result, 'B8Q9aZ4Mz1ZwWYaknJdZ8t3Z6z9F3Fz1Zz');
    });

    test('returns the same address if no prefix is present', () {
      const String address = '0x1234567890abcdef';
      final String result = removeBlockchainPrefix(address);
      expect(result, '0x1234567890abcdef');
    });

    test('returns the address after the prefix', () {
      const String address = ':0x1234567890abcdef';
      final String result = removeBlockchainPrefix(address);
      expect(result, ':0x1234567890abcdef');
    });

    test('returns the same address if no prefix is present', () {
      const String address = '0x1234567890abcdef:';
      final String result = removeBlockchainPrefix(address);
      expect(result, '0x1234567890abcdef:');
    });
  });
}
