import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_form.dart';
import 'package:rational/rational.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';

class SellAmountField extends StatefulWidget {
  @override
  _SellAmountFieldState createState() => _SellAmountFieldState();
}

class _SellAmountFieldState extends State<SellAmountField> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();

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
    return Theme(
      data: Theme.of(context)
          .copyWith(inputDecorationTheme: gefaultUnderlineInputTheme),
      child: TextFormField(
        key: Key('input-text-sell'),
        scrollPadding: const EdgeInsets.only(left: 35),
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: appConfig.tradeFormPrecision),
          FilteringTextInputFormatter.allow(RegExp(
              '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?\$'))
        ],
        controller: _ctrl,
        onChanged: tradeForm.onSellAmountFieldChange,
        enabled: swapBloc.enabledSellField,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.subtitle2,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).amountToSell,
        ),
      ),
    );
  }

  void _onDataChange(Rational value) {
    if (!mounted) return;
    if (value == null) {
      _ctrl.clear();
      return;
    }

    final String newFormatted =
        cutTrailingZeros(value.toStringAsFixed(appConfig.tradeFormPrecision));
    final String currentFormatted = cutTrailingZeros(_ctrl.text);

    if (newFormatted != currentFormatted) {
      _ctrl.text = newFormatted;
      moveCursorToEnd(_ctrl);
    }
  }
}
