import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class SwapFeesFromBalance extends StatefulWidget {
  const SwapFeesFromBalance({this.preimage});

  final TradePreimage preimage;

  @override
  _SwapFeesFromBalanceState createState() => _SwapFeesFromBalanceState();
}

class _SwapFeesFromBalanceState extends State<SwapFeesFromBalance> {
  bool _isTaker;
  CexProvider _cexProvider;
  bool _showFiatAmounts = false;
  bool _haveCexPrices;

  @override
  Widget build(BuildContext context) {
    if (widget.preimage == null) return SizedBox();

    _isTaker = widget.preimage.request.swapMethod == 'buy';
    _cexProvider ??= Provider.of<CexProvider>(context);
    _haveCexPrices = _haveAllCexPrices();
    if (!_haveCexPrices) setState(() => _showFiatAmounts = false);

    return InkWell(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTxFeeRow(),
                if (_showFiatAmounts) const SizedBox(height: 4),
                _buildTakerFeeRow(),
              ],
            ),
          ),
          if (_haveCexPrices)
            Container(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                _showFiatAmounts ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Theme.of(context).textTheme.caption.color,
                size: 18,
              ),
            ),
        ],
      ),
      onTap: _haveCexPrices
          ? () => setState(() => _showFiatAmounts = !_showFiatAmounts)
          : null,
    );
  }

  Widget _buildTakerFeeRow() {
    if (!_isTaker) return SizedBox();

    return Row(
      children: <Widget>[
        Text(AppLocalizations.of(context).tradingFee,
            style: Theme.of(context).textTheme.caption),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildTakerFee(),
            if (_showFiatAmounts) _buildTakerFeeInFiat(),
          ],
        )),
      ],
    );
  }

  Widget _buildTakerFee() {
    final CoinFee feeToSendFee = widget.preimage.feeToSendTakerFee;
    final double feeAmount =
        double.tryParse(widget.preimage.takerFee.amount ?? '0') ?? 0;
    final double feeToSendFeeAmount =
        double.tryParse(feeToSendFee.amount ?? '0') ?? 0;

    if (feeToSendFee?.coin == widget.preimage.request.rel) {
      final double amount = feeAmount + feeToSendFeeAmount;
      return Text(
        '${cutTrailingZeros(formatPrice(amount, 4))}'
        ' ${widget.preimage.request.rel}',
        style: Theme.of(context).textTheme.caption,
      );
    } else {
      return Row(
        children: [
          Text(
            '${cutTrailingZeros(formatPrice(feeAmount, 4))}'
            ' ${widget.preimage.request.rel}',
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            ' + ${cutTrailingZeros(formatPrice(feeToSendFeeAmount, 4))}'
            ' ${feeToSendFee.coin}',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      );
    }
  }

  Widget _buildTakerFeeInFiat() {
    final double takerFeeUsd =
        (double.tryParse(widget.preimage.takerFee.amount ?? '0') ?? 0) *
            _cexProvider.getUsdPrice(widget.preimage.takerFee.coin);

    final double feeToSendFeeUsd =
        (double.tryParse(widget.preimage.feeToSendTakerFee.amount) ?? 0) *
            _cexProvider.getUsdPrice(widget.preimage.feeToSendTakerFee.coin);

    return Text(
      _cexProvider.convert(takerFeeUsd + feeToSendFeeUsd),
      style: Theme.of(context).textTheme.caption.copyWith(color: cexColor),
    );
  }

  Widget _buildTxFeeRow() {
    return Row(
      children: <Widget>[
        Text(AppLocalizations.of(context).txFeeTitle,
            style: Theme.of(context).textTheme.caption),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildTxFee(),
            if (_showFiatAmounts) _buildTxFeeInFiat(),
          ],
        )),
      ],
    );
  }

  Widget _buildTxFee() {
    final List<String> txFees = [
      if (_sellCoinTxFee() != null) _sellCoinTxFee(),
      if (_receiveCoinTxFee() != null) _receiveCoinTxFee(),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          txFees.join(' + '),
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  String _sellCoinTxFee() {
    final CoinFee sellCoinFee =
        _isTaker ? widget.preimage.relCoinFee : widget.preimage.baseCoinFee;

    if (sellCoinFee.paidFromTradingVol) return null;
    if ((double.tryParse(sellCoinFee.amount ?? '0') ?? 0) <= 0) return null;

    return '${cutTrailingZeros(formatPrice(sellCoinFee.amount, 4))}'
        ' ${sellCoinFee.coin}';
  }

  String _receiveCoinTxFee() {
    final CoinFee receiveCoinFee =
        _isTaker ? widget.preimage.baseCoinFee : widget.preimage.relCoinFee;

    if (receiveCoinFee.paidFromTradingVol) return null;
    if ((double.tryParse(receiveCoinFee.amount ?? '0') ?? 0) <= 0) return null;

    return '${cutTrailingZeros(formatPrice(receiveCoinFee.amount, 4))}'
        ' ${receiveCoinFee.coin}';
  }

  Widget _buildTxFeeInFiat() {
    final double baseFeeUsd =
        (double.tryParse(widget.preimage.baseCoinFee?.amount ?? '0') ?? 0) *
            _cexProvider.getUsdPrice(widget.preimage.baseCoinFee.coin);

    final double relFeeUsd =
        (double.tryParse(widget.preimage.relCoinFee?.amount ?? '0') ?? 0) *
            _cexProvider.getUsdPrice(widget.preimage.relCoinFee.coin);

    return Text(
      _cexProvider.convert(baseFeeUsd + relFeeUsd),
      style: Theme.of(context).textTheme.caption.copyWith(color: cexColor),
    );
  }

  bool _haveAllCexPrices() {
    final CoinFee relCoinFee = widget.preimage.relCoinFee;
    final double relCoinFeeAmount =
        double.tryParse(relCoinFee.amount ?? '0') ?? 0;
    final double relCoinFeeUsdPrice = _cexProvider.getUsdPrice(relCoinFee.coin);
    if ((!relCoinFee.paidFromTradingVol) &&
        relCoinFeeAmount > 0 &&
        relCoinFeeUsdPrice == 0) return false;

    final CoinFee baseCoinFee = widget.preimage.baseCoinFee;
    final double baseCoinFeeAmount =
        double.tryParse(baseCoinFee.amount ?? '0') ?? 0;
    final double baseCoinFeeUsdPrice =
        _cexProvider.getUsdPrice(baseCoinFee.coin);
    if ((!baseCoinFee.paidFromTradingVol) &&
        baseCoinFeeAmount > 0 &&
        baseCoinFeeUsdPrice == 0) return false;

    if (_isTaker) {
      final double takerFeeAmount =
          double.tryParse(widget.preimage.takerFee.amount ?? '0') ?? 0;
      final double takerFeeCoinUsdPrice =
          _cexProvider.getUsdPrice(widget.preimage.takerFee.coin);
      if (takerFeeAmount > 0 && takerFeeCoinUsdPrice == 0) return false;

      final double feeToSendFeeAmount =
          double.tryParse(widget.preimage.feeToSendTakerFee.amount ?? '0') ?? 0;
      final double feeToSendFeeCoinUsdPrice =
          _cexProvider.getUsdPrice(widget.preimage.feeToSendTakerFee.coin);
      if (feeToSendFeeAmount > 0 && feeToSendFeeCoinUsdPrice == 0) return false;
    }

    return true;
  }
}
