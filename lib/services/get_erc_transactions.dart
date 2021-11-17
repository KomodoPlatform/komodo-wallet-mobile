import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/error_code.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/model/transaction_data.dart';
import 'package:komodo_dex/model/transactions.dart';
import 'package:komodo_dex/utils/log.dart';

GetErcTransactions getErcTransactions = GetErcTransactions();

class GetErcTransactions {
  final String ethUrl = appConfig.ethUrl;
  final String ercUrl = appConfig.ercUrl;
  final String bnbUrl = appConfig.bnbUrl;
  final String bepUrl = appConfig.bepUrl;

  Future<dynamic> getTransactions({Coin coin, String fromId}) async {
    if (coin.type != 'erc' && coin.type != 'bep') return;

    // Endpoint returns all tx at ones, and `fromId` only has value
    // if some txs was already fetched, so no need to fetch same txs again
    if (fromId != null) return;

    final CoinBalance coinBalance = coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == coin.abbr,
        orElse: () => null);
    if (coinBalance == null) return;

    final String address = coinBalance.balance.address;

    String url;
    switch (coin.type) {
      case 'erc':
        url = (coin.protocol?.type == 'ETH' // 'ETH', 'ETHR'
                ? '$ethUrl/$address'
                : '$ercUrl/${coin.protocol.protocolData.contractAddress}/$address') +
            (coin.testCoin ? '&testnet=true' : '');
        break;
      case 'bep':
        url = (coin.protocol?.type == 'ETH' // 'BNB', 'BNBT'
                ? '$bnbUrl/$address'
                : '$bepUrl/${coin.protocol.protocolData.contractAddress}/$address') +
            (coin.testCoin ? '&testnet=true' : '');
        break;
      default:
        return;
    }

    String body;
    try {
      final Response response = await http.get(Uri.parse(url));
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
          message: AppLocalizations().txLimitExceeded,
        ));
      }
      return;
    }

    transactions.result.transactions
        .sort((a, b) => b.timestamp.compareTo(a.timestamp));
    transactions.result?.syncStatus?.state ??= 'Finished';

    _fixTestCoinsNaming(transactions, coin);
    return transactions;
  }

  // https://github.com/KomodoPlatform/AtomicDEX-mobile/pull/1078#issuecomment-808705710
  Transactions _fixTestCoinsNaming(
      Transactions transactions, Coin originalCoin) {
    if (!originalCoin.testCoin) return transactions;

    for (Transaction tx in transactions.result.transactions) {
      String feeCoin;
      switch (originalCoin.abbr) {
        case 'ETHR':
          feeCoin = 'ETHR';
          break;
        case 'JSTR':
          feeCoin = 'ETHR';
          break;
        default:
      }

      tx.coin = originalCoin.abbr;
      tx.feeDetails.coin = feeCoin;
    }

    return transactions;
  }
}
