class BinanceKlinesResponse {
  BinanceKlinesResponse({this.klines});

  factory BinanceKlinesResponse.fromJson(List<dynamic> json) {
    return BinanceKlinesResponse(
      klines:
          json.map((dynamic kline) => BinanceKline.fromJson(kline)).toList(),
    );
  }

  final List<BinanceKline> klines;

  List<dynamic> toJson() {
    return klines.map((BinanceKline kline) => kline.toJson()).toList();
  }
}

class BinanceKline {
  BinanceKline({
    this.openTime,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
    this.closeTime,
    this.quoteAssetVolume,
    this.numberOfTrades,
    this.takerBuyBaseAssetVolume,
    this.takerBuyQuoteAssetVolume,
  });

  factory BinanceKline.fromJson(List<dynamic> json) {
    return BinanceKline(
      openTime: json[0],
      open: double.parse(json[1]),
      high: double.parse(json[2]),
      low: double.parse(json[3]),
      close: double.parse(json[4]),
      volume: double.parse(json[5]),
      closeTime: json[6],
      quoteAssetVolume: double.parse(json[7]),
      numberOfTrades: json[8],
      takerBuyBaseAssetVolume: double.parse(json[9]),
      takerBuyQuoteAssetVolume: double.parse(json[10]),
    );
  }

  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int closeTime;
  final double quoteAssetVolume;
  final int numberOfTrades;
  final double takerBuyBaseAssetVolume;
  final double takerBuyQuoteAssetVolume;

  List<dynamic> toJson() {
    return <dynamic>[
      openTime,
      open,
      high,
      low,
      close,
      volume,
      closeTime,
      quoteAssetVolume,
      numberOfTrades,
      takerBuyBaseAssetVolume,
      takerBuyQuoteAssetVolume,
    ];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'timestamp': openTime,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'quote_volume': quoteAssetVolume
    };
  }
}
