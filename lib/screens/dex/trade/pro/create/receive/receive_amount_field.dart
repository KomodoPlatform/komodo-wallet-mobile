import 'package:flutter/material.dart';
import '../../../../../../app_config/theme_data.dart';
import 'package:rational/rational.dart';
import 'package:flutter/services.dart';
import '../../../../../../generic_blocs/swap_bloc.dart';
import '../../../../../../app_config/app_config.dart';
import '../../../../../dex/trade/pro/create/trade_form.dart';
import '../../../../../../utils/decimal_text_input_formatter.dart';
import '../../../../../../utils/utils.dart';

class ReceiveAmountField extends StatefulWidget {
  @override
  _ReceiveAmountFieldState createState() => _ReceiveAmountFieldState();
}

class _ReceiveAmountFieldState extends State<ReceiveAmountField> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    swapBloc.outAmountReceive.listen(_onDataChange);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _onDataChange(swapBloc.amountReceive));
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
        key: Key('input-text-buy'),
        scrollPadding: const EdgeInsets.only(left: 35),
        onChanged: tradeForm.onReceiveAmountFieldChange,
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: appConfig.tradeFormPrecision),
          FilteringTextInputFormatter.allow(RegExp(
              '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?\$'))
        ],
        controller: _ctrl,
        enabled: swapBloc.enabledReceiveField,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.subtitle2,
        textInputAction: TextInputAction.done,
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
