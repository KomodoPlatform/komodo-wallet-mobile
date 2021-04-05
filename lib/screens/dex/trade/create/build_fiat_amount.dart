import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_page.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class BuildFiatAmount extends StatelessWidget {
  const BuildFiatAmount(this.market);

  final Market market;

  @override
  Widget build(BuildContext context) {
    final cexProvider = Provider.of<CexProvider>(context);

    final double amount =
        market == Market.SELL ? swapBloc.amountSell : swapBloc.amountReceive;
    final Coin coin = market == Market.SELL
        ? swapBloc.sellCoinBalance?.coin
        : swapBloc.receiveCoinBalance?.coin;

    if (amount == null || coin == null || amount == 0) return Container();

    final double price = cexProvider.getUsdPrice(coin.abbr);
    if (price == null || price == 0) return Container();

    final double amountUsd = amount * price;
    if (amountUsd == null || amountUsd == 0) return Container();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        CexMarker(
          context,
          size: Size.fromHeight(12),
        ),
        const SizedBox(width: 2),
        Text(
          cexProvider.convert(amountUsd),
          style: TextStyle(
              fontSize: 12,
              color: settingsBloc.isLightTheme
                  ? cexColorLight.withAlpha(150)
                  : cexColor.withAlpha(150)),
        ),
      ],
    );
  }
}
