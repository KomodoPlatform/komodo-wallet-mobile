import 'dart:convert';

import '../model/recent_swaps.dart';

String getImportSwapsToJson(GetImportSwaps data) => json.encode(data.toJson());

class GetImportSwaps {
  GetImportSwaps({
    this.userpass,
    this.method = 'import_swaps',
    this.swaps,
  });

  String userpass;
  String method;
  List<MmSwap> swaps;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'swaps': swaps ?? '',
      };
}
