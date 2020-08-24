import 'dart:convert';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/utils/log.dart';

// At the moment (8/24/2020) tx history is disabled on parity nodes,
// so we switching ETH/ERC20 tx history to the https://komodo.live:3334 endpoint
//
// API calls:
// '/api/v1/eth_tx_history/{address}' - ETH transaction history for address
// '/api/v1/erc_tx_history/{token}/{address}' - ERC20 transaction history
//
// ref: https://github.com/ca333/komodoDEX/issues/872

GetErcTransactions getErcTransactions = GetErcTransactions();

class GetErcTransactions {
  final String ethUrl = 'https://komodo.live:3334/api/v1/eth_tx_history';
  final String ercUrl = 'https://komodo.live:3334/api/v1/erc_tx_history';

  Future<dynamic> getTransactions(Coin coin) async {
    if (coin.type != 'erc') return;

    final CoinBalance coinBalance = coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == coin.abbr,
        orElse: () => null);
    if (coinBalance == null) return;

    final String address = '0x3AC609B427EE0179cc3a571478Fe8038f123bCBE';
    // coinBalance.balance.address;

    final String url = coin.abbr == 'ETH'
        ? '$ethUrl/$address'
        : '$ercUrl/${coin.abbr}/$address';

    String body;
    try {
      Response response;
      response = await http.get(url);
      body = response.body;
    } catch (e) {
      Log('get_erc_transactions', 'getTransactions/fetch] $e');
      return ErrorCode(error: e);
    }

    return transactionsFromJson('{"result": $body}');
  }
}
