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
      const s32 =
          '25c42dc6bd76a4791d04d4e352c404a01147b50c943f45c14a9392c0294f2718';
      const b91 =
          '57%IcjHTzJQz{*QiZ%wbq+zX4Re0v67Rg5VEh)!G7I7=08{Qm,J.?,Zdp!l/vPBSYz%Ibj*X}R6=OCH';
      expect(base91js.encodeUtf8(s32), b91);
      expect(base91js.decodeUtf8(b91), s32);
      expect(json.encode(b91).length, b91.length + 2);
    });

    test('64 bytes', () {
      const s64 =
          '4f0f642bd70f6a4a4aed2b0aff8072c7cad776782a1a0626a4924f3d06decf667135947e9555d7a9a1f6a36534f6d244f114834f1e8114edf701b33b4d3c01c3';
      const b91 =
          "pRYxXmkMYR^=5*LTe5xIh)&Y>IF),,Ak5t>x**ISLR^=`*lTXzEfg):i;I%uyN8RpRvEDi#X<!'1]*lT'1Qb&kfdJ3<:fvrTk,Ef?,:GDJ=:Xv`j=LnE%k?H7IF?Xv`j3Oqb2iZd7R_=hNwiB25Ir+ASv1txXC";
      expect(base91js.encodeUtf8(s64), b91);
      expect(base91js.decodeUtf8(b91), s64);
      expect(json.encode(b91).length, b91.length + 2);
    });
  });
}
