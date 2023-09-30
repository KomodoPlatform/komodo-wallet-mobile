import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../app_config/theme_data.dart';
import '../../../../blocs/swap_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/cex_provider.dart';
import '../../../../model/coin.dart';
import '../../../../model/order_book_provider.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/cex_data_marker.dart';
import '../../../dex/trade/pro/create/trade_form.dart';

class Evaluation extends StatefulWidget {
  const Evaluation({
    this.alignCenter = false,
  });

  final bool alignCenter;

  @override
  _EvaluationState createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
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

  @override
  Widget build(BuildContext context) {
    _init();

    if (_rate == null || _cexRate == null || _cexRate == 0.0) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
        child:
            Text(String.fromCharCode(0x00A0), style: TextStyle(fontSize: 16)),
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

    if (_buyAbbr == null || _sellAbbr == null) {
      _rate = null;
      _cexRate = null;
      return;
    }

    _rate = tradeForm.getExchangeRate();
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
      onTap: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 2, 6, 6),
        child: Row(
          mainAxisAlignment: widget.alignCenter
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            _buildEvaluationHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return _buildEvaluation();
  }

  Widget _buildEvaluation() {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 4, 6, 0),
      child: Column(
        crossAxisAlignment: widget.alignCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          _buildCexRate(),
          SizedBox(height: 8),
          _buildEvaluationSlider(),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCexRate() {
    return Row(
      mainAxisAlignment: widget.alignCenter
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        CexMarker(context, size: Size.fromRadius(6)),
        SizedBox(width: 2),
        Text(
          '${AppLocalizations.of(context).cexRate}: 1 $_sellAbbr = '
          '${cutTrailingZeros(formatPrice(_cexRate))} $_buyAbbr',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.light
                ? cexColorLight
                : cexColor,
          ),
        )
      ],
    );
  }

  Widget _buildEvaluationHeader() {
    final String percentString = formatPrice(_percent.toString(), 2);
    Widget message;
    Color color;
    bool lessThan10kVol =
        coinsBloc.coinsWithLessThan10kVol.contains(_buyAbbr) ||
            coinsBloc.coinsWithLessThan10kVol.contains(_sellAbbr);

    switch (_sign) {
      case 1:
        {
          message = _message(
            AppLocalizations.of(context).exchangeExpedient,
            percentString,
            Colors.green,
            lessThan10kVol,
          );
          break;
        }
      case -1:
        {
          if (_percent > _neutralRange) {
            color = Colors.orange;
          }
          message = _message(
            AppLocalizations.of(context).exchangeExpensive,
            percentString,
            color,
            lessThan10kVol,
          );

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

  Widget _message(
      String msg, String percentString, Color color, bool lessThan10kVol) {
    return Expanded(
      child: RichText(
        textAlign: widget.alignCenter ? TextAlign.center : TextAlign.start,
        text: TextSpan(
          children: [
            TextSpan(
              text: msg + ': ',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            TextSpan(
              text: '+$percentString% ',
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: color ?? Theme.of(context).textTheme.bodyText2.color,
                  ),
            ),
            TextSpan(
              text: lessThan10kVol
                  ? AppLocalizations.of(context).comparedTo24hrCex
                  : AppLocalizations.of(context).comparedToCex,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            WidgetSpan(
              child: Icon(
                _showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 16,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationSlider() {
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
            clipBehavior: Clip.none,
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
                          colors: const [Colors.orangeAccent, Colors.grey]),
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
                          colors: const [Colors.grey, Colors.green]),
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
                      color: Theme.of(context).colorScheme.secondary,
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
