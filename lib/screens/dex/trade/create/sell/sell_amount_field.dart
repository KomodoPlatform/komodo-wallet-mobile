import 'package:rational/rational.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';

class SellAmountField extends StatefulWidget {
  @override
  _SellAmountFieldState createState() => _SellAmountFieldState();
}

class _SellAmountFieldState extends State<SellAmountField> {
  final _ctrl = TextEditingControllerWorkaroud();

  @override
  void initState() {
    super.initState();

    _ctrl.addListener(_onFieldChange);
    swapBloc.outAmountSell.listen(_onDataChange);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _onDataChange(swapBloc.amountSell));
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key('input-text-sell'),
      scrollPadding: const EdgeInsets.only(left: 35),
      inputFormatters: <TextInputFormatter>[
        DecimalTextInputFormatter(decimalRange: tradeForm.precision),
        FilteringTextInputFormatter.allow(RegExp(
            '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${tradeForm.precision}})?\$'))
      ],
      controller: _ctrl,
      enabled: swapBloc.enabledSellField,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.subtitle2,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).accentColor),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.w200),
          hintText: AppLocalizations.of(context).amountToSell),
    );
  }

  void _onFieldChange() {
    final String text = _ctrl.text;
    tradeForm.onSellAmountFieldChange(text);
  }

  void _onDataChange(Rational value) {
    if (!mounted) return;
    if (value == tryParseRat(_ctrl.text)) return;

    _ctrl.setTextAndPosition(value == null
        ? ''
        : cutTrailingZeros(value.toStringAsFixed(tradeForm.precision)) ?? '');
  }
}
