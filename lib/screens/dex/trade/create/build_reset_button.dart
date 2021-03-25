import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';

class BuildResetButton extends StatefulWidget {
  @override
  _BuildResetButtonState createState() => _BuildResetButtonState();
}

class _BuildResetButtonState extends State<BuildResetButton> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();

    // Using listeners to avoid multiple nested StreamBuilder's
    swapBloc.outAmountSell.listen(_onStateChange);
    swapBloc.outAmountReceive.listen(_onStateChange);
    swapBloc.outSellCoinBalance.listen(_onStateChange);
    swapBloc.outReceiveCoinBalance.listen(_onStateChange);
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: _enabled ? tradeForm.reset : null,
      child: Text(AppLocalizations.of(context).reset),
    );
  }

  void _onStateChange(dynamic _) {
    if (!mounted) return;

    final bool isEnabled = swapBloc.sellCoinBalance != null ||
        swapBloc.receiveCoinBalance != null ||
        swapBloc.amountSell != null ||
        swapBloc.amountReceive != null;

    setState(() => _enabled = isEnabled);
  }
}
