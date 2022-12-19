import 'package:flutter/material.dart';
import '../../../../../../blocs/coins_bloc.dart';
import '../../../../../../localizations.dart';
import '../../../../../../model/order_book_provider.dart';
import '../../../../../../model/orderbook.dart';
import '../../../../../../model/orderbook_depth.dart';
import '../../../../../dex/trade/pro/create/receive/matching_bids_page.dart';
import '../../../../../../utils/utils.dart';
import 'package:provider/provider.dart';

class MatchingOrderbookItem extends StatelessWidget {
  const MatchingOrderbookItem({
    Key key,
    this.orderbookDepth,
    this.sellAmount,
    this.onCreatePressed,
    this.onBidSelected,
  }) : super(key: key);

  final OrderbookDepth orderbookDepth;
  final double sellAmount;
  final Function(String) onCreatePressed;
  final Function(Ask) onBidSelected;

  @override
  Widget build(BuildContext context) {
    final OrderBookProvider orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    return InkWell(
      onTap: () {
        orderBookProvider.activePair = CoinsPair(
          sell: orderBookProvider.activePair.sell,
          buy: coinsBloc.getCoinByAbbr(orderbookDepth.pair.rel),
        );

        if ((orderbookDepth.depth.bids ?? 0) == 0) {
          onCreatePressed(orderbookDepth.pair.rel);
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement<dynamic, dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => MatchingBidsPage(
                    baseCoin: orderbookDepth.pair.base,
                    sellAmount: sellAmount,
                    onCreateNoOrder: onCreatePressed,
                    onCreateOrder: onBidSelected)),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
              width: 20,
              child: Image.asset(
                getCoinIconPath(orderbookDepth.pair.rel),
              ),
            ),
            SizedBox(width: 4),
            Text(orderbookDepth.pair.rel),
            SizedBox(width: 4),
            Expanded(
              child: (orderbookDepth.depth.bids ?? 0) > 0
                  ? RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText2,
                          children: <InlineSpan>[
                            TextSpan(
                                text: AppLocalizations.of(context).clickToSee,
                                style: Theme.of(context).textTheme.bodyText2),
                            TextSpan(
                                text:
                                    orderbookDepth.depth.bids.toString() + ' ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: AppLocalizations.of(context).orders,
                                style: Theme.of(context).textTheme.bodyText2)
                          ]),
                    )
                  : Text(
                      AppLocalizations.of(context).noOrderAvailable,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
