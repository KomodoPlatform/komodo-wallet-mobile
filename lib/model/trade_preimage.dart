import '../model/get_trade_preimage.dart';
import '../model/rpc_error.dart';

class TradePreimage {
  TradePreimage({
    this.baseCoinFee,
    this.relCoinFee,
    this.volume,
    this.volumeFract,
    this.takerFee,
    this.totalFees,
    this.feeToSendTakerFee,
    this.request,
    this.error,
  });

  factory TradePreimage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> result = json['result'];
    if (result == null) throw 'Failed to parse trade_preimage result';

    return TradePreimage(
        baseCoinFee: CoinFee.fromJson(result['base_coin_fee']),
        relCoinFee: CoinFee.fromJson(result['rel_coin_fee']),
        volume: result['volume'],
        volumeFract: result['volume_fraction'],
        takerFee: CoinFee.fromJson(result['taker_fee']),
        feeToSendTakerFee: CoinFee.fromJson(result['fee_to_send_taker_fee']),
        totalFees: result['total_fees']
                ?.map<CoinFee>((dynamic item) => CoinFee.fromJson(item))
                ?.toList() ??
            [],
        request: GetTradePreimage.fromJson(result['request']));
  }

  CoinFee baseCoinFee;
  CoinFee relCoinFee;
  String volume;
  Map<String, dynamic> volumeFract; // {'numer': '1', 'denom': '3'}
  CoinFee takerFee;
  CoinFee feeToSendTakerFee;
  List<CoinFee> totalFees;
  dynamic request; // GetTradePreimage or GetTradePreimage2
  RpcError error; // Used by RPC 2.0

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'base_coin_fee': baseCoinFee.toJson(),
      'rel_coin_fee': relCoinFee.toJson(),
      'taker_fee': takerFee.toJson(),
      'volume': volume,
      if (volumeFract != null) 'volume_fraction': volumeFract,
      'fee_to_send_taker_fee': feeToSendTakerFee,
      'total_fees': totalFees.map((item) => item.toJson()).toList(),
      if (request != null) 'request': request.toJson(),
    };

    return <String, dynamic>{
      'result': result,
    };
  }
}

class CoinFee {
  CoinFee({
    this.coin,
    this.amount,
    this.amountFract,
    this.paidFromTradingVol,
  });

  factory CoinFee.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return CoinFee(
      coin: json['coin'] ?? '',
      amount: json['amount'] ?? '',
      amountFract: json['amount_fraction'],
      paidFromTradingVol: json['paid_from_trading_vol'] ?? false,
    );
  }

  String coin;
  String amount;
  Map<String, dynamic> amountFract; // {'numer': '1', 'denom': '3'}
  bool paidFromTradingVol;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coin': coin ?? '',
      'amount': amount ?? '',
      if (amountFract != null) 'amount_fraction': amountFract,
      'paid_from_trading_vol': paidFromTradingVol,
    };
  }
}
