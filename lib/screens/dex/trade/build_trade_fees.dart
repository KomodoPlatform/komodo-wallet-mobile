import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
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
    @required this.baseCoin,
    @required this.baseAmount,
    this.includeGasFee = false,
    this.relCoin,
  });

  final String baseCoin;
  final double baseAmount;
  final bool includeGasFee;
  final String relCoin;

  @override
  _BuildTradeFeesState createState() => _BuildTradeFeesState();
}

class _BuildTradeFeesState extends State<BuildTradeFees> {
  CexProvider cexProvider;
  bool showDetailedFees = false;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);

    if (widget.baseCoin == null || widget.baseAmount == null)
      return Container();

    return FutureBuilder<double>(
      future: getTxFee(widget.baseCoin),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final double tradeFee = getTradeFee(widget.baseAmount);
        final double txFee = snapshot.data;

        if (txFee == 0 || tradeFee == null || tradeFee == 0)
          return const SizedBox();

        final bool hasCexPrice =
            (cexProvider.getUsdPrice(widget.baseCoin) ?? 0) > 0;

        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildTxFeeRow(txFee),
                      if (showDetailedFees) const SizedBox(height: 4),
                      _buildTradeFeeRow(),
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
          onTap: hasCexPrice
              ? () {
                  setState(() {
                    showDetailedFees = !showDetailedFees;
                  });
                }
              : null,
        );
      },
    );
  }

  Widget _buildTradeFeeRow() {
    return Row(
      children: <Widget>[
        Text(AppLocalizations.of(context).tradingFee,
            style: Theme.of(context).textTheme.caption),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildTradeFee(),
            if (showDetailedFees) _buildTradeFeeInFiat(),
          ],
        )),
      ],
    );
  }

  Widget _buildTradeFee() {
    return Text(
      '${cutTrailingZeros(formatPrice(getTradeFee(widget.baseAmount)))}'
      ' ${widget.baseCoin}',
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildTradeFeeInFiat() {
    return Text(
      cexProvider.convert(
        getTradeFee(widget.baseAmount),
        from: widget.baseCoin,
      ),
      style: Theme.of(context).textTheme.caption.copyWith(color: cexColor),
    );
  }

  Widget _buildTxFeeRow(double txFee) {
    return Row(
      children: <Widget>[
        Text(AppLocalizations.of(context).txFeeTitle,
            style: Theme.of(context).textTheme.caption),
        Expanded(
            child: FutureBuilder<double>(
                future: getGasFee(widget.relCoin),
                builder: (context, snapshot) {
                  final double gasFee = snapshot.data ?? 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      _buildTxFee(txFee, gasFee),
                      if (showDetailedFees) _buildTxFeeInFiat(txFee, gasFee),
                    ],
                  );
                })),
      ],
    );
  }

  Widget _buildTxFee(double txFee, double gasFee) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '${cutTrailingZeros(formatPrice(txFee))}'
          ' ${widget.baseCoin}',
          style: Theme.of(context).textTheme.caption,
        ),
        _buildGasFee(gasFee),
      ],
    );
  }

  Widget _buildGasFee(double gasFee) {
    if (gasFee == null || gasFee == 0) return SizedBox();
    if (!widget.includeGasFee) return SizedBox();
    if (widget.relCoin == null) return SizedBox();

    final String payGasIn = coinsBloc.getCoinByAbbr(widget.relCoin).payGasIn;
    if (payGasIn == null) return SizedBox();

    return Text(
      ' + ${cutTrailingZeros(formatPrice(gasFee))}'
      ' $payGasIn',
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildTxFeeInFiat(double txFee, double gasFee) {
    final double baseUsdPrice = cexProvider.getUsdPrice(widget.baseCoin);
    final double gasUsdPrice = cexProvider
        .getUsdPrice(coinsBloc.getCoinByAbbr(widget.relCoin)?.payGasIn);

    double totalTxFeeUsd = txFee * baseUsdPrice;
    if (widget.includeGasFee && gasUsdPrice != 0) {
      totalTxFeeUsd = totalTxFeeUsd + gasFee * gasUsdPrice;
    }

    return Text(
      cexProvider.convert(totalTxFeeUsd),
      style: Theme.of(context).textTheme.caption.copyWith(color: cexColor),
    );
  }
}

Future<double> getTxFee(String coin) async {
  if (coin == null) return null;

  try {
    final dynamic tradeFeeResponse =
        await MM.getTradeFee(MMService().client, GetTradeFee(coin: coin));

    if (tradeFeeResponse is TradeFee) {
      // TODO: deal with 'magic' x2
      return double.parse(tradeFeeResponse.result.amount) * 2;
    } else {
      return null;
    }
  } catch (e) {
    Log('build_trade_fees] failed to get tx fee', e);
    rethrow;
  }
}

Future<double> getGasFee(String coin) async {
  if (coin == null) return null;

  try {
    final dynamic tradeFeeResponse =
        await MM.getTradeFee(MMService().client, GetTradeFee(coin: coin));

    if (tradeFeeResponse is TradeFee) {
      return double.parse(tradeFeeResponse.result.amount);
    } else {
      return null;
    }
  } catch (e) {
    Log('build_trade_fees] failed to get gas fee', e);
    rethrow;
  }
}

double getTradeFee(double amt) {
  if (amt == null) return null;
  return amt / 777;
}
