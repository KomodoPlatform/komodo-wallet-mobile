import 'package:flutter/material.dart';
import '../../../../generic_blocs/swap_bloc.dart';
import '../../../../model/cex_provider.dart';
import '../../../dex/trade/pro/create/trade_form.dart';
import '../../../../utils/utils.dart';
import 'package:provider/provider.dart';

import '../../../../localizations.dart';

class ExchangeRate extends StatefulWidget {
  const ExchangeRate({
    this.alignCenter = false,
  });

  final bool alignCenter;

  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  bool _showDetails = false;
  String? _buyAbbr;
  String? _sellAbbr;
  double? _rate;

  CexProvider? _cexProvider;

  @override
  Widget build(BuildContext context) {
    _init();

    if (_rate == null) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
        child: Opacity(
            opacity: 0.2,
            child: Row(
              mainAxisAlignment: widget.alignCenter
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.exchangeRate,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            )),
      );
    }

    return Column(
      crossAxisAlignment: widget.alignCenter
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeader(),
        if (_showDetails) _buildDetails(),
      ],
    );
  }

  void _init() {
    _cexProvider ??= Provider.of<CexProvider>(context);

    _buyAbbr = swapBloc.receiveCoinBalance?.coin?.abbr;
    _sellAbbr = swapBloc.sellCoinBalance?.coin?.abbr;

    if (_buyAbbr == null ||
        _sellAbbr == null ||
        (swapBloc.amountSell ?? 0) == 0 ||
        (swapBloc.amountReceive ?? 0) == 0) {
      _rate = null;
      return;
    }

    _rate = tradeForm.getExchangeRate();
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 2, 6, 6),
        child: Row(
          mainAxisAlignment: widget.alignCenter
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            _buildRateHeader(),
            Icon(
              _showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: _buildBackRate(),
    );
  }

  Widget _buildRateHeader() {
    if (_rate == null) return SizedBox();

    final String? exchangeRate = formatPrice(_rate);
    return Row(
      children: [
        Text(
          '1 $_sellAbbr = ',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Text(
          '$exchangeRate ',
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Theme.of(context).textTheme.bodyText2!.color),
        ),
        Text(
          _buyAbbr!,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  Widget _buildBackRate() {
    final String? exchangeRateBack = formatPrice(1 / _rate!);

    return Text(
      '1 $_buyAbbr = $exchangeRateBack $_sellAbbr',
      style: TextStyle(fontSize: 13),
    );
  }
}
