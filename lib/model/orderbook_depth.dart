import '../model/pair.dart';

class OrderbookDepth {
  OrderbookDepth({this.pair, this.depth});

  factory OrderbookDepth.fromJson(Map<String, dynamic> json) {
    return OrderbookDepth(
        depth: Depth.fromJson(json['depth']),
        pair: Pair.fromJson(json['pair']));
  }

  Pair pair;
  Depth depth;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pair': pair.toJson(),
      'depth': depth.toJson(),
    };
  }
}

class Depth {
  Depth({this.asks, this.bids});

  factory Depth.fromJson(Map<String, dynamic> json) {
    return Depth(
      asks: json['asks'],
      bids: json['bids'],
    );
  }

  int asks;
  int bids;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'asks': asks,
      'bids': bids,
    };
  }
}
