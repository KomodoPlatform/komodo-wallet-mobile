import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/amount_address_step/address_field.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/steps_withdraw.dart/receiving_amount_step/fiat_amount_field.dart';
import 'package:provider/provider.dart';

import '../../../../../localizations.dart';
import '../../../../../model/coin_balance.dart';
import '../../../../../widgets/primary_button.dart';
import '../../../../../widgets/secondary_button.dart';
import 'amount_field.dart';

typedef EnterCallback = void Function(double coinAmount, String address);

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
  final _fiatAmountController = TextEditingController();
  final _addressController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isEnterPressed = false;
  CexProvider cex;

  double get usdPrice => cex.getUsdPrice(widget.coinBalance.coin.abbr);

  bool get canInputFiat => usdPrice != null && usdPrice > 0;

  @override
  void initState() {
    super.initState();
    _coinAmountController.addListener(_onCoinAmountUpdated);
    _fiatAmountController.addListener(_onFiatAmountUpdated);
  }

  @override
  void dispose() {
    _coinAmountController.dispose();
    _fiatAmountController.dispose();
    _addressController.dispose();

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
            FiatAmountField(
              controller: _fiatAmountController,
              enabled: canInputFiat,
              onFiatChanged: _onCoinAmountUpdated,
            ),
            const SizedBox(height: 16),
            AddressField(
              addressFormat: widget.coinBalance.coin.addressFormat,
              controller: _addressController,
              coin: widget.coinBalance.coin,
              onChanged: null,
              onScan: null,
              showScanner: false,
              isOptional: true,
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
                      _fiatAmountController.clear();
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
                          _addressController.text,
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
    if (coinAmount == null || !canInputFiat) return;

    final fiatUsdPrice = cex.getUsdPrice(cex.selectedFiat);
    final fiat = usdPrice * coinAmount / fiatUsdPrice;
    _fiatAmountController
      ..removeListener(_onFiatAmountUpdated)
      ..text = fiat.toStringAsFixed(2)
      ..addListener(_onFiatAmountUpdated);
  }

  void _onFiatAmountUpdated() {
    onChanged(_fiatAmountController.text);
    final fiatAmount = double.tryParse(
      _fiatAmountController.text.replaceAll(',', '.'),
    );
    if (fiatAmount == null) return;

    final fiatUsdPrice = cex.getUsdPrice(cex.selectedFiat);
    final coin = fiatAmount / usdPrice * fiatUsdPrice;
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
