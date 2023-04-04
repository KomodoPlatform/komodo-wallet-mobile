import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../app_config/app_config.dart';
import '../../../../../localizations.dart';
import '../../../../../utils/decimal_text_input_formatter.dart';

class FiatAmountField extends StatefulWidget {
  const FiatAmountField({
    Key key,
    this.controller,
    this.onFiatChanged,
    this.enabled = true,
  }) : super(key: key);

  final TextEditingController controller;
  final VoidCallback onFiatChanged;
  final bool enabled;

  @override
  State<FiatAmountField> createState() => _FiatAmountFieldState();
}

class _FiatAmountFieldState extends State<FiatAmountField> {
  CexProvider cexProvider;

  _onFiatTypeChange(String fiat) {
    cexProvider.selectedFiat = fiat;
    widget.onFiatChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);

    Widget body = TextFormField(
      inputFormatters: <TextInputFormatter>[
        DecimalTextInputFormatter(
          decimalRange: appConfig.tradeFormPrecision,
        ),
        FilteringTextInputFormatter.allow(
          RegExp('^\$|^(0|([1-9][0-9]{0,12}))([.,]{1}[0-9]{0,8})?\$'),
        )
      ],
      controller: widget.enabled ? widget.controller : null,
      autovalidateMode: widget.controller.text.isNotEmpty
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
      textInputAction: TextInputAction.done,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: Theme.of(context).textTheme.bodyText2,
      textAlign: TextAlign.end,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).amount,
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: DropdownButton<String>(
            underline: SizedBox(),
            alignment: Alignment.centerRight,
            value: cexProvider.selectedFiat ?? cexProvider.fiatList.first,
            dropdownColor: Theme.of(context).primaryColor,
            items: cexProvider.fiatList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            }).toList(),
            onChanged: _onFiatTypeChange,
          ),
        ),
      ),
      validator: (String value) {
        if (!widget.enabled) return null;

        value = value.replaceAll(',', '.');
        if (value.isEmpty || double.parse(value) <= 0) {
          return AppLocalizations.of(context).errorValueNotEmpty;
        }

        return null;
      },
    );

    if (!widget.enabled) {
      body = Stack(
        children: [
          widget,
          Positioned.fill(
            child: ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(2),
              child: ColoredBox(
                color: Colors.grey.withOpacity(0.6),
              ),
            ),
          ),
        ],
      );
    }

    return body;
  }
}
