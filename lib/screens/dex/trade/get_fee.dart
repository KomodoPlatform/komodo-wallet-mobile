import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

class GetFee {
  static Future<CoinAmt> tx(String coin) async {
    final CoinAmt fee = await _getTradeFeeFromMM(coin);
    fee.amount = fee.amount * 2;
    return fee;
  }

  static Future<CoinAmt> gas(String coin) async {
    if (gasCoin(coin) == null) return null;
    return await _getTradeFeeFromMM(coin);
  }

  static CoinAmt trading(double amt, [String coin]) {
    if (amt == null) return null;

    double amount = amt / 777;
    // DEX-fee (aka trading fee) for DOGE can't be less than 1DOGE (dust: 100000000).
    // MM2 returns correct value in response of 'trade_preimage' call,
    // but until 'trade_preimage' support implemented on GUI side,
    // we'll use this temp patch. Ref: #1039
    if (coin == 'DOGE' && amount < 1) amount = 1;

    return CoinAmt(
      amount: amount,
      coin: coin,
    );
  }

  static Future<CoinAmt> totalSell({
    String sellCoin,
    String buyCoin,
    double sellAmt,
  }) async {
    double totalAmt = 0;

    final CoinAmt txFee = await tx(sellCoin);
    if (txFee.coin == sellCoin) totalAmt += txFee.amount;

    final CoinAmt gasFee = await gas(buyCoin);
    if (gasFee?.coin == sellCoin) totalAmt += gasFee.amount;

    totalAmt += trading(sellAmt).amount;

    return CoinAmt(
      amount: totalAmt,
      coin: sellCoin,
    );
  }

  static String gasCoin(String coin) {
    final String type = coinsBloc.getCoinByAbbr(coin)?.type;

    switch (type) {
      case 'erc':
        return 'ETH';
      case 'qrc':
        return 'QTUM';
      default:
        return null;
    }
  }

  static Future<CoinAmt> _getTradeFeeFromMM(String coin) async {
    if (coin == null) return null;

    try {
      final dynamic tradeFeeResponse =
          await MM.getTradeFee(MMService().client, GetTradeFee(coin: coin));

      if (tradeFeeResponse is TradeFee) {
        return CoinAmt(
          amount: double.parse(tradeFeeResponse.result.amount),
          coin: tradeFeeResponse.result.coin,
        );
      } else {
        return null;
      }
    } catch (e) {
      Log('get_fee] failed to get trade fee', e);
      rethrow;
    }
  }
}

class CoinAmt {
  CoinAmt({this.amount, this.coin});

  double amount;
  String coin;
}
