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

  Future<dynamic> getTransactions({Coin coin, String fromId}) async {
    if (coin.type != 'erc') return;

    // Endpoint returns all tx at ones, and `fromId` only has value
    // if some txs was already fetched, so no need to fetch same txs again
    if (fromId != null) return;

    final CoinBalance coinBalance = coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == coin.abbr,
        orElse: () => null);
    if (coinBalance == null) return;

    final String address = coinBalance.balance.address;

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
      return ErrorCode(error: Error(message: e));
    }

    final String result =
        body.isNotEmpty ? body : '{"result": {"transactions": []}}';
    Transactions transactions;

    try {
      transactions = transactionsFromJson(result);
    } catch (_) {
      if (body == 'Limit exceeded') {
        return ErrorCode(
            error: Error(
          // TODO(yurii): localization
          message: 'Too many requests.\n'
              'Transactions history requests limit exceeded.\n'
              'Please try again later.',
        ));
      }
      return;
    }

    transactions.result.transactions
        .sort((a, b) => b.timestamp.compareTo(a.timestamp));
    transactions.result?.syncStatus?.state ??= 'Finished';

    return transactions;
  }
}