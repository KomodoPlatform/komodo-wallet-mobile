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

    Widget _buildExchangeRate() {
      final double rate = swapBloc.getExchangeRate();
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
        ],
      );
    }

    Widget _buildCExchangeRate() {
      final double rate = swapBloc.getCExchangeRate();
      if (rate == null) return Container();

      final String cExchangeRate =
          OrderBookProvider.formatPrice(rate.toString());
      final String cExchangeRateQuoted =
          OrderBookProvider.formatPrice((1 / rate).toString());

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
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: <Widget>[
          _buildExchangeRate(),
          const SizedBox(
            height: 12,
          ),
          _buildCExchangeRate(),
        ],
      ),
    );
  }
}
