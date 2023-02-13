import 'package:flutter/material.dart';
import '../model/cex_provider.dart';
import '../widgets/cex_data_marker.dart';
import '../app_config/theme_data.dart';
import 'package:provider/provider.dart';

class CexFiatPreview extends StatelessWidget {
  const CexFiatPreview({
    Key? key,
    this.amount,
    this.coinAbbr,
    this.colorCex,
    this.textStyle,
    this.currencyType,
  }) : super(key: key);

  final String? amount;
  final String? coinAbbr;
  final Color? colorCex;
  final TextStyle? textStyle;
  final String? currencyType;

  @override
  Widget build(BuildContext context) {
    final cexProvider = Provider.of<CexProvider>(context);
    final amountParsed = double.tryParse(amount!) ?? 0.0;
    String? convertedValue;

    if (currencyType != coinAbbr) {
      convertedValue =
          cexProvider.convert(amountParsed, from: currencyType, to: coinAbbr);
    } else {
      convertedValue = cexProvider.convert(amountParsed,
          from: coinAbbr, to: cexProvider.selectedFiat);
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
          convertedValue!,
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
