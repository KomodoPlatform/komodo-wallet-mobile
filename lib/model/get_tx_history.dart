// To parse this JSON data, do
//
//     final getTxHistory = getTxHistoryFromJson(jsonString);

import 'dart:convert';

import 'package:komodo_dex/model/coin_type.dart';

import '../blocs/coins_bloc.dart';
import '../model/coin_type.dart';
import '../services/mm_service.dart';
import '../utils/utils.dart';

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

    bool v2Coins = isSlp(coinToEnable) ||
        coinToEnable.type == CoinType.iris ||
        coinToEnable.type == CoinType.cosmos;
    return v2Coins
        ? <String, dynamic>{
            'userpass': userpass ?? '',
            'method': method ?? '',
            'mmrpc': '2.0',
            'params': {
              'coin': coin ?? '',
            }
          }
        : coinToEnable.type == CoinType.zhtlc
            ? <String, dynamic>{
                'userpass': mmSe.userpass ?? '',
                'method': 'z_coin_tx_history',
                'mmrpc': '2.0',
                'params': {
                  'coin': coin ?? '',
                  'limit': limit ?? 0,
                },
              }
            : <String, dynamic>{
                'userpass': userpass ?? '',
                'method': method ?? '',
                'coin': coin ?? '',
                'limit': limit ?? 0,
                'from_id': fromId,
                'decimals': coinToEnable.decimals
    };
  }
}
