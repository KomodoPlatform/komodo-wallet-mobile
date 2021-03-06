import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/swap_confirmation_page.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class BuildTradeButton extends StatefulWidget {
  @override
  _BuildTradeButtonState createState() => _BuildTradeButtonState();
}

class _BuildTradeButtonState extends State<BuildTradeButton> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: PrimaryButton(
        key: const Key('trade-button'),
        onPressed: _enabled ? () => _validateAndConfirm(context) : null,
        text: AppLocalizations.of(context).trade,
      ),
    );
  }

  Future<void> _validateAndConfirm(BuildContext mContext) async {
    final validator = TradeFormValidator();
    final errorMessage = await validator.errorMessage;

    if (errorMessage == null) {
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SwapConfirmationPage()));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(errorMessage),
      ));
    }
  }

  void _onStateChange(dynamic _) {
    if (!mounted) return;

    final bool isEnabled = swapBloc.sellCoinBalance != null &&
        swapBloc.receiveCoinBalance != null &&
        swapBloc.amountSell != null &&
        swapBloc.amountReceive != null;

    setState(() => _enabled = isEnabled);
  }
}
