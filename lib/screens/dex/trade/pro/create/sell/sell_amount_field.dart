import 'package:rational/rational.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/pro/create/trade_form.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';

class SellAmountField extends StatefulWidget {
  @override
  _SellAmountFieldState createState() => _SellAmountFieldState();
}

class _SellAmountFieldState extends State<SellAmountField> {
  // MRC: Seems this workaround controller causes problems, so disabling it for now

  final _ctrl = TextEditingController(); //TextEditingControllerWorkaroud();

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
        DecimalTextInputFormatter(decimalRange: appConfig.tradeFormPrecision),
        FilteringTextInputFormatter.allow(RegExp(
            '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?\$'))
      ],
      controller: _ctrl,
      enabled: swapBloc.enabledSellField,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.subtitle2,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.w200),
          hintText: AppLocalizations.of(context).amountToSell),
    );
  }

  void _onFieldChange() {
    tradeForm.onSellAmountFieldChange(_ctrl.text);
  }

  void _onDataChange(Rational value) {
    if (!mounted) return;
    if (value == null) {
      _ctrl.text = '';
      return;
    }

    final String newFormatted =
        cutTrailingZeros(value.toStringAsFixed(appConfig.tradeFormPrecision));
    final String currentFormatted = cutTrailingZeros(_ctrl.text);

    // MRC: Using TextEditingControllerWorkaround breaks stuff,
    // so disabling this
    /*
    if (newFormatted != currentFormatted) {
      _ctrl.setTextAndPosition(newFormatted);
    }
    */
  }
}
