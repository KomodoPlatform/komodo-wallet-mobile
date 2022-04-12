import 'package:flutter/material.dart';
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
    this.currencyType,
  }) : super(key: key);

  final String amount;
  final String coinAbbr;
  final Color colorCex;
  final TextStyle textStyle;
  final String currencyType;

  @override
  Widget build(BuildContext context) {
    final cexProvider = Provider.of<CexProvider>(context);
    double amountUsd = 0;
    final double price = cexProvider.getUsdPrice(coinAbbr);
    final amountParsed = double.tryParse(amount) ?? 0.0;
    if (currencyType == 'USD') {
      amountUsd = amountParsed / price;
    } else if (currencyType == cexProvider.selectedFiatSymbol.toUpperCase()) {
    } else {
      amountUsd = amountParsed * price;
    }

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
        Text(
          cexProvider.convert(amountUsd, hideSymbol: currencyType != coinAbbr) +
              (currencyType == coinAbbr ? '' : ' ' + coinAbbr),
          style: textStyle ??
              TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.light
                    ? cexColorLight.withAlpha(150)
                    : cexColor.withAlpha(150),
              ),
        ),
      ],
    );
  }
}
