import 'dart:convert';

import 'package:komodo_dex/utils/base91.dart';
import 'package:test/test.dart';

// Run with
//
//     flutter test test/utility_test.dart

void main() {
  group('base91', () {
    test('foobar', () {
      final foobar91 = base91js.encodeUtf8('foobar');
      print('foobar91: $foobar91');
      expect(foobar91, 'dr/2s)uC');
      expect(base91js.decodeUtf8(foobar91), 'foobar');
    });

    test('32 bytes', () {
      const s32 = '25c42dc6bd76a4791d04d4e352c404a0'; // Some binary data
      const b91 = '57%IcjHTzJQz{*QiZ%wbq+zX4Re0v67Rg5VEh)FB';
      expect(base91js.encodeUtf8(s32), b91);
      expect(base91js.decodeUtf8(b91), s32);
      expect(json.encode(b91).length, b91.length + 2);
    });

    test('64 bytes', () {
      const s64 =
          '4f0f642bd70f6a4a4aed2b0aff8072c7cad776782a1a0626a4924f3d06decf66';
      const b91 =
          "pRYxXmkMYR^=5*LTe5xIh)&Y>IF),,Ak5t>x**ISLR^=`*lTXzEfg):i;I%uyN8RpRvEDi#X<!'1]*G";
      expect(base91js.encodeUtf8(s64), b91);
      expect(base91js.decodeUtf8(b91), s64);
      expect(json.encode(b91).length, b91.length + 2);
    });
  });
}
