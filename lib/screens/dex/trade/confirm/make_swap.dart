import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/get_buy.dart';
import 'package:komodo_dex/model/get_setprice.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/orders/swap/swap_detail_page.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/protection_control.dart';
import 'package:komodo_dex/screens/dex/trade/create/order_created_popup.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/sounds_explanation_dialog.dart';

Future<void> makeASwap(
  BuildContext mContext, {
  ProtectionSettings protectionSettings,
  BuyOrderType buyOrderType,
  String minVolume,
}) async {
  Log('make_swap', 'Starting a swap…');

  if (swapBloc.matchingBid != null) {
    final dynamic re = await MM.postBuy(
        mmSe.client,
        GetBuySell(
          base: swapBloc.receiveCoinBalance.coin.abbr,
          rel: swapBloc.sellCoinBalance.coin.abbr,
          volume: swapBloc.amountReceive.toString(),
          max: swapBloc.isMaxActive,
          price: swapBloc.matchingBid.price,
          orderType: buyOrderType,
          baseNota: protectionSettings.requiresNotarization,
          baseConfs: protectionSettings.requiredConfirmations,
        ));
    if (re is BuyResponse) {
      _goToNextScreen(mContext, re);
    } else {
      _catchErrorSwap(mContext, re);
    }
  } else {
    MM
        .postSetPrice(
            mmSe.client,
            GetSetPrice(
              base: swapBloc.sellCoinBalance.coin.abbr,
              rel: swapBloc.receiveCoinBalance.coin.abbr,
              cancelPrevious: false,
              max: swapBloc.isMaxActive,
              volume: swapBloc.amountSell.toString(),
              minVolume: double.tryParse(minVolume ?? ''),
              price: (swapBloc.amountReceive / swapBloc.amountSell).toString(),
              relNota: protectionSettings.requiresNotarization,
              relConfs: protectionSettings.requiredConfirmations,
            ))
        .then<dynamic>((dynamic re) => re is SetPriceResponse
            ? _goToNextScreen(mContext, re)
            : throw re.error)
        .catchError((dynamic onError) => _catchErrorSwap(mContext, onError));
  }
}

void _catchErrorSwap(BuildContext context, ErrorString error) {
  String timeSecondeLeft = error.error;
  Log('make_swap', timeSecondeLeft);
  timeSecondeLeft = timeSecondeLeft.substring(
      timeSecondeLeft.lastIndexOf(' '), timeSecondeLeft.length);
  Log('make_swap', timeSecondeLeft);
  String errorDisplay =
      error.error.substring(error.error.lastIndexOf(r']') + 1).trim();
  if (error.error.contains('is too low, required')) {
    errorDisplay = AppLocalizations.of(context).notEnoughtBalanceForFee;
  }
  Scaffold.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 4),
    backgroundColor: Theme.of(context).errorColor,
    content: Text(errorDisplay),
  ));
}

void _goToNextScreen(BuildContext context, dynamic response) {
  Log('make_swap', '_goToNextScreen] swap started…');
  ordersBloc.updateOrdersSwaps();

  if (swapBloc.matchingBid != null) {
    Navigator.pushReplacement<dynamic, dynamic>(
      context,
      MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => SwapDetailPage(
                swap: Swap(
                    status: Status.ORDER_MATCHING,
                    result: MmSwap(
                      uuid: response.result.uuid,
                      myInfo: SwapMyInfo(
                          myAmount: cutTrailingZeros(
                              formatPrice(swapBloc.amountSell)),
                          otherAmount: cutTrailingZeros(
                              formatPrice(swapBloc.amountReceive)),
                          myCoin: response.result.rel,
                          otherCoin: response.result.base,
                          startedAt: DateTime.now().millisecondsSinceEpoch),
                    )),
              )),
    );
    showSoundsDialog(context);
  } else {
    Navigator.of(context).pop();
    showOrderCreatedDialog(context);
  }
}
