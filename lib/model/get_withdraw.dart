// To parse this JSON data, do
//
//     final getWithdraw = getWithdrawFromJson(jsonString);

import 'package:flutter/foundation.dart';

import '../blocs/coins_bloc.dart';
import 'coin.dart';
import 'coin_type.dart';

class GetWithdraw {
  GetWithdraw({
    // this.method = 'withdraw',
    this.amount,
    this.to,
    this.coin,
    this.max,
    this.userpass,
    this.fee,
    this.memo,
  });

  // String method;
  String amount;
  String memo;
  String coin;
  String to;
  bool max;
  String userpass;
  Fee fee;

  Map<String, dynamic> toJson() {
    Coin coinToEnable = coinsBloc.getKnownCoinByAbbr(coin);
    return coinToEnable.type == CoinType.zhtlc
        ? <String, dynamic>{
            'userpass': userpass ?? '',
            'method': 'task::withdraw::init',
            'mmrpc': '2.0',
            'params': {
              'coin': coin ?? '',
              'to': to ?? '',
              'max': max ?? false,
              if (amount != null) 'amount': amount,
            }
          }
        : <String, dynamic>{
            'method': 'withdraw',
            if (amount != null) 'amount': amount,
            if (memo != null) 'memo': memo,
            'to': to ?? '',
            'max': max ?? false,
            'coin': coin ?? '',
            'userpass': userpass ?? '',
            if (fee != null) 'fee': fee.toJson(),
          };
  }
}

class GetWithdrawTaskStatus {
  GetWithdrawTaskStatus({
    this.method = 'task::withdraw::status',
    this.mmrpc = '2.0',
    @required this.taskId,
    @required this.userpass,
  });

  String method;
  String mmrpc;
  int taskId;
  String userpass;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method,
        'mmrpc': mmrpc,
        'userpass': userpass,
        'params': {
          'task_id': taskId,
        }
      };
}

class Fee {
  Fee({
    this.type,
    this.amount,
    this.gasPrice,
    this.gas,
  });

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
