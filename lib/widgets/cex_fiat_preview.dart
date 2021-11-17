import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:provider/provider.dart';

class CexFiatPreview extends StatelessWidget {
  const CexFiatPreview({
    Key key,
    this.amount,
    this.coinAbbr,
    this.colorCex,
    this.textStyle,
  }) : super(key: key);

  final String amount;
  final String coinAbbr;
  final Color colorCex;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final cexProvider = Provider.of<CexProvider>(context);

    final double price = cexProvider.getUsdPrice(coinAbbr);
    final amountParsed = double.tryParse(amount) ?? 0.0;
    final amountUsd = amountParsed * price;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CexMarker(
          context,
          size: Size.fromHeight(12),
          color: colorCex,
        ),
        SizedBox(width: 2),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            cexProvider.convert(amountUsd),
            style: textStyle ??
                TextStyle(
                  fontSize: 14,
                  color: settingsBloc.isLightTheme
                      ? cexColorLight.withAlpha(150)
                      : cexColor.withAlpha(150),
                ),
          ),
        ),
      ],
    );
  }
}
