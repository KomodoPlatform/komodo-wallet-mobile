import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app_config/app_config.dart';
import '../../../../../localizations.dart';
import '../../../../../utils/decimal_text_input_formatter.dart';

class AmountField extends StatelessWidget {
  const AmountField({
    Key key,
    this.trailingText,
    this.controller,
  }) : super(key: key);

  final String trailingText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: <TextInputFormatter>[
        DecimalTextInputFormatter(
          decimalRange: appConfig.tradeFormPrecision,
        ),
        FilteringTextInputFormatter.allow(
          RegExp('^\$|^(0|([1-9][0-9]{0,12}))([.,]{1}[0-9]{0,8})?\$'),
        )
      ],
      controller: controller,
      autovalidateMode: controller.text.isNotEmpty
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      textInputAction: TextInputAction.done,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: Theme.of(context).textTheme.bodyText2,
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).amount,
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                trailingText.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
      validator: (String value) {
        value = value.replaceAll(',', '.');
        if (value.isEmpty || double.parse(value) <= 0) {
          return AppLocalizations.of(context).errorValueNotEmpty;
        }

        return null;
      },
    );
  }
}
