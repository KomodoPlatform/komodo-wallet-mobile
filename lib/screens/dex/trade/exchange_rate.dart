import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class ExchangeRate extends StatefulWidget {
  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  CexProvider _cexProvider;
  OrderBookProvider _orderBookProvider;
  String _buyAbbr;
  String _sellAbbr;
  double _rate;
  double _cexRate;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    _cexProvider ??= Provider.of<CexProvider>(context);
    _orderBookProvider ??= Provider.of<OrderBookProvider>(context);

    _buyAbbr = swapBloc.receiveCoinBalance?.coin?.abbr;
    _sellAbbr = swapBloc.sellCoinBalance?.coin?.abbr;

    if (_buyAbbr == null || _sellAbbr == null) return SizedBox();

    _rate = tradeForm.getExchangeRate();
    _cexRate = _cexProvider.getCexRate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildIndicator(),
        if (_showDetails) _buildExchangeRate(),
      ],
    );
  }

  Widget _buildExchangeRate() {
    if (_rate == null) return Container();

    final String exchangeRate = formatPrice(_rate);
    final String exchangeRateBack = formatPrice(1 / _rate);

    return Container(
      padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            '1 $_sellAbbr = $exchangeRate $_buyAbbr',
          ),
          Text(
            '1 $_buyAbbr = $exchangeRateBack $_sellAbbr',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildCExchangeRate() {
    if (_cexRate == null || _cexRate == 0.0) return Container();

    final String cExchangeRate = formatPrice(_cexRate);
    final String cExchangeRateBack = formatPrice(1 / _cexRate);

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                CexMarker(context),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  AppLocalizations.of(context).cexChangeRate,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ],
        ),
        Text(
          '1 $_buyAbbr = $cExchangeRateBack $_sellAbbr',
          style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontWeight: FontWeight.bold,
                color: settingsBloc.isLightTheme ? cexColorLight : cexColor,
              ),
        ),
        Text(
          '1 $_sellAbbr = $cExchangeRate $_buyAbbr',
          style: TextStyle(
            fontSize: 13,
            color: settingsBloc.isLightTheme ? cexColorLight : cexColor,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIndicator() {
    if (_rate == null || _cexRate == null || _cexRate == 0.0) return SizedBox();

    const double indicatorH = 4;
    final double indicatorW = MediaQuery.of(context).size.width * 2 / 3;
    const double neutralRange = 5;
    final num sign = (_cexRate - _rate).sign;
    final double percent = ((_cexRate - _rate) * 100 / _rate).abs();
    int indicatorRange = (neutralRange * 2).round();
    if (percent > indicatorRange) {
      // log_n(x) = log_e(x) / log_e(n)
      final power = (math.log(percent) / math.log(10)).ceil();
      // Round up to the closest power of 10
      indicatorRange = math.pow(10, power);
    }
    final percentString = formatPrice(percent.toString(), 2);
    String message;
    Color color;

    switch (sign) {
      case -1:
        {
          if (percent > neutralRange) {
            color = Colors.greenAccent;
          }
          message =
              AppLocalizations.of(context).exchangeExpedient(percentString);
          break;
        }
      case 1:
        {
          if (percent > neutralRange) {
            color = Colors.orange;
          }
          message =
              AppLocalizations.of(context).exchangeExpensive(percentString);
          break;
        }
      default:
        {
          message = AppLocalizations.of(context).echangeIdentical;
        }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: color,
                ),
          ),
          if (_showDetails) ...{
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '-$indicatorRange%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: indicatorW,
                  height: indicatorH * 2,
                  child: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Positioned(
                          left: 0,
                          top: indicatorH / 2,
                          child: Container(
                            width: indicatorW / 2,
                            height: indicatorH,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.green, Colors.grey]),
                            ),
                          )),
                      Positioned(
                          left: indicatorW / 2,
                          top: indicatorH / 2,
                          child: Container(
                            width: indicatorW / 2,
                            height: indicatorH,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.grey, Colors.orangeAccent]),
                            ),
                          )),
                      Positioned(
                          left: ((indicatorW / 2) - indicatorH / 2) +
                              sign * percent * indicatorW / indicatorRange / 2,
                          top: 0,
                          width: indicatorH,
                          height: indicatorH * 2,
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
                  '+$indicatorRange%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          }
        ],
      ),
    );
  }
}
