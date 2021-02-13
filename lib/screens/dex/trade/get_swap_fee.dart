import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

class GetSwapFee {
  static Future<CoinAmt> tx(String coin) async {
    final CoinAmt fee = await _getTradeFeeFromMM(coin);
    fee.amount = fee.amount * 2;
    return fee;
  }

  static Future<CoinAmt> gas(String coin) async {
    if (coinsBloc.getCoinByAbbr(coin)?.payGasIn == null) return null;
    return await _getTradeFeeFromMM(coin);
  }

  static CoinAmt trading(double amt, [String coin]) {
    if (amt == null) return null;

    return CoinAmt(
      amount: amt / 777,
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
