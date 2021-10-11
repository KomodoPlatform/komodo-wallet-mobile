import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:komodo_dex/model/market.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:provider/provider.dart';

class EvaluationSimple extends StatefulWidget {
  const EvaluationSimple({
    this.alignCenter = false,
  });

  final bool alignCenter;
  @override
  _EvaluationSimpleState createState() => _EvaluationSimpleState();
}

class _EvaluationSimpleState extends State<EvaluationSimple> {
  final double _sliderH = 4;
  final double _neutralRange = 5; // % - show lower values in neutral color
  bool _showDetails = false;
  double _sliderW;
  num _sign;
  double _percent;
  int _indicatorRange;
  String _buyAbbr;
  String _sellAbbr;
  double _rate;
  double _cexRate;

  CexProvider _cexProvider;
  ConstructorProvider _constrProvider;

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _init();

    if (_rate == null || _cexRate == null || _cexRate == 0.0) {
      return SizedBox();
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

    _buyAbbr = _constrProvider.buyCoin;
    _sellAbbr = _constrProvider.sellCoin;

    if (_buyAbbr == null || _sellAbbr == null) {
      _rate = null;
      _cexRate = null;
      return;
    }

    final Rational price = _constrProvider.matchingOrder.action == Market.SELL
        ? _constrProvider.matchingOrder.price
        : _constrProvider.matchingOrder.price.inverse;
    _rate = price.toDouble();
    _cexRate = _cexProvider.getCexRate(
        CoinsPair(sell: Coin(abbr: _sellAbbr), buy: Coin(abbr: _buyAbbr)));

    if (_rate == null || _cexRate == null || _cexRate == 0.0) return;

    _sliderW = MediaQuery.of(context).size.width / 5 * 3;

    _sign = (_rate - _cexRate).sign;
    _percent = ((_rate - _cexRate) * 100 / _cexRate).abs();
    if (_percent > 99.99) _percent = 99.99;
    if (_percent < -99.99) _percent = -99.99;
    _indicatorRange = (_neutralRange * 2).round();
    if (_percent > _indicatorRange) {
      // log_n(x) = log_e(x) / log_e(n)
      final power = (math.log(_percent) / math.log(10)).ceil();
      // Round up to the closest power of 10
      _indicatorRange = math.pow(10, power);
    }
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
            _buildEvaluationSimpleHeader(),
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
    return _buildEvaluationSimple();
  }

  Widget _buildEvaluationSimple() {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 4, 6, 0),
      child: Column(
        crossAxisAlignment: widget.alignCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          _buildCexRate(),
          SizedBox(height: 8),
          _buildEvaluationSimpleSlider(),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCexRate() {
    return Container(
      child: Row(
        mainAxisAlignment: widget.alignCenter
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          CexMarker(context, size: Size.fromRadius(6)),
          SizedBox(width: 2),
          Text(
            'CEX Rate: 1 $_sellAbbr = '
            '${cutTrailingZeros(formatPrice(_cexRate))} $_buyAbbr',
            style: TextStyle(
              fontSize: 12,
              color: settingsBloc.isLightTheme ? cexColorLight : cexColor,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEvaluationSimpleHeader() {
    final String percentString = formatPrice(_percent.toString(), 2);
    Widget message;
    Color color;

    switch (_sign) {
      case 1:
        {
          color = Colors.green;
          message = Row(children: [
            Text(
              AppLocalizations.of(context).exchangeExpedient + ': ',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              '+$percentString% ',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: color ?? Theme.of(context).textTheme.bodyText2.color,
                  ),
            ),
            Text(
              AppLocalizations.of(context).comparedToCex,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ]);
          break;
        }
      case -1:
        {
          if (_percent > _neutralRange) {
            color = Colors.orange;
          }
          message = Row(children: [
            Text(
              AppLocalizations.of(context).exchangeExpensive + ': ',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              '-$percentString% ',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: color ?? Theme.of(context).textTheme.bodyText2.color,
                  ),
            ),
            Text(
              AppLocalizations.of(context).comparedToCex,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ]);
          break;
        }
      default:
        {
          message = Text(
            AppLocalizations.of(context).exchangeIdentical,
            style: Theme.of(context).textTheme.bodyText1,
          );
        }
    }

    return message;
  }

  Widget _buildEvaluationSimpleSlider() {
    return Row(
      mainAxisAlignment: widget.alignCenter
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: <Widget>[
        Text(
          '-$_indicatorRange%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: _sliderW,
          height: _sliderH * 2,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                  left: 0,
                  top: _sliderH / 2,
                  child: Container(
                    width: _sliderW / 2,
                    height: _sliderH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.orangeAccent, Colors.grey]),
                    ),
                  )),
              Positioned(
                  left: _sliderW / 2,
                  top: _sliderH / 2,
                  child: Container(
                    width: _sliderW / 2,
                    height: _sliderH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.grey, Colors.green]),
                    ),
                  )),
              Positioned(
                  left: ((_sliderW / 2) - _sliderH / 2) +
                      _sign * _percent * _sliderW / _indicatorRange / 2,
                  top: 0,
                  width: _sliderH,
                  height: _sliderH * 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '+$_indicatorRange%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
