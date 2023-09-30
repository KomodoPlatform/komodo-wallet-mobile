import 'package:flutter/material.dart';
import 'package:rational/rational.dart';
import 'package:provider/provider.dart';

import '../../../model/cex_provider.dart';
import '../../../model/trade_preimage.dart';
import '../../../utils/utils.dart';

import '../../../localizations.dart';

class BuildDetailedFees extends StatefulWidget {
  const BuildDetailedFees({
    this.preimage,
    this.alignCenter = false,
    this.style,
  });

  final TradePreimage preimage;
  final bool alignCenter;
  final TextStyle style;

  @override
  _BuildDetailedFeesState createState() => _BuildDetailedFeesState();
}

class _BuildDetailedFeesState extends State<BuildDetailedFees> {
  TextStyle _style;
  CexProvider _cexProvider;
  bool _showDetails = false;
  bool _isLarge = false;
  String _sellCoin;
  String _receiveCoin;
  CoinFee _sellTxFee;
  CoinFee _receiveTxFee;
  CoinFee _dexFee;
  CoinFee _feeToSendDexFee;

  @override
  Widget build(BuildContext context) {
    _init();

    return widget.preimage == null
        ? Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
            child: Opacity(
                opacity: 0.2,
                child: Row(
                  mainAxisAlignment: widget.alignCenter
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).totalFees,
                      style:
                          widget.style ?? Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                )),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              if (_showDetails) _buildDetails(),
            ],
          );
  }

  void _init() {
    _cexProvider ??= Provider.of<CexProvider>(context);
    _style = widget.style ?? Theme.of(context).textTheme.bodyText1;

    if (widget.preimage != null) {
      final bool isTaker = widget.preimage.request.swapMethod == 'buy';
      final TradePreimage preimage = widget.preimage;
      setState(() {
        _sellCoin = isTaker ? preimage.request.rel : preimage.request.base;
        _receiveCoin = isTaker ? preimage.request.base : preimage.request.rel;
        _sellTxFee = isTaker ? preimage.relCoinFee : preimage.baseCoinFee;
        _sellTxFee = isTaker ? preimage.relCoinFee : preimage.baseCoinFee;
        _receiveTxFee = isTaker ? preimage.baseCoinFee : preimage.relCoinFee;
        if (isTaker) {
          _dexFee = preimage.takerFee;
          _feeToSendDexFee = preimage.feeToSendTakerFee;
        } else {
          _dexFee = null;
          _feeToSendDexFee = null;
        }
      });
    }
  }

  Widget _buildHeader() {
    final String total = _getTotalFee();

    return InkWell(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
        child: Row(
          mainAxisAlignment: widget.alignCenter
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).totalFees + ' ',
              style: _style,
            ),
            Flexible(
              child: Text(
                total,
                style: _style.copyWith(
                    color: _isLarge
                        ? Colors.orange
                        : Theme.of(context)
                            .textTheme
                            .bodyText2
                            .color
                            .withAlpha(220)),
              ),
            ),
            Icon(
              _showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16,
              color: _style.color,
            ),
          ],
        ),
      ),
    );
  }

  String _getTotalFee() {
    setState(() => _isLarge = false);

    final String nbsp = String.fromCharCode(0x00A0);
    final Map<String, double> normalizedTotals = {
      'USD': 0,
    };

    for (int i = 0; i < widget.preimage.totalFees.length; i++) {
      final CoinFee fee = widget.preimage.totalFees[i];

      final double feeUsdAmount = (double.tryParse(fee.amount ?? '0') ?? 0) *
          _cexProvider.getUsdPrice(fee.coin);

      if (feeUsdAmount > 0) {
        normalizedTotals['USD'] += feeUsdAmount;
      } else {
        final double amount = double.tryParse(fee.amount ?? '0') ?? 0;
        if (amount > 0) normalizedTotals[fee.coin] = amount;
      }
    }

    String totalFees = '';
    normalizedTotals.forEach((String coin, double amount) {
      if (amount == 0) return;

      if (totalFees.isNotEmpty) totalFees += ' +$nbsp';
      if (coin == 'USD') {
        totalFees += _cexProvider.convert(amount);
      } else {
        totalFees += '${cutTrailingZeros(formatPrice(amount, 4))}$nbsp$coin';
      }
    });

    _checkIfLarge(normalizedTotals['USD']);

    return totalFees;
  }

  void _checkIfLarge(double amtUsd) {
    final bool isTaker = widget.preimage.request.swapMethod == 'buy';
    final String sellCoin =
        isTaker ? widget.preimage.request.rel : widget.preimage.request.base;

    final double requestVolume = widget.preimage.request.volume is Rational
        ? widget.preimage.request.volume.toDouble()
        : double.parse(widget.preimage.request.volume);

    final double requestPrice = widget.preimage.request.price is Rational
        ? widget.preimage.request.price.toDouble()
        : double.parse(widget.preimage.request.price);

    final double amountSell =
        isTaker ? requestVolume * requestPrice : requestVolume;

    final double sellAmtUsd = amountSell * cexPrices.getUsdPrice(sellCoin);
    if (sellAmtUsd > 0) {
      setState(() => _isLarge = amtUsd > sellAmtUsd * 0.1);
    }
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _buildPaidFromBalance(),
        SizedBox(height: 4),
        _buildPaidFromTrade(),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildPaidFromBalance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
          color: Theme.of(context).highlightColor.withAlpha(25),
          child: Text(
            AppLocalizations.of(context).paidFromBalance,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        SizedBox(height: 4),
        if (_sellTxFee != null && !_sellTxFee.paidFromTradingVol)
          Container(
            padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
            child: Text(
              '• ${cutTrailingZeros(formatPrice(_sellTxFee.amount))} '
              '${_sellTxFee.coin} '
              '(${_cexProvider.convert(double.tryParse(_sellTxFee.amount), from: _sellTxFee.coin)}): '
              'send $_sellCoin tx fee',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        if (_receiveTxFee != null && !_receiveTxFee.paidFromTradingVol)
          Container(
            padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
            child: Text(
              '• ${cutTrailingZeros(formatPrice(_receiveTxFee.amount))} '
              '${_receiveTxFee.coin} '
              '(${_cexProvider.convert(double.tryParse(_receiveTxFee.amount), from: _receiveTxFee.coin)}): '
              'receive $_receiveCoin tx fee',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        if (_dexFee != null && !_dexFee.paidFromTradingVol)
          Container(
            padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
            child: Text(
              '• ${cutTrailingZeros(formatPrice(_dexFee.amount))} '
              '${_dexFee.coin} '
              '(${_cexProvider.convert(double.tryParse(_dexFee.amount), from: _dexFee.coin)}): '
              'trading fee',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        if (_feeToSendDexFee != null && !_feeToSendDexFee.paidFromTradingVol)
          Container(
            padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
            child: Text(
              '• ${cutTrailingZeros(formatPrice(_feeToSendDexFee.amount))} '
              '${_feeToSendDexFee.coin} '
              '(${_cexProvider.convert(double.tryParse(_feeToSendDexFee.amount), from: _feeToSendDexFee.coin)}): '
              'send trading fee tx fee',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
      ],
    );
  }

  Widget _buildPaidFromTrade() {
    final List<Widget> items = [];

    if (_sellTxFee != null && _sellTxFee.paidFromTradingVol)
      items.add(Container(
        padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
        child: Text(
          '• ${cutTrailingZeros(formatPrice(_sellTxFee.amount))} '
          '${_sellTxFee.coin} '
          '(${_cexProvider.convert(double.tryParse(_sellTxFee.amount), from: _sellTxFee.coin)}): '
          'send $_sellCoin tx fee',
          style: Theme.of(context).textTheme.caption,
        ),
      ));

    if (_receiveTxFee != null && _receiveTxFee.paidFromTradingVol)
      items.add(Container(
        padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
        child: Text(
          '• ${cutTrailingZeros(formatPrice(_receiveTxFee.amount))} '
          '${_receiveTxFee.coin} '
          '(${_cexProvider.convert(double.tryParse(_receiveTxFee.amount), from: _receiveTxFee.coin)}): '
          'receive $_receiveCoin tx fee',
          style: Theme.of(context).textTheme.caption,
        ),
      ));

    if (_dexFee != null && _dexFee.paidFromTradingVol)
      items.add(Container(
        padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
        child: Text(
          '• ${cutTrailingZeros(formatPrice(_dexFee.amount))} '
          '${_dexFee.coin} '
          '(${_cexProvider.convert(double.tryParse(_dexFee.amount), from: _dexFee.coin)}): '
          'trading fee',
          style: Theme.of(context).textTheme.caption,
        ),
      ));

    if (_feeToSendDexFee != null && _feeToSendDexFee.paidFromTradingVol)
      items.add(Container(
        padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
        child: Text(
          '• ${cutTrailingZeros(formatPrice(_feeToSendDexFee.amount))} '
          '${_feeToSendDexFee.coin} '
          '(${_cexProvider.convert(double.tryParse(_feeToSendDexFee.amount), from: _feeToSendDexFee.coin)}): '
          'send trading fee tx fee',
          style: Theme.of(context).textTheme.caption,
        ),
      ));

    if (items.isEmpty)
      items.add(Container(
        padding: EdgeInsets.fromLTRB(8, 2, 4, 2),
        child: Text(
          '• ${AppLocalizations.of(context).none}',
          style: Theme.of(context).textTheme.caption,
        ),
      ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
          color: Theme.of(context).highlightColor.withAlpha(25),
          child: Text(
            AppLocalizations.of(context).paidFromVolume,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        SizedBox(height: 4),
        ...items,
      ],
    );
  }
}
