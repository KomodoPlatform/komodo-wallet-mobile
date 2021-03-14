class TradePreimage {
  TradePreimage({
    this.baseCoinFee,
    this.relCoinFee,
    this.volume,
    this.volumeFract,
    this.takerFee,
    this.takerFeeFract,
    this.feeToSendTakerFee,
  });

  factory TradePreimage.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> result = json['result'];
    if (result == null) throw 'Failed to parse trade_preimage result';

    return TradePreimage(
      baseCoinFee: CoinFee.fromJson(result['base_coin_fee']),
      relCoinFee: CoinFee.fromJson(result['rel_coin_fee']),
      volume: result['volume'],
      volumeFract: result['volume_fraction'],
      takerFee: result['taker_fee'],
      takerFeeFract: result['taker_fee_fraction'],
      feeToSendTakerFee: CoinFee.fromJson(result['fee_to_send_taker_fee']),
    );
  }

  CoinFee baseCoinFee;
  CoinFee relCoinFee;
  String volume;
  Map<String, dynamic> volumeFract; // {'numer': '1', 'denom': '3'}
  String takerFee;
  Map<String, dynamic> takerFeeFract; // {'numer': '1', 'denom': '3'}
  CoinFee feeToSendTakerFee;

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'base_coin_fee': baseCoinFee.toJson(),
      'rel_coin_fee': relCoinFee.toJson(),
      'volume': volume,
      if (volumeFract != null) 'volume_fraction': volumeFract,
      'taker_fee': takerFee,
      if (takerFeeFract != null) 'taker_fee_fraction': takerFeeFract,
      'fee_to_send_taker_fee': feeToSendTakerFee,
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
  });

  factory CoinFee.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return CoinFee(
      coin: json['coin'] ?? '',
      amount: json['amount'] ?? '',
      amountFract: json['amount_fraction'],
    );
  }

  String coin;
  String amount;
  Map<String, dynamic> amountFract; // {'numer': '1', 'denom': '3'}

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coin': coin ?? '',
      'amount': amount ?? '',
      if (amountFract != null) 'amount_fraction': amountFract,
    };
  }
}
