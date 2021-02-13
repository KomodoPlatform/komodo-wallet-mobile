import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/screens/dex/trade/get_swap_fee.dart';
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

    return FutureBuilder<CoinAmt>(
      future: GetSwapFee.tx(widget.baseCoin),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final CoinAmt tradeFee = GetSwapFee.trading(widget.baseAmount);
        final CoinAmt txFee = snapshot.data;

        if (txFee == null || tradeFee == null) return const SizedBox();

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
      '${cutTrailingZeros(formatPrice(GetSwapFee.trading(widget.baseAmount).amount))}'
      ' ${widget.baseCoin}',
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildTradeFeeInFiat() {
    return Text(
      cexProvider.convert(
        GetSwapFee.trading(widget.baseAmount).amount,
        from: widget.baseCoin,
      ),
      style: Theme.of(context).textTheme.caption.copyWith(color: cexColor),
    );
  }

  Widget _buildTxFeeRow(CoinAmt txFee) {
    return Row(
      children: <Widget>[
        Text(AppLocalizations.of(context).txFeeTitle,
            style: Theme.of(context).textTheme.caption),
        Expanded(
            child: FutureBuilder<CoinAmt>(
                future: GetSwapFee.gas(widget.relCoin),
                builder: (context, snapshot) {
                  final CoinAmt gasFee = snapshot.data;

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

  Widget _buildTxFee(CoinAmt txFee, CoinAmt gasFee) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '${cutTrailingZeros(formatPrice(txFee.amount))}'
          ' ${txFee.coin}',
          style: Theme.of(context).textTheme.caption,
        ),
        _buildGasFee(gasFee),
      ],
    );
  }

  Widget _buildGasFee(CoinAmt gasFee) {
    if (gasFee == null || gasFee.amount == 0) return SizedBox();
    if (!widget.includeGasFee) return SizedBox();
    if (widget.relCoin == null) return SizedBox();

    return Text(
      ' + ${cutTrailingZeros(formatPrice(gasFee.amount))}'
      ' ${gasFee.coin}',
      style: Theme.of(context).textTheme.caption,
    );
  }

  Widget _buildTxFeeInFiat(CoinAmt txFee, CoinAmt gasFee) {
    if (txFee == null) return SizedBox();

    final double txUsdPrice = cexProvider.getUsdPrice(txFee?.coin);
    final double gasUsdPrice = cexProvider.getUsdPrice(gasFee?.coin) ?? 0.0;

    double totalTxFeeUsd = txFee.amount * txUsdPrice;
    if (widget.includeGasFee && gasUsdPrice != 0) {
      totalTxFeeUsd += gasFee.amount * gasUsdPrice;
    }

    return Text(
      cexProvider.convert(totalTxFeeUsd),
      style: Theme.of(context).textTheme.caption.copyWith(color: cexColor),
    );
  }
}
