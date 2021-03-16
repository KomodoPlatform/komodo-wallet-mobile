import 'package:decimal/decimal.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/get_trade_preimage.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/protection_control.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/screens/dex/get_swap_fee.dart';
import 'package:komodo_dex/utils/utils.dart';

class TradeForm {
  final AppLocalizations localizations = AppLocalizations();

  Future<void> onSellAmountFieldChange(String text) async {
    double valueDouble = double.tryParse(text ?? '');
    // If empty or non-numerical
    if (valueDouble == null) {
      swapBloc.setAmountSell(null);
      swapBloc.setAmountReceive(null);
      swapBloc.setIsMaxActive(false);

      return;
    }

    // If greater than max available balance
    final Decimal maxAmount = await getMaxSellAmount();
    if (valueDouble > maxAmount.toDouble()) {
      valueDouble = maxAmount.toDouble();
      swapBloc.setIsMaxActive(true);
    }

    final Ask matchingBid = swapBloc.matchingBid;
    if (matchingBid != null) {
      final Rational valueRat = Rational.parse(valueDouble.toString());
      final Rational bidPrice = fract2rat(matchingBid.priceFract) ??
          Rational.parse(matchingBid.price);
      final Rational bidVolume = fract2rat(matchingBid.maxvolumeFract) ??
          Rational.parse(matchingBid.maxvolume.toString());

      // If greater than matching bid max receive volume
      // TODO(yurii): refactor after
      // https://github.com/KomodoPlatform/atomicDEX-API/issues/838 implemented
      if (valueRat >= (bidVolume * bidPrice)) {
        valueDouble = (bidVolume * bidPrice).toDouble();
        swapBloc.setIsMaxActive(false);
        swapBloc.shouldBuyOut = true;
      } else {
        swapBloc.shouldBuyOut = false;
      }

      swapBloc.setAmountReceive(valueDouble / double.parse(matchingBid.price));
    }

    swapBloc.setAmountSell(valueDouble);
  }

  void onReceiveAmountFieldChange(String text) {
    final double valueNum = double.tryParse(text ?? '');
    swapBloc.setAmountReceive(valueNum);
  }

  Future<void> makeSwap({
    ProtectionSettings protectionSettings,
    BuyOrderType buyOrderType,
    String minVolume,
    Function(dynamic) onSuccess,
    Function(dynamic) onError,
  }) async {
    Log('trade_form', 'Starting a swap…');

    if (swapBloc.matchingBid != null) {
      await _takerOrder(
        protectionSettings: protectionSettings,
        buyOrderType: buyOrderType,
        onSuccess: onSuccess,
        onError: onError,
      );
    } else {
      await _makerOrder(
          protectionSettings: protectionSettings,
          minVolume: minVolume,
          onSuccess: onSuccess,
          onError: onError);
    }
  }

  Future<void> _takerOrder({
    BuyOrderType buyOrderType,
    ProtectionSettings protectionSettings,
    Function(dynamic) onSuccess,
    Function(dynamic) onError,
  }) async {
    final Rational price = fract2rat(swapBloc.matchingBid.priceFract) ??
        Rational.parse(swapBloc.matchingBid.price);

    Rational volume;
    if (swapBloc.shouldBuyOut) {
      volume = fract2rat(swapBloc.matchingBid.maxvolumeFract) ??
          Rational.parse(swapBloc.matchingBid.maxvolume.toString());
    } else {
      volume = Rational.parse(swapBloc.amountReceive.toString());
    }

    final dynamic re = await MM.postBuy(
      mmSe.client,
      GetBuySell(
        base: swapBloc.receiveCoinBalance.coin.abbr,
        rel: swapBloc.sellCoinBalance.coin.abbr,
        orderType: buyOrderType,
        baseNota: protectionSettings.requiresNotarization,
        baseConfs: protectionSettings.requiredConfirmations,
        volume: {
          'numer': volume.numerator.toString(),
          'denom': volume.denominator.toString(),
        },
        price: {
          'numer': price.numerator.toString(),
          'denom': price.denominator.toString(),
        },
      ),
    );

    if (re is BuyResponse) {
      onSuccess(re);
    } else {
      onError(re);
    }
  }

  Future<void> _makerOrder({
    ProtectionSettings protectionSettings,
    String minVolume,
    Function(dynamic) onSuccess,
    Function(dynamic) onError,
  }) async {
    final amountSell = Rational.parse(swapBloc.amountSell.toString());
    final amountReceive = Rational.parse(swapBloc.amountReceive.toString());
    final Rational price = amountReceive / amountSell;

    final dynamic re = await MM.postSetPrice(
        mmSe.client,
        GetSetPrice(
          base: swapBloc.sellCoinBalance.coin.abbr,
          rel: swapBloc.receiveCoinBalance.coin.abbr,
          cancelPrevious: false,
          max: swapBloc.isSellMaxActive,
          minVolume: double.tryParse(minVolume ?? ''),
          relNota: protectionSettings.requiresNotarization,
          relConfs: protectionSettings.requiredConfirmations,
          volume: swapBloc.isSellMaxActive
              ? '0.00'
              : {
                  'numer': amountSell.numerator.toString(),
                  'denom': amountSell.denominator.toString(),
                },
          price: {
            'numer': price.numerator.toString(),
            'denom': price.denominator.toString(),
          },
        ));

    if (re is SetPriceResponse) {
      onSuccess(re);
    } else {
      onError(re);
    }
  }

  double getExchangeRate() {
    if (swapBloc.amountSell == null) return null;
    if (swapBloc.amountReceive == null || swapBloc.amountReceive == 0)
      return null;

    return swapBloc.amountReceive / swapBloc.amountSell;
  }

  double minVolumeDefault(String coin) {
    // https://github.com/KomodoPlatform/AtomicDEX-mobile/pull/1013#issuecomment-770423015
    // Default min volumes hardcoded for QTUM and rest of the coins for now.
    // Should be handled on API-side in the future
    if (coin == 'QTUM') {
      return 1;
    } else {
      return 0.00777;
    }
  }

  Future<Decimal> getMaxSellAmount() async {
    final Decimal sellCoinFee = await _getSellCoinFees(true);
    final CoinBalance sellCoinBalance = swapBloc.sellCoinBalance;
    return sellCoinBalance.balance.balance - sellCoinFee;
  }

  Future<Decimal> _getSellCoinFees(bool max) async {
    final CoinAmt fee = await GetSwapFee.totalSell(
      sellCoin: swapBloc.sellCoinBalance.coin.abbr,
      buyCoin: swapBloc.receiveCoinBalance?.coin?.abbr,
      sellAmt: max
          ? swapBloc.sellCoinBalance.balance.balance.toDouble()
          : swapBloc.amountSell,
    );

    return deci(fee.amount);
  }

  // Updates swapBloc.tradePreimage and returns error String or null
  Future<String> updateTradePreimage() async {
    if (swapBloc.sellCoinBalance == null ||
        swapBloc.receiveCoinBalance == null ||
        swapBloc.amountSell == null ||
        swapBloc.amountReceive == null) {
      swapBloc.tradePreimage = null;
      return null;
    }

    final getTradePreimageRequest = swapBloc.matchingBid == null
        ? GetTradePreimage(
            base: swapBloc.sellCoinBalance.coin.abbr,
            rel: swapBloc.receiveCoinBalance.coin.abbr,
            max: swapBloc.isSellMaxActive ?? false,
            swapMethod: 'setprice',
            volume: swapBloc.amountSell.toString())
        : GetTradePreimage(
            base: swapBloc.receiveCoinBalance.coin.abbr,
            rel: swapBloc.sellCoinBalance.coin.abbr,
            swapMethod: 'buy',
            volume: swapBloc.amountReceive.toString());

    TradePreimage tradePreimage;
    try {
      tradePreimage = await MM.getTradePreimage(getTradePreimageRequest);
    } catch (e) {
      swapBloc.tradePreimage = null;
      Log('trade_form', 'updateTradePreimage] $e');
      return localizations.tradePreimageError + ': ' + e.toString();
    }

    swapBloc.tradePreimage = tradePreimage;
    return null;
  }

  void reset() {
    Log('trade_form', 'form reseted');

    swapBloc.updateSellCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.updateMatchingBid(null);
    swapBloc.setAmountSell(null);
    swapBloc.setAmountReceive(null);
    swapBloc.setIsMaxActive(false);
    swapBloc.setEnabledSellField(false);
    swapBloc.enabledReceiveField = false;
    swapBloc.shouldBuyOut = false;
    syncOrderbook.activePair = CoinsPair(sell: null, buy: null);
  }
}

var tradeForm = TradeForm();
