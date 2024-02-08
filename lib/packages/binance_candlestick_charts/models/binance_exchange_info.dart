class BinanceExchangeInfoResponse {
  BinanceExchangeInfoResponse({
    this.timezone,
    this.serverTime,
    this.rateLimits,
    this.symbols,
  });

  factory BinanceExchangeInfoResponse.fromJson(Map<String, dynamic> json) {
    return BinanceExchangeInfoResponse(
      timezone: json['timezone'],
      serverTime: json['serverTime'],
      rateLimits: (json['rateLimits'] as List<dynamic>)
          .map((dynamic v) => RateLimit.fromJson(v))
          .toList(),
      symbols: (json['symbols'] as List<dynamic>)
          .map((dynamic v) => Symbol.fromJson(v))
          .toList(),
    );
  }

  String timezone;
  int serverTime;
  List<RateLimit> rateLimits;
  List<Symbol> symbols;
}

class RateLimit {
  RateLimit({
    this.rateLimitType,
    this.interval,
    this.intervalNum,
    this.limit,
  });

  RateLimit.fromJson(Map<String, dynamic> json) {
    rateLimitType = json['rateLimitType'];
    interval = json['interval'];
    intervalNum = json['intervalNum'];
    limit = json['limit'];
  }

  String rateLimitType;
  String interval;
  int intervalNum;
  int limit;
}

class Symbol {
  Symbol({
    this.symbol,
    this.status,
    this.baseAsset,
    this.baseAssetPrecision,
    this.quoteAsset,
    this.quotePrecision,
    this.quoteAssetPrecision,
    this.baseCommissionPrecision,
    this.quoteCommissionPrecision,
    this.orderTypes,
    this.icebergAllowed,
    this.ocoAllowed,
    this.quoteOrderQtyMarketAllowed,
    this.allowTrailingStop,
    this.cancelReplaceAllowed,
    this.isSpotTradingAllowed,
    this.isMarginTradingAllowed,
    this.filters,
    this.permissions,
    this.defaultSelfTradePreventionMode,
    this.allowedSelfTradePreventionModes,
  });

  factory Symbol.fromJson(Map<String, dynamic> json) {
    return Symbol(
      symbol: json['symbol'],
      status: json['status'],
      baseAsset: json['baseAsset'],
      baseAssetPrecision: json['baseAssetPrecision'],
      quoteAsset: json['quoteAsset'],
      quotePrecision: json['quotePrecision'],
      quoteAssetPrecision: json['quoteAssetPrecision'],
      baseCommissionPrecision: json['baseCommissionPrecision'],
      quoteCommissionPrecision: json['quoteCommissionPrecision'],
      orderTypes: (json['orderTypes'] as List<dynamic>)
          .map((dynamic orderType) => orderType.toString())
          .toList(),
      icebergAllowed: json['icebergAllowed'],
      ocoAllowed: json['ocoAllowed'],
      quoteOrderQtyMarketAllowed: json['quoteOrderQtyMarketAllowed'],
      allowTrailingStop: json['allowTrailingStop'],
      cancelReplaceAllowed: json['cancelReplaceAllowed'],
      isSpotTradingAllowed: json['isSpotTradingAllowed'],
      isMarginTradingAllowed: json['isMarginTradingAllowed'],
      permissions: (json['permissions'] as List<dynamic>)
          .map((dynamic permission) => permission.toString())
          .toList(),
      defaultSelfTradePreventionMode: json['defaultSelfTradePreventionMode'],
      allowedSelfTradePreventionModes:
          (json['allowedSelfTradePreventionModes'] as List<dynamic>)
              .map((dynamic mode) => mode.toString())
              .toList(),
      filters: (json['filters'] as List<dynamic>)
          .map((dynamic v) => Filter.fromJson(v))
          .toList(),
    );
  }

  String symbol;
  String status;
  String baseAsset;
  int baseAssetPrecision;
  String quoteAsset;
  int quotePrecision;
  int quoteAssetPrecision;
  int baseCommissionPrecision;
  int quoteCommissionPrecision;
  List<String> orderTypes;
  bool icebergAllowed;
  bool ocoAllowed;
  bool quoteOrderQtyMarketAllowed;
  bool allowTrailingStop;
  bool cancelReplaceAllowed;
  bool isSpotTradingAllowed;
  bool isMarginTradingAllowed;
  List<Filter> filters;
  List<String> permissions;
  String defaultSelfTradePreventionMode;
  List<String> allowedSelfTradePreventionModes;
}

class Filter {
  Filter({
    this.filterType,
    this.minPrice,
    this.maxPrice,
    this.tickSize,
    this.minQty,
    this.maxQty,
    this.stepSize,
    this.limit,
    this.minNotional,
    this.applyMinToMarket,
    this.maxNotional,
    this.applyMaxToMarket,
    this.avgPriceMins,
    this.maxNumOrders,
    this.maxNumAlgoOrders,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      filterType: json['filterType'],
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
      tickSize: json['tickSize'],
      minQty: json['minQty'],
      maxQty: json['maxQty'],
      stepSize: json['stepSize'],
      limit: json['limit'],
      minNotional: json['minNotional'],
      applyMinToMarket: json['applyMinToMarket'],
      maxNotional: json['maxNotional'],
      applyMaxToMarket: json['applyMaxToMarket'],
      avgPriceMins: json['avgPriceMins'],
      maxNumOrders: json['maxNumOrders'],
      maxNumAlgoOrders: json['maxNumAlgoOrders'],
    );
  }

  String filterType;
  String minPrice;
  String maxPrice;
  String tickSize;
  String minQty;
  String maxQty;
  String stepSize;
  int limit;
  String minNotional;
  bool applyMinToMarket;
  String maxNotional;
  bool applyMaxToMarket;
  int avgPriceMins;
  int maxNumOrders;
  int maxNumAlgoOrders;
}
