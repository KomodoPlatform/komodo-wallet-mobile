import 'package:flutter/material.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:provider/provider.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/utils/utils.dart';

class ExchangeRateSimple extends StatefulWidget {
  @override
  _ExchangeRateSimpleState createState() => _ExchangeRateSimpleState();
}

class _ExchangeRateSimpleState extends State<ExchangeRateSimple> {
  ConstructorProvider _constrProvider;
  bool _showDetails = false;
  String _buyAbbr;
  String _sellAbbr;
  double _rate;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _init();

    if (_rate == null) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
        child: Opacity(
            opacity: 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Exchange rate:',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            )),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildHeader(),
        if (_showDetails) _buildDetails(),
      ],
    );
  }

  void _init() {
    _buyAbbr = _constrProvider.buyCoin;
    _sellAbbr = _constrProvider.sellCoin;

    if (_constrProvider.matchingOrder == null) {
      _rate = null;
    } else {
      final Rational price = _constrProvider.matchingOrder.action == Market.SELL
          ? _constrProvider.matchingOrder.price
          : _constrProvider.matchingOrder.price.inverse;
      _rate = price.toDouble();
    }
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 2, 6, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRateHeader(),
            Icon(
              _showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 16,
              color: Theme.of(context).textTheme.bodyText1.color,
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

    final String exchangeRate = formatPrice(_rate);
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
              .bodyText1
              .copyWith(color: Theme.of(context).textTheme.bodyText2.color),
        ),
        Text(
          '$_buyAbbr',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  Widget _buildBackRate() {
    final String exchangeRateBack = formatPrice(1 / _rate);

    return Text(
      '1 $_buyAbbr = $exchangeRateBack $_sellAbbr',
      style: TextStyle(fontSize: 13),
    );
  }
}
