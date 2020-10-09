import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class ExchangeRate extends StatefulWidget {
  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  CexProvider cexProvider;
  OrderBookProvider orderBookProvider;

  @override
  Widget build(BuildContext context) {
    cexProvider ??= Provider.of<CexProvider>(context);
    orderBookProvider ??= Provider.of<OrderBookProvider>(context);

    final String buyAbbr = swapBloc.buyCoinBalance?.coin?.abbr;
    final String sellAbbr = swapBloc.sellCoinBalance?.coin?.abbr;

    if (buyAbbr == null || sellAbbr == null) return Container();

    final double rate = swapBloc.getExchangeRate();
    final double cexRate = cexProvider.getCexRate();

    Widget _buildExchangeRate() {
      if (rate == null) return Container();

      final String exchangeRate = formatPrice(rate);
      final String exchangeRateBack = formatPrice(1 / rate);

      return Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).bestAvailableRate,
            style: Theme.of(context).textTheme.body2,
          ),
          Text(
            '1 $buyAbbr = $exchangeRateBack $sellAbbr',
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '1 $sellAbbr = $exchangeRate $buyAbbr',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      );
    }

    Widget _buildCExchangeRate() {
      if (cexRate == null || cexRate == 0.0) return Container();

      final String cExchangeRate = formatPrice(cexRate);
      final String cExchangeRateBack = formatPrice(1 / cexRate);

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
                    'CEXchange rate', // TODO(yurii): localization
                    style: Theme.of(context).textTheme.body2,
                  ),
                ],
              ),
            ],
          ),
          Text(
            '1 $buyAbbr = $cExchangeRateBack $sellAbbr',
            style: Theme.of(context).textTheme.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cexColor,
                ),
          ),
          Text(
            '1 $sellAbbr = $cExchangeRate $buyAbbr',
            style: const TextStyle(
              fontSize: 13,
              color: cexColor,
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    Widget _buildIndicator() {
      if (rate == null || cexRate == null || cexRate == 0.0) return Container();

      const double indicatorH = 4;
      final double indicatorW = MediaQuery.of(context).size.width * 2 / 3;
      const double neutralRange = 5;
      final num sign = (cexRate - rate).sign;
      final double percent = ((cexRate - rate) * 100 / rate).abs();
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
                'Expedient: -$percentString% compared to CEX'; // TODO(yurii): localization
            break;
          }
        case 1:
          {
            if (percent > neutralRange) {
              color = Colors.orange;
            }
            message =
                'Expensive: +$percentString% compared to CEX'; // TODO(yurii): localization
            break;
          }
        default:
          {
            message = 'Identical to CEX'; // TODO(yurii): localization
          }
      }

      return Container(
        child: Column(
          children: <Widget>[
            Text(
              message,
              style: TextStyle(
                color: color,
              ),
            ),
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
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          _buildExchangeRate(),
          _buildIndicator(),
          InkWell(
            onTap: () => showCexDialog(context),
            child: _buildCExchangeRate(),
          ),
        ],
      ),
    );
  }
}
