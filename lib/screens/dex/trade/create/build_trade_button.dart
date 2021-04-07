import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/swap_confirmation_page.dart';
import 'package:komodo_dex/screens/dex/trade/create/trade_form_validator.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class BuildTradeButton extends StatefulWidget {
  @override
  _BuildTradeButtonState createState() => _BuildTradeButtonState();
}

class _BuildTradeButtonState extends State<BuildTradeButton> {
  List<StreamSubscription> _listeners;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();

    // Using listeners to avoid multiple nested StreamBuilder's
    _listeners = [
      swapBloc.outAmountSell.listen(_onStateChange),
      swapBloc.outAmountReceive.listen(_onStateChange),
      swapBloc.outSellCoinBalance.listen(_onStateChange),
      swapBloc.outReceiveCoinBalance.listen(_onStateChange),
      swapBloc.outTradePreimage.listen(_onStateChange),
      swapBloc.outProcessing.listen(_onStateChange),
    ];
  }

  @override
  void dispose() {
    _listeners.map((listener) {
      listener?.cancel();
    });

    super.dispose();
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
    Log('build_trade_button', 'validating trading form...');

    final validator = TradeFormValidator();
    final errorMessage = await validator.errorMessage;

    if (errorMessage == null) {
      Log('build_trade_button', 'form is valid');

      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SwapConfirmationPage()));
    } else {
      Log('build_trade_button', 'form is invalid: $errorMessage');

      Scaffold.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(errorMessage),
      ));
    }
  }

  void _onStateChange(dynamic _) {
    if (!mounted) return;

    final bool isEnabled = swapBloc.processing == false &&
        swapBloc.tradePreimage != null &&
        swapBloc.sellCoinBalance != null &&
        swapBloc.receiveCoinBalance != null &&
        swapBloc.amountSell != null &&
        swapBloc.amountReceive != null;

    setState(() => _enabled = isEnabled);
  }
}
