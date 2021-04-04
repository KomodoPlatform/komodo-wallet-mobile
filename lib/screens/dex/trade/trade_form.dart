import 'dart:async';

import 'package:komodo_dex/model/get_max_taker_volume.dart';
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
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/utils/utils.dart';

class TradeForm {
  final int precision = 8;
  Timer _typingTimer;
  String _latestSellFieldValue;

  Future<void> onSellAmountFieldChange(String text) async {
    _typingTimer?.cancel();
    _latestSellFieldValue = text;
    _typingTimer = Timer(Duration(milliseconds: 200), () {
      _handleSellAmountChange(text);
    });
  }

  Future<void> _handleSellAmountChange(String text) async {
    double valueDouble = double.tryParse(text ?? '');
    // If empty or non-numerical
    if (valueDouble == null) {
      swapBloc.setAmountSell(null);
      swapBloc.setIsMaxActive(false);
      if (swapBloc.matchingBid != null) swapBloc.setAmountReceive(null);

      return;
    }

    // If greater than max available balance
    final double maxAmount = await getMaxSellAmount();
    if (text != _latestSellFieldValue) return;
    if (valueDouble >= maxAmount) {
      valueDouble = maxAmount;
      swapBloc.setIsMaxActive(true);
    } else {
      swapBloc.setIsMaxActive(false);
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

      final double amountReceive =
          valueDouble / double.parse(matchingBid.price);
      swapBloc.setAmountReceive(amountReceive);
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

  Future<void> setMaxSellAmount() async {
    swapBloc.setIsMaxActive(true);

    swapBloc.processing = true;
    await updateTradePreimage();
    final double max = await getMaxSellAmount();
    swapBloc.processing = false;

    if (max != swapBloc.amountSell) swapBloc.setAmountSell(max);
  }

  Future<double> getMaxSellAmount() async {
    if (swapBloc.sellCoinBalance == null) return null;

    final double fromPreimage =
        double.tryParse(swapBloc.tradePreimage?.volume ?? '');
    if (fromPreimage != null)
      return double.parse(fromPreimage.toStringAsFixed(precision));

    final Rational fromMaxTakerVolume = await MM.getMaxTakerVolume(
        GetMaxTakerVolume(coin: swapBloc.sellCoinBalance.coin.abbr));
    if (fromMaxTakerVolume != null)
      return double.parse(fromMaxTakerVolume.toStringAsFixed(precision));

    return double.tryParse(
        swapBloc.sellCoinBalance.balance.balance.toStringAsFixed(precision) ??
            '0');
  }

  // Updates swapBloc.tradePreimage and returns error String or null
  Future<String> updateTradePreimage() async {
    if (swapBloc.sellCoinBalance == null ||
        swapBloc.receiveCoinBalance == null ||
        swapBloc.amountSell == null ||
        swapBloc.amountSell == 0.0 ||
        swapBloc.amountReceive == null ||
        swapBloc.amountReceive == 0.0) {
      swapBloc.tradePreimage = null;
      return null;
    }

    final getTradePreimageRequest = swapBloc.matchingBid == null
        ? GetTradePreimage(
            base: swapBloc.sellCoinBalance.coin.abbr,
            rel: swapBloc.receiveCoinBalance.coin.abbr,
            max: swapBloc.isSellMaxActive ?? false,
            swapMethod: 'setprice',
            volume: swapBloc.amountSell.toString(),
            price: (swapBloc.amountReceive / swapBloc.amountSell).toString())
        : GetTradePreimage(
            base: swapBloc.receiveCoinBalance.coin.abbr,
            rel: swapBloc.sellCoinBalance.coin.abbr,
            swapMethod: 'buy',
            volume: swapBloc.amountReceive.toString(),
            price: (swapBloc.amountSell / swapBloc.amountReceive).toString());

    TradePreimage tradePreimage;

    swapBloc.processing = true;
    try {
      tradePreimage = await MM.getTradePreimage(getTradePreimageRequest);
    } catch (e) {
      swapBloc.processing = false;
      swapBloc.tradePreimage = null;
      Log('trade_form', 'updateTradePreimage] $e');
      return e.toString();
    }

    swapBloc.processing = false;
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
    swapBloc.tradePreimage = null;
    swapBloc.processing = false;
    syncOrderbook.activePair = CoinsPair(sell: null, buy: null);
  }
}

var tradeForm = TradeForm();
