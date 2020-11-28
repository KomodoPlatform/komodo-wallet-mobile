import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/get_trade_fee.dart';
import 'package:komodo_dex/model/trade_fee.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class BuildTradeFees extends StatefulWidget {
  const BuildTradeFees({
    @required this.coin,
    @required this.amount,
  });

  final String coin;
  final double amount;

  @override
  _BuildTradeFeesState createState() => _BuildTradeFeesState();
}

class _BuildTradeFeesState extends State<BuildTradeFees> {
  CexProvider cexProvider;
  bool showDetailedFees = false;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);

    if (widget.coin == null || widget.amount == null) return Container();

    return FutureBuilder<double>(
      future: getTxFee(widget.coin),
      builder: (context, snapshot) {
        final double tradeFee = getTradeFee(widget.amount);
        if (!snapshot.hasData ||
            snapshot.data == 0 ||
            tradeFee == null ||
            tradeFee == 0) return const SizedBox();

        final bool hasCexPrice =
            (cexProvider.getUsdPrice(widget.coin) ?? 0) > 0;

        return GestureDetector(
          onTap: hasCexPrice
              ? () {
                  setState(() {
                    showDetailedFees = !showDetailedFees;
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).txFeeTitle,
                              style: Theme.of(context).textTheme.caption),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${cutTrailingZeros(formatPrice(snapshot.data))}'
                                ' ${widget.coin}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              if (showDetailedFees)
                                Text(
                                  cexProvider.convert(
                                    snapshot.data,
                                    from: widget.coin,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: cexColor),
                                ),
                            ],
                          )),
                        ],
                      ),
                      if (showDetailedFees) const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).tradingFee,
                              style: Theme.of(context).textTheme.caption),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${cutTrailingZeros(formatPrice(getTradeFee(widget.amount)))}'
                                ' ${widget.coin}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              if (showDetailedFees)
                                Text(
                                  cexProvider.convert(
                                    getTradeFee(widget.amount),
                                    from: widget.coin,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: cexColor),
                                ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasCexPrice)
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      showDetailedFees ? Icons.unfold_less : Icons.unfold_more,
                      color: Theme.of(context).textTheme.caption.color,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<double> getTxFee(String coin) async {
  if (coin == null) return null;

  try {
    final dynamic tradeFeeResponse =
        await MM.getTradeFee(MMService().client, GetTradeFee(coin: coin));

    if (tradeFeeResponse is TradeFee) {
      return double.parse(tradeFeeResponse.result.amount) * 2;
    } else {
      return null;
    }
  } catch (e) {
    Log('multi_order_provider] failed to get tx fee', e);
    rethrow;
  }
}

double getTradeFee(double amt) {
  if (amt == null) return null;
  return amt / 777;
}
