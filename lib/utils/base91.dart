import 'dart:convert';

Base91 base91 = Base91();

class Base91 {
  Base91() {
    const String ts =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#\$%&()*+,./:;<=>?@[]^_`{|}~"';
    _encodingTable = Encoding.getByName('ISO_8859-1').encode(ts);
    base = _encodingTable.length;
    assert(base == 91);

    _decodingTable = List<int>(256);
    for (int i = 0; i < 256; i++) {
      _decodingTable[i] = -1;
    }

    for (int i = 0; i < base; i++) {
      _decodingTable[_encodingTable[i]] = i;
    }
  }

  List<int> _encodingTable;
  List<int> _decodingTable;
  int base;

  List<int> encode(List<int> bytes) {
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
        result.add(_encodingTable[(ev / base).truncate()]);
      }
    }
    if (en > 0) {
      result.add(_encodingTable[ebq % base]);
      if (en > 7 || ebq > 90) {
        result.add(_encodingTable[(ebq / base).truncate()]);
      }
    }
    return result;
  }

  List<int> decode(List<int> bytes) {
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

    if (dv != -1) {
      result.add((dbq | dv << dn).toUnsigned(8));
    }
    return result;
  }
}

// Simple code to test the class
void main(List<String> args) {
  const String text = '123456';
  print('Original text: $text');
  final List<int> encoded = base91.encode(utf8.encode(text));
  print('Base91 = ${utf8.decode(encoded)}');
  final List<int> decoded = base91.decode(encoded);
  print('Decoded = ${utf8.decode(decoded)}');
}
