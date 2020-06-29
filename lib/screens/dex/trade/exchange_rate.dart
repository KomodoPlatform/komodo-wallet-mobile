import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';

class ExchangeRate extends StatefulWidget {
  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  @override
  Widget build(BuildContext context) {
    final String buyAbbr = swapBloc.buyCoinBalance?.coin?.abbr;
    final String sellAbbr = swapBloc.sellCoinBalance?.coin?.abbr;

    if (buyAbbr == null || sellAbbr == null) return Container();

    final double rate = swapBloc.getExchangeRate();
    final double cexRate = swapBloc.getCExchangeRate();

    Widget _buildExchangeRate() {
      if (rate == null) return Container();

      final String exchangeRate =
          OrderBookProvider.formatPrice(rate.toString());
      final String exchangeRateQuoted =
          OrderBookProvider.formatPrice((1 / rate).toString());

      return Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).bestAvailableRate,
            style: Theme.of(context).textTheme.body2,
          ),
          Text(
            '1 $buyAbbr = $exchangeRate $sellAbbr',
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '1 $sellAbbr = $exchangeRateQuoted $buyAbbr',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      );
    }

    Widget _buildCExchangeRate() {
      if (cexRate == null) return Container();

      final String cExchangeRate =
          OrderBookProvider.formatPrice(cexRate.toString());
      final String cExchangeRateQuoted =
          OrderBookProvider.formatPrice((1 / cexRate).toString());

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
            '1 $buyAbbr = $cExchangeRate $sellAbbr',
            style: Theme.of(context).textTheme.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cexColor,
                ),
          ),
          Text(
            '1 $sellAbbr = $cExchangeRateQuoted $buyAbbr',
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
      if (rate == null || cexRate == null) return Container();

      const double range = 5;
      final num sign = (rate - cexRate).sign;
      final double percent = ((rate - cexRate) * 100 / rate).abs();
      final percentString =
          OrderBookProvider.formatPrice(percent.toString(), 2);
      String message;
      Color color;

      switch (sign) {
        case -1:
          {
            if (percent > range) {
              color = Colors.green;
            }
            message =
                'Expedient: -$percentString% compared to CEX'; // TODO(yurii): localization
            break;
          }
        case 1:
          {
            if (percent > range) {
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

      return Column(
        children: <Widget>[
          Text(
            message,
            style: TextStyle(
              color: color,
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          _buildExchangeRate(),
          _buildIndicator(),
          _buildCExchangeRate(),
        ],
      ),
    );
  }
}
