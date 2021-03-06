import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/get_swap_fee.dart';
import 'package:komodo_dex/utils/utils.dart';

class TradeFormValidator {
  final CoinBalance sellBalance = swapBloc.sellCoinBalance;
  final CoinBalance receiveBalance = swapBloc.receiveCoinBalance;
  final double amountSell = swapBloc.amountSell;
  final double amountReceive = swapBloc.amountReceive;
  final Ask matchingBid = swapBloc.matchingBid;
  final AppLocalizations appLocalizations = AppLocalizations();

  Future<String> get errorMessage async {
    return _validateNetwork() ?? _validateMinValues() ?? await _validateGas();
  }

  String _validateNetwork() {
    if (mainBloc.isNetworkOffline) {
      return appLocalizations.noInternet;
    } else {
      return null;
    }
  }

  String _validateMinValues() {
    final double minVolumeSell =
        swapBloc.minVolumeDefault(swapBloc.sellCoinBalance.coin.abbr);
    final double minVolumeReceive =
        swapBloc.minVolumeDefault(swapBloc.receiveCoinBalance.coin.abbr);

    if (amountSell > 0 && amountSell < minVolumeSell) {
      return appLocalizations.minValue(
          swapBloc.sellCoinBalance.coin.abbr, '$minVolumeSell');
    } else if (amountReceive > 0 && amountReceive < minVolumeReceive) {
      return appLocalizations.minValueBuy(
          swapBloc.receiveCoinBalance.coin.abbr, '$minVolumeReceive');
    } else if (matchingBid != null && matchingBid.minVolume != null) {
      if (amountReceive < matchingBid.minVolume) {
        return appLocalizations.minValueBuy(
            swapBloc.receiveCoinBalance.coin.abbr,
            cutTrailingZeros(formatPrice(matchingBid.minVolume)));
      }
      return null;
    } else {
      return null;
    }
  }

  Future<String> _validateGas() async {
    return await _validateGasFor(swapBloc.sellCoinBalance.coin.abbr) ??
        await _validateGasFor(swapBloc.receiveCoinBalance.coin.abbr);
  }

  Future<String> _validateGasFor(String coin) async {
    final CoinAmt gasFee = await GetSwapFee.gas(coin);
    if (gasFee == null) return null;

    CoinBalance gasBalance;
    try {
      gasBalance = coinsBloc.coinBalance
          .singleWhere((CoinBalance coin) => coin.coin.abbr == gasFee.coin);
    } catch (e) {
      return appLocalizations.swapGasActivate(gasFee.coin);
    }

    double requiredGasAmt = gasFee.amount;
    if (gasFee.coin == swapBloc.sellCoinBalance.coin.abbr) {
      requiredGasAmt += GetSwapFee.trading(amountSell).amount;
    }

    if (gasBalance.balance.balance < deci(requiredGasAmt)) {
      return appLocalizations.swapGasAmount(
          cutTrailingZeros(formatPrice(gasFee)), gasFee.coin);
    }

    return null;
  }
}
