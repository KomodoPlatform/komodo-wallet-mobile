import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../localizations.dart';
import '../../../../../model/coin_balance.dart';
import '../../../../../widgets/primary_button.dart';
import '../../../../../widgets/secondary_button.dart';
import 'amount_field.dart';

typedef EnterCallback = void Function(double coinAmount);

class ReceivingAmountStep extends StatefulWidget {
  const ReceivingAmountStep({
    Key key,
    this.onEnterPressed,
    this.onCancel,
    this.onQrCodeTap,
    this.coinBalance,
  }) : super(key: key);

  final EnterCallback onEnterPressed;
  final VoidCallback onCancel;
  final VoidCallback onQrCodeTap;
  final CoinBalance coinBalance;

  @override
  _ReceivingAmountStepState createState() => _ReceivingAmountStepState();
}

class _ReceivingAmountStepState extends State<ReceivingAmountStep> {
  final _coinAmountController = TextEditingController();
  final _usdAmountController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isEnterPressed = false;
  CexProvider cex;

  double get usdPrice => cex.getUsdPrice(widget.coinBalance.coin.abbr);

  bool get canInputUsd => usdPrice != null && usdPrice > 0;

  @override
  void initState() {
    super.initState();
    _coinAmountController.addListener(_onCoinAmountUpdated);
    _usdAmountController.addListener(_onUsdAmountUpdated);
  }

  @override
  void dispose() {
    _coinAmountController.dispose();
    _usdAmountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cex = Provider.of<CexProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AmountField(
              trailingText: widget.coinBalance.coin.abbr,
              controller: _coinAmountController,
            ),
            const SizedBox(height: 16),
            AmountField(
              trailingText: '\$',
              // TODO(vanchel): выставлять enabled в false, "if that coin has a price within the wallet"
              enabled: canInputUsd,
              controller: _usdAmountController,
            ),
            const SizedBox(height: 16),
            InkWell(
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

  void _onCoinAmountUpdated() {
    onChanged(_coinAmountController.text);
    final coinAmount = double.tryParse(
      _coinAmountController.text.replaceAll(',', '.'),
    );
    if (coinAmount == null || !canInputUsd) return;

    final usd = usdPrice * coinAmount;
    _usdAmountController
      ..removeListener(_onUsdAmountUpdated)
      ..text = usd.toStringAsFixed(2)
      ..addListener(_onUsdAmountUpdated);
  }

  void _onUsdAmountUpdated() {
    onChanged(_usdAmountController.text);
    final usdAmount = double.tryParse(
      _usdAmountController.text.replaceAll(',', '.'),
    );
    if (usdAmount == null) return;

    final coin = usdAmount / usdPrice;
    _coinAmountController
      ..removeListener(_onCoinAmountUpdated)
      ..text = coin.toStringAsFixed(8)
      ..addListener(_onCoinAmountUpdated);
  }

  onChanged(String value) {
    setState(() {
      if (isEnterPressed && value.isEmpty) {
        formKey.currentState.validate();
      }
    });
  }
}
