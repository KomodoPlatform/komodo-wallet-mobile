import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class SwapFeesFromTrade extends StatefulWidget {
  const SwapFeesFromTrade({this.preimage});

  final TradePreimage preimage;

  @override
  _SwapFeesFromTradeState createState() => _SwapFeesFromTradeState();
}

class _SwapFeesFromTradeState extends State<SwapFeesFromTrade> {
  bool _isTaker;
  CexProvider _cexProvider;
  bool _showFiatAmounts = false;
  bool _haveCexPrices;

  @override
  Widget build(BuildContext context) {
    if (widget.preimage == null) return SizedBox();

    _isTaker = widget.preimage.request.swapMethod == 'buy';

    final CoinFee fee =
        _isTaker ? widget.preimage.baseCoinFee : widget.preimage.relCoinFee;

    if (!fee.paidFromTradingVol) return SizedBox();

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
    final String fee = _receiveCoinTxFee();
    if (fee == null) return SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          fee,
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  String _receiveCoinTxFee() {
    final CoinFee receiveCoinFee =
        _isTaker ? widget.preimage.baseCoinFee : widget.preimage.relCoinFee;

    if (!receiveCoinFee.paidFromTradingVol) return null;
    if ((double.tryParse(receiveCoinFee.amount ?? '0') ?? 0) <= 0) return null;

    return '${cutTrailingZeros(formatPrice(receiveCoinFee.amount, 4))}'
        ' ${receiveCoinFee.coin}';
  }

  Widget _buildTxFeeInFiat() {
    final CoinFee fee =
        _isTaker ? widget.preimage.baseCoinFee : widget.preimage.relCoinFee;
    final double feeAmountUsd = (double.tryParse(fee.amount ?? '0') ?? 0) *
        _cexProvider.getUsdPrice(fee.coin);

    return Text(
      _cexProvider.convert(feeAmountUsd),
      style: Theme.of(context).textTheme.caption.copyWith(
            color: settingsBloc.isLightTheme
                ? cexColorLight.withAlpha(150)
                : cexColor.withAlpha(150),
          ),
    );
  }

  bool _haveAllCexPrices() {
    final CoinFee fee =
        _isTaker ? widget.preimage.baseCoinFee : widget.preimage.relCoinFee;

    final double amount = double.tryParse(fee.amount ?? '0') ?? 0;
    final double price = _cexProvider.getUsdPrice(fee.coin);
    if (fee.paidFromTradingVol && amount > 0 && price == 0) return false;

    return true;
  }
}
