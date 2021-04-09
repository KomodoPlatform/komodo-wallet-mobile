import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class ExchangeRate extends StatefulWidget {
  const ExchangeRate({
    this.alignCenter = false,
  });

  final bool alignCenter;

  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  final double _sliderH = 4;
  final double _neutralRange = 5; // % - show lower values in neutral color
  bool _showDetails = false;
  bool _canShowEvaluation = false;
  double _sliderW;
  num _sign;
  double _percent;
  int _indicatorRange;
  String _buyAbbr;
  String _sellAbbr;
  double _rate;
  double _cexRate;

  CexProvider _cexProvider;

  @override
  Widget build(BuildContext context) {
    _init();

    if (_buyAbbr == null || _sellAbbr == null) return SizedBox();

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

    if (_buyAbbr == null || _sellAbbr == null) return;

    _rate = tradeForm.getExchangeRate();
    _cexRate = _cexProvider.getCexRate();

    _canShowEvaluation = _rate != null && _cexRate != null && _cexRate != 0.0;
    if (!_canShowEvaluation) return;

    _sliderW = _sliderW = MediaQuery.of(context).size.width * 2 / 3;

    _sign = (_cexRate - _rate).sign;
    _percent = ((_cexRate - _rate) * 100 / _rate).abs();
    if (_percent > 99) _percent = 99;
    if (_percent < -99) _percent = -99;
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
            _canShowEvaluation ? _buildEvaluationHeader() : _buildRateHeader(),
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
    if (_canShowEvaluation) {
      return _buildEvaluation();
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
        child: _buildBackRate(),
      );
    }
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

  Widget _buildExchangeRate() {
    if (_rate == null) return Container();

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: widget.alignCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '1 $_sellAbbr = ${cutTrailingZeros(formatPrice(_rate))} $_buyAbbr',
          ),
          _buildBackRate(),
          const SizedBox(
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildBackRate() {
    final String exchangeRateBack = formatPrice(1 / _rate);

    return Text(
      '1 $_buyAbbr = $exchangeRateBack $_sellAbbr',
      style: TextStyle(fontSize: 13),
    );
  }

  Widget _buildEvaluation() {
    if (!_canShowEvaluation) return SizedBox();

    return Container(
      padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
      child: Column(
        crossAxisAlignment: widget.alignCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          _buildEvaluationSlider(),
          SizedBox(height: 12),
          Text(
            'Exchange rate:',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 4),
          _buildExchangeRate(),
        ],
      ),
    );
  }

  Widget _buildEvaluationHeader() {
    final String percentString = formatPrice(_percent.toString(), 2);
    Widget message;
    Color color;

    switch (_sign) {
      case -1:
        {
          message = Row(children: [
            Text(
              AppLocalizations.of(context).exchangeExpedient + ': ',
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
      case 1:
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

  Widget _buildEvaluationSlider() {
    if (!_canShowEvaluation) return SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '-$_indicatorRange%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.greenAccent,
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
                          colors: [Colors.green, Colors.grey]),
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
                          colors: [Colors.grey, Colors.orangeAccent]),
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
            color: Colors.orangeAccent,
          ),
        ),
      ],
    );
  }
}
