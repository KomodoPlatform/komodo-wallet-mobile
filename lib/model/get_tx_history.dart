// To parse this JSON data, do
//
//     final getTxHistory = getTxHistoryFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'coin.dart';

String getTxHistoryToJson(GetTxHistory data) => json.encode(data.toJson());

class GetTxHistory {
  GetTxHistory({
    this.userpass,
    this.method = 'my_tx_history',
    this.coin,
    this.limit,
    this.fromId,
  });

  String userpass;
  String method;
  String coin;
  int limit;
  String fromId;

  Map<String, dynamic> toJson() {
    // slp coins uses the rpc 2.0 methods
    Coin coinToEnable = coinsBloc.getKnownCoinByAbbr(coin);
    return isSlp(coinToEnable)
        ? <String, dynamic>{
            'userpass': userpass ?? '',
            'method': method ?? '',
            'mmrpc': '2.0',
            'params': {
              'coin': coin ?? '',
            }
          }
        : <String, dynamic>{
            'userpass': userpass ?? '',
            'method': method ?? '',
            'coin': coin ?? '',
            'limit': limit ?? 0,
            'from_id': fromId,
          };
  }
}
