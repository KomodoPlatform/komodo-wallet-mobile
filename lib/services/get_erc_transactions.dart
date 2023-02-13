import '../app_config/app_config.dart';
import '../blocs/coins_bloc.dart';
import '../localizations.dart';
import '../model/coin.dart';
import '../model/coin_balance.dart';
import '../model/coin_type.dart';
import '../model/error_code.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../model/transaction_data.dart';
import '../model/transactions.dart';
import '../utils/log.dart';
import '../utils/utils.dart';

GetErcTransactions getErcTransactions = GetErcTransactions();

class GetErcTransactions {
  final String ethUrl = appConfig.ethUrl;
  final String ercUrl = appConfig.ercUrl;
  final String bnbUrl = appConfig.bnbUrl;
  final String bepUrl = appConfig.bepUrl;
  final String maticUrl = appConfig.maticUrl;
  final String plgUrl = appConfig.plgUrl;
  final String fantomUrl = appConfig.fantomUrl;
  final String ftmUrl = appConfig.ftmUrl;
  final String oneUrl = appConfig.oneUrl;
  final String hrcUrl = appConfig.hrcUrl;
  final String movrUrl = appConfig.movrUrl;
  final String mvrUrl = appConfig.mvrUrl;
  final String htUrl = appConfig.htUrl;
  final String hcoUrl = appConfig.hcoUrl;
  final String kcsUrl = appConfig.kcsUrl;
  final String krcUrl = appConfig.krcUrl;
  final String etcUrl = appConfig.etcUrl;
  final String sbchUrl = appConfig.sbchUrl;
  final String ubqUrl = appConfig.ubqUrl;
  final String avaxUrl = appConfig.avaxUrl;
  final String avxUrl = appConfig.avxUrl;

  Future<dynamic> getTransactions({Coin coin, String fromId}) async {
    if (!isErcType(coin)) return;

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
      case CoinType.utxo:
      case CoinType.slp:
      case CoinType.iris:
      case CoinType.cosmos:
      case CoinType.smartChain:
      case CoinType.qrc:
      case CoinType.zhtlc:
        break;
      case CoinType.etc:
        url = '$etcUrl/$address';
        break;
      case CoinType.sbch:
        url = '$sbchUrl/$address';
        break;
      case CoinType.ubiq:
        url = '$ubqUrl/$address';
        break;
      case CoinType.avx:
        url = _getErcTransactionHistoryUrl(coin, avaxUrl, avxUrl);
        break;
      case CoinType.erc:
        url = _getErcTransactionHistoryUrl(coin, ethUrl, ercUrl);
        break;
      case CoinType.bep:
        url = _getErcTransactionHistoryUrl(coin, bnbUrl, bepUrl);
        break;
      case CoinType.plg:
        url = _getErcTransactionHistoryUrl(coin, maticUrl, plgUrl);
        break;
      case CoinType.ftm:
        url = _getErcTransactionHistoryUrl(coin, fantomUrl, ftmUrl);
        break;
      case CoinType.hco:
        url = _getErcTransactionHistoryUrl(coin, htUrl, hcoUrl);
        break;
      case CoinType.hrc:
        url = _getErcTransactionHistoryUrl(coin, oneUrl, hrcUrl);
        break;
      case CoinType.mvr:
        url = _getErcTransactionHistoryUrl(coin, movrUrl, mvrUrl);
        break;
      case CoinType.krc:
        url = _getErcTransactionHistoryUrl(coin, kcsUrl, krcUrl);
        break;
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

  String _getErcTransactionHistoryUrl(
    Coin coin,
    String mainUrl,
    String protocolUrl,
  ) {
    CoinBalance coinBalance = coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == coin.abbr,
        orElse: () => null);
    final String address = coinBalance.balance.address;

    return (coin.protocol?.type == 'ETH'
            ? '$mainUrl/$address'
            : '$protocolUrl/${coin.protocol.protocolData.contractAddress}/$address') +
        (coin.testCoin ? '&testnet=true' : '');
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
        case 'MATICTEST':
          feeCoin = 'MATICTEST';
          break;
        case 'FTMT':
          feeCoin = 'FTMT';
          break;
        default:
      }

      tx.coin = originalCoin.abbr;
      tx.feeDetails.coin = feeCoin;
    }

    return transactions;
  }
}
