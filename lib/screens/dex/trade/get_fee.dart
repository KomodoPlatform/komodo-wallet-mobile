import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';

class GetFee {
  static Future<Fee> tx(String coin) async {
    final Fee fee = await _getTradeFeeFromMM(coin);
    fee.amount = fee.amount * 2;
    return fee;
  }

  static Future<Fee> gas(String coin) async {
    if (gasCoin(coin) == null) return null;
    return await _getTradeFeeFromMM(coin);
  }

  static Fee trading(double amt, [String coin]) {
    if (amt == null) return null;

    return Fee(
      amount: amt / 777,
      coin: coin,
    );
  }

  static Future<Fee> totalSell({
    String sellCoin,
    String buyCoin,
    double sellAmt,
  }) async {
    double totalAmt = 0;

    final Fee txFee = await tx(sellCoin);
    if (txFee.coin == sellCoin) totalAmt += txFee.amount;

    final Fee gasFee = await gas(buyCoin);
    if (gasFee?.coin == sellCoin) totalAmt += gasFee.amount;

    totalAmt += trading(sellAmt).amount;

    return Fee(
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

  static Future<Fee> _getTradeFeeFromMM(String coin) async {
    if (coin == null) return null;

    try {
      final dynamic tradeFeeResponse =
          await MM.getTradeFee(MMService().client, GetTradeFee(coin: coin));

      if (tradeFeeResponse is TradeFee) {
        return Fee(
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

class Fee {
  Fee({this.amount, this.coin});

  double amount;
  String coin;
}
