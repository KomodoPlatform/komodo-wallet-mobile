import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/utils/log.dart';

import '../localizations.dart';

class TenderMintTransactions {
  Future<dynamic> getTransactions(CoinBalance coinBalance) async {
    if (coinBalance == null) return;
    String body;
    String url = 'https://tx.komodo.live/${coinBalance.balance.address}';
    try {
      final Response response = await http.get(Uri.parse(url));
      body = response.body;
    } catch (e) {
      Log('get_tendermint_transactions', 'getTransactions/fetch] $e');
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
          message: AppLocalizations().txLimitExceeded,
        ));
      }
      return;
    }

    transactions.result.transactions
        .sort((a, b) => b.timestamp.compareTo(a.timestamp));
    transactions.result?.syncStatus?.state ??= 'Finished';

    return filterTxByCoin(transactions, coinBalance.coin);
  }

  Transactions filterTxByCoin(Transactions txs, Coin coin) {
    if (coin.protocol.protocolData.platform != null) {
      txs.result.transactions.removeWhere((tx) => tx.coin != coin.abbr);
      return txs;
    } else {
      return txs;
    }
  }
}

TenderMintTransactions tenderMintTransactions = TenderMintTransactions();
