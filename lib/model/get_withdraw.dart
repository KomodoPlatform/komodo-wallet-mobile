class GetWithdraw {
  GetWithdraw({
    this.method = 'withdraw',
    this.amount,
    this.to,
    this.coin,
    this.max,
    this.userpass,
    this.fee,
    this.memo,
  });

  String method;
  String amount;
  String memo;
  String coin;
  String to;
  bool max;
  String userpass;
  Fee fee;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method ?? '',
        if (amount != null) 'amount': amount,
        if (memo != null) 'memo': memo,
        'to': to ?? '',
        'max': max ?? false,
        'coin': coin ?? '',
        'userpass': userpass ?? '',
        if (fee != null) 'fee': fee.toJson(),
      };
}

class Fee {
  Fee({
    this.type,
    this.amount,
    this.gasPrice,
    this.gas,
  });
  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        type: json['type'],
        amount: json['amount'],
        gasPrice: json['gas_price'],
        gas: json['gas'],
      );
  String
      type; // type of transaction fee, possible values: UtxoFixed, UtxoPerKbyte, EthGas
  String
      amount; // fee amount in coin units, used only when type is UtxoFixed (fixed amount not depending on tx size) or UtxoPerKbyte (amount per Kbyte).
  String
      gasPrice; // used only when fee type is EthGas. Sets the gas price in `gwei` units
  int gas; // used only when fee type is EthGas. Sets the gas limit for transaction

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'amount': amount,
        'gas_price': gasPrice,
        'gas': gas,
      };
}
