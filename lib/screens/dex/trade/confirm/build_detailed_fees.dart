import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuildDetailedFees extends StatefulWidget {
  const BuildDetailedFees(this.preimage);

  final TradePreimage preimage;

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
  void initState() {
    if (widget.preimage != null) {
      final bool isTaker = widget.preimage.request.method == 'buy';
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
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _cexProvider ??= Provider.of<CexProvider>(context);

    return widget.preimage == null
        ? SizedBox()
        : Container(
            padding: EdgeInsets.fromLTRB(26, 0, 26, 0),
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
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

  Widget _buildHeader() {
    final String total = _getTotalFee();

    return InkWell(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        totalFees += '${cutTrailingZeros(formatPrice(amount))}$nbsp$coin';
      }
    });

    return totalFees;
  }

  Widget _buildDetails() {
    final TradePreimage preimage = swapBloc.tradePreimage;
    final bool isTaker = preimage.request.swapMethod == 'buy';
    final CoinFee sellCoinTxFee =
        isTaker ? preimage.relCoinFee : preimage.baseCoinFee;
    final CoinFee receiveCoinTxFee =
        isTaker ? preimage.baseCoinFee : preimage.relCoinFee;
    final CoinFee dexFee = isTaker ? preimage.takerFee : null;
    final CoinFee feeToPayDex = isTaker ? preimage.feeToSendTakerFee : null;
    final String sellCoin =
        isTaker ? preimage.request.rel : preimage.request.base;
    final String receiveCoin =
        isTaker ? preimage.request.base : preimage.request.rel;

    return Container(
      width: double.infinity,
      child: Column(
        children: [
          if (sellCoinTxFee != null && !sellCoinTxFee.paidFromTradingVol)
            Text(
              '+ ${cutTrailingZeros(formatPrice(sellCoinTxFee.amount))} '
              '${sellCoinTxFee.coin} '
              '(send $sellCoin tx fee)',
              style: TextStyle(fontSize: 12),
            ),
          if (receiveCoinTxFee != null && !receiveCoinTxFee.paidFromTradingVol)
            Text(
              '+ ${cutTrailingZeros(formatPrice(receiveCoinTxFee.amount))} '
              '${receiveCoinTxFee.coin} '
              '(receive $receiveCoin tx fee)',
              style: TextStyle(fontSize: 12),
            ),
          if (dexFee != null && !dexFee.paidFromTradingVol)
            Text(
              '+ ${cutTrailingZeros(formatPrice(dexFee.amount))} '
              '${dexFee.coin} '
              '(DEX-fee)',
              style: TextStyle(fontSize: 12),
            ),
          if (feeToPayDex != null && !feeToPayDex.paidFromTradingVol)
            Text(
              '+ ${cutTrailingZeros(formatPrice(feeToPayDex.amount))} '
              '${feeToPayDex.coin} '
              '(send DEX-fee tx fee)',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }
}
