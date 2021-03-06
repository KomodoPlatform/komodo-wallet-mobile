import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';

import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';

class SellAmountField extends StatefulWidget {
  @override
  _SellAmountFieldState createState() => _SellAmountFieldState();
}

class _SellAmountFieldState extends State<SellAmountField> {
  final _ctrl = TextEditingControllerWorkaroud();
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

    final String newValue = cutTrailingZeros(formatPrice(value));
    if (newValue == _prevValue) return;
    setState(() => _prevValue = newValue);

    _ctrl.setTextAndPosition(newValue ?? '');
  }

  Future<void> _onFieldChange() async {
    double valueNum = double.tryParse(_ctrl.text ?? '');
    // If empty or non-numerical
    if (valueNum == null) {
      swapBloc.setAmountSell(null);
      swapBloc.setAmountReceive(null);
      swapBloc.setIsMaxActive(false);

      return;
    }

    // If greater than max available balance
    final Decimal maxAmount = await swapBloc.getMaxSellAmount();
    if (valueNum > maxAmount.toDouble()) {
      valueNum = maxAmount.toDouble();
      swapBloc.setIsMaxActive(true);
    }

    final Ask matchingBid = swapBloc.matchingBid;
    if (matchingBid != null) {
      final double bidPrice = double.parse(matchingBid.price);
      final double bidVolume = matchingBid.maxvolume.toDouble();

      // If greater than matching bid max receive volume
      if (valueNum > bidVolume * bidPrice) {
        valueNum = bidVolume * bidPrice;
        swapBloc.setIsMaxActive(false);
      }

      swapBloc.setAmountReceive(valueNum / double.parse(matchingBid.price));
    }

    if (valueNum != swapBloc.amountSell) {
      swapBloc.setAmountSell(valueNum); // fires `_onDataChange()`
    }
  }
}
