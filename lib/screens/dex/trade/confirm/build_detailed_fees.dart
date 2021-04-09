import 'package:flutter/material.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuildDetailedFees extends StatefulWidget {
  const BuildDetailedFees({
    this.preimage,
    this.alignCenter = false,
  });

  final TradePreimage preimage;
  final bool alignCenter;

  @override
  _BuildDetailedFeesState createState() => _BuildDetailedFeesState();
}

class _BuildDetailedFeesState extends State<BuildDetailedFees> {
  CexProvider _cexProvider;
  bool _showDetails = false;
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
        ? SizedBox()
        : Container(
            padding: EdgeInsets.fromLTRB(26, 0, 26, 0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).highlightColor,
                ),
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  if (_showDetails) _buildDetails(),
                ],
              ),
            ),
          );
  }

  void _init() {
    _cexProvider ??= Provider.of<CexProvider>(context);

    if (widget.preimage != null) {
      final bool isTaker = widget.preimage.request.swapMethod == 'buy';
      final TradePreimage preimage = widget.preimage;
      setState(() {
        _sellCoin = isTaker ? preimage.request.rel : preimage.request.base;
        _receiveCoin = isTaker ? preimage.request.base : preimage.request.rel;
        _sellTxFee = isTaker ? preimage.relCoinFee : preimage.baseCoinFee;
        _sellTxFee = isTaker ? preimage.relCoinFee : preimage.baseCoinFee;
        _receiveTxFee = isTaker ? preimage.baseCoinFee : preimage.relCoinFee;
        print(isTaker);
        if (isTaker) {
          _dexFee = preimage.takerFee;
          _feeToSendDexFee = preimage.feeToSendTakerFee;
        }
      });
    }
  }

  Widget _buildHeader() {
    final String total = _getTotalFee();

    return InkWell(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 4, 0, 6),
        child: Row(
          mainAxisAlignment: widget.alignCenter
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Text(
              'Total fees: ',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Flexible(
              child: Text(
                total,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withAlpha(220)),
              ),
            ),
            Icon(
              _showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16,
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
          ],
        ),
      ),
    );
  }

  String _getTotalFee() {
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

    return totalFees;
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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
            color: Theme.of(context).highlightColor.withAlpha(25),
            child: Text(
              'Paid from balance:',
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
      ),
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
          '• None',
          style: Theme.of(context).textTheme.caption,
        ),
      ));

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
            color: Theme.of(context).highlightColor.withAlpha(25),
            child: Text(
              'Paid from received volume:',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          SizedBox(height: 4),
          ...items,
        ],
      ),
    );
  }
}
