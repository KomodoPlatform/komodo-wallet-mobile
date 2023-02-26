import 'package:flutter/material.dart';
import '../../../../../blocs/swap_bloc.dart';
import '../../../../../model/cex_provider.dart';
import '../../../../../model/coin.dart';
import '../../../../../model/market.dart';
import '../../../../../widgets/cex_data_marker.dart';
import '../../../../../app_config/theme_data.dart';
import 'package:provider/provider.dart';

class BuildFiatAmount extends StatelessWidget {
  const BuildFiatAmount(this.market);

  final Market market;

  @override
  Widget build(BuildContext context) {
    final cexProvider = Provider.of<CexProvider>(context);

    final double amount = market == Market.SELL
        ? swapBloc.amountSell?.toDouble()
        : swapBloc.amountReceive?.toDouble();
    final Coin coin = market == Market.SELL
        ? swapBloc.sellCoinBalance?.coin
        : swapBloc.receiveCoinBalance?.coin;

    if (amount == null || coin == null || amount == 0) return _spacer();

    final double price = cexProvider.getUsdPrice(coin.abbr);
    if (price == null || price == 0) return _spacer();

    final double amountUsd = amount * price;
    if (amountUsd == null || amountUsd == 0) return _spacer();

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
              color: Theme.of(context).brightness == Brightness.light
                  ? cexColorLight.withAlpha(150)
                  : cexColor.withAlpha(150)),
        ),
      ],
    );
  }

  Widget _spacer() {
    return Text(String.fromCharCode(0x00A0), style: TextStyle(fontSize: 12));
  }
}
