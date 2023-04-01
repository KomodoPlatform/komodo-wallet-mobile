import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../localizations.dart';
import '../../../../../model/coin_balance.dart';
import '../../../../../widgets/primary_button.dart';
import '../../../../../widgets/secondary_button.dart';
import 'amount_field.dart';

typedef EnterCallback = void Function(double coinAmount);

class ReceivingAmountStep extends StatefulWidget {
  const ReceivingAmountStep({
    Key key,
    this.focusNode,
    this.autoFocus = false,
    this.onEnterPressed,
    this.onCancel,
    this.onQrCodeTap,
    this.coinBalance,
    this.scrollController,
  }) : super(key: key);

  final FocusNode focusNode;
  final bool autoFocus;
  final EnterCallback onEnterPressed;
  final VoidCallback onCancel;
  final VoidCallback onQrCodeTap;
  final CoinBalance coinBalance;
  final ScrollController scrollController;

  @override
  _ReceivingAmountStepState createState() => _ReceivingAmountStepState();
}

class _ReceivingAmountStepState extends State<ReceivingAmountStep> {
  final _coinAmountController = TextEditingController();
  final _usdAmountController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool autovalidate = false;
  bool isEnterPressed = false;

  @override
  void dispose() {
    _coinAmountController.dispose();
    _usdAmountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        autovalidateMode:
            autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AmountField(
              trailingText: widget.coinBalance.coin.abbr,
              controller: _coinAmountController,
            ),
            const SizedBox(height: 16),
            // TODO(vanchel): выставлять enabled в false, "if that coin has a price within the wallet"
            AmountField(
              trailingText: widget.coinBalance.coin.abbr,
              controller: _usdAmountController,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onQrCodeTap,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/svg/qr_code.svg',
                  height: 44,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: SecondaryButton(
                    text: AppLocalizations.of(context).cancel,
                    onPressed: () {
                      _coinAmountController.clear();
                      _usdAmountController.clear();
                      formKey.currentState.validate();
                      widget.onCancel();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: AppLocalizations.of(context).enter.toUpperCase(),
                    onPressed: () async {
                      setState(() {
                        isEnterPressed = true;
                        _coinAmountController.text =
                            _coinAmountController.text.replaceAll(',', '.');
                      });
                      if (formKey.currentState.validate() &&
                          _coinAmountController.text.isNotEmpty) {
                        widget.onEnterPressed(
                          double.tryParse(_coinAmountController.text) ?? 0.0,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TODO(vanchel): реализовать использование этого метода
  onChanged(String a) {
    setState(() {
      if (isEnterPressed && a.isEmpty) {
        autovalidate = false;
        formKey.currentState.validate();
      } else if (isEnterPressed) {
        autovalidate = true;
      }
    });
  }
}
