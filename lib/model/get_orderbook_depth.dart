import 'dart:convert';

String getOrderbookDepthToJson(GetOrderbookDepth data) =>
    json.encode(data.toJson());

class GetOrderbookDepth {
  GetOrderbookDepth({
    this.userpass,
    this.method = 'orderbook_depth',
    this.pairs,
  });

  String? userpass;
  String method;
  List<List<String>>? pairs;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userpass': userpass ?? '',
        'method': method ?? '',
        'pairs': pairs ?? '',
      };
}
