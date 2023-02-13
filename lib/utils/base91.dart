import 'dart:convert';

import 'dart:typed_data';

/// JSON-friendly version of Base91: double-quote (" 0x22) replaced with apostrophe (' 0x27)
Base91 base91js = Base91(
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#\$%&()*+,./:;<=>?@[]^_`{|}~'");

class Base91 {
  Base91(this.alphabet) {
    _encodingTable = utf8.encode(alphabet);
    assert(_encodingTable.length == base);

    _decodingTable = List.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      _decodingTable[i] = -1;
    }

    for (int i = 0; i < base; i++) {
      _decodingTable[_encodingTable[i]] = i;
    }
  }

  final String alphabet;
  final int base = 91;
  late List<int> _encodingTable;
  late List<int> _decodingTable;

  Uint8List encode(Uint8List bytes) {
    int ebq = 0;
    int en = 0;

    final List<int> result = [];

    for (int b in bytes) {
      ebq |= (b & 255) << en;
      en += 8;
      if (en > 13) {
        int ev = ebq & 8191;
        if (ev > 88) {
          ebq >>= 13;
          en -= 13;
        } else {
          ev = ebq & 16383;
          ebq >>= 14;
          en -= 14;
        }
        result.add(_encodingTable[ev % base]);
        result.add(_encodingTable[ev ~/ base]);
      }
    }
    if (en > 0) {
      result.add(_encodingTable[ebq % base]);
      if (en > 7 || ebq > 90) {
        result.add(_encodingTable[ebq ~/ base]);
      }
    }
    return Uint8List.fromList(result);
  }

  String encodeUtf8(String sv) => utf8.decode(encode(utf8.encode(sv) as Uint8List));

  Uint8List decode(Uint8List bytes) {
    final List<int> result = [];
    int dbq = 0;
    int dn = 0;
    int dv = -1;

    for (int i = 0; i < bytes.length; i++) {
      assert(_decodingTable[bytes[i]] != -1);
      if (dv == -1) {
        dv = _decodingTable[bytes[i]];
      } else {
        dv += _decodingTable[bytes[i]] * base;
        dbq |= dv << dn;
        dn += (dv & 8191) > 88 ? 13 : 14;
        do {
          result.add(dbq.toUnsigned(8));
          dbq >>= 8;
          dn -= 8;
        } while (dn > 7);
        dv = -1;
      }
    }

    if (dv != -1) result.add((dbq | dv << dn).toUnsigned(8));

    return Uint8List.fromList(result);
  }

  String decodeUtf8(String sv) => utf8.decode(decode(utf8.encode(sv) as Uint8List));
}
