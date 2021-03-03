import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';

class SellAmountField extends StatefulWidget {
  @override
  _SellAmountFieldState createState() => _SellAmountFieldState();
}

class _SellAmountFieldState extends State<SellAmountField> {
  final _ctrl = TextEditingController();
  String _prevValue;

  @override
  void initState() {
    super.initState();

    _ctrl.addListener(_onFieldChange);
    swapBloc.outAmountSell.listen(_onDataChange);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('input-text-sell'),
      scrollPadding: const EdgeInsets.only(left: 35),
      inputFormatters: <TextInputFormatter>[
        DecimalTextInputFormatter(decimalRange: 8),
        FilteringTextInputFormatter.allow(
            RegExp('^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,8})?\$'))
      ],
      controller: _ctrl,
      enabled: swapBloc.enabledSellField,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.subtitle2,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
          hintText: AppLocalizations.of(context).amountToSell),
      onChanged: (_) => swapBloc.setIsMaxActive(false),
    );
  }

  void _onDataChange(double value) {
    if (!mounted) return;

    _ctrl.text = value.toString();
  }

  void _onFieldChange() {
    String value = _ctrl.text;
    if (_prevValue == value) return;

    // TODO(yurii): mutating value (all logic and check goes here)
    // - check if not greater than max balance
    // - check if not greater than matching bid max receive volume
    value = value;

    if (value == _prevValue) return;

    setState(() => _prevValue = value);
    _ctrl.text = value;
  }
}
