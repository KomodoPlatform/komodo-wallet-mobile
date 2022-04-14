import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/widgets/cex_fiat_preview.dart';
import 'package:provider/provider.dart';

class AmountField extends StatefulWidget {
  const AmountField({
    Key key,
    this.onMaxValue,
    this.focusNode,
    this.controller,
    this.autoFocus = false,
    this.coinBalance,
    this.cryptoListener,
  }) : super(key: key);

  final bool autoFocus;
  final CoinBalance coinBalance;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onMaxValue;
  final TextEditingController cryptoListener;

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  String amountPreview = '';
  CexProvider cexProvider;
  String currencyType;
  bool isLastPressedMax = false;

  @override
  void dispose() {
    widget.controller.removeListener(_amountPreviewListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    currencyType = widget.coinBalance.coin.abbr.toUpperCase();
    widget.controller.addListener(_amountPreviewListener);
  }

  void onChange({bool isDropdownChange = false}) {
    if (!isDropdownChange) isLastPressedMax = false;
    final String text = widget.controller.text.replaceAll(',', '.');
    if (text.isNotEmpty) {
      setState(() {
        if (currencyType == 'USD') {
          final String coinBalanceUsd = cexProvider
              .convert(widget.coinBalance.balanceUSD, hideSymbol: true);

          if ((isLastPressedMax) ||
              (widget.coinBalance != null &&
                  double.parse(text) > double.parse(coinBalanceUsd))) {
            setMaxValue();
          }
        } else if (currencyType ==
            cexProvider.selectedFiatSymbol.toUpperCase()) {
          final String coinBalanceUsd = cexProvider
              .convert(widget.coinBalance.balanceUSD, hideSymbol: true);

          final String convertedBalance = cexProvider
              .convert(double.parse(coinBalanceUsd), hideSymbol: true);

          if ((isLastPressedMax) ||
              (widget.coinBalance != null &&
                  double.parse(text) > double.parse(convertedBalance))) {
            setMaxValue();
          }
        } else {
          if ((isLastPressedMax) ||
              (widget.coinBalance != null &&
                  double.parse(text) >
                      double.parse(cexProvider.convert(
                          widget.coinBalance.balanceUSD,
                          hideSymbol: true)))) {
            setMaxValue();
          }
        }
      });
    }
  }

  Future<void> setMaxValue() async {
    widget.focusNode.unfocus();
    setState(() {
      if (currencyType == 'USD') {
        final String coinBalanceUsd = cexProvider
            .convert(widget.coinBalance.balanceUSD, hideSymbol: true);

        widget.controller.text = coinBalanceUsd;
      } else if (currencyType == cexProvider.selectedFiat.toUpperCase()) {
        final String coinBalanceUsd = cexProvider
            .convert(widget.coinBalance.balanceUSD, hideSymbol: true);
        widget.controller.text =
            cexProvider.convert(double.parse(coinBalanceUsd), hideSymbol: true);
      } else {
        widget.controller.text = widget.coinBalance.balance.getBalance();
      }
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        FocusScope.of(context).requestFocus(widget.focusNode);
      });
    });
    coinsDetailBloc.setAmountToSend(widget.controller.text);
  }

  void _amountPreviewListener() {
    setState(() {
      amountPreview = widget.controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    cexProvider = Provider.of<CexProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: <Widget>[
                SizedBox(
                  height: 60,
                  child: TextButton(
                    onPressed: () {
                      isLastPressedMax = true;
                      setMaxValue();
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      primary: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.only(left: 6, right: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context).max),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: StreamBuilder<List<CoinBalance>>(
                      initialData: coinsBloc.coinBalance,
                      stream: coinsBloc.outCoins,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<CoinBalance>> snapshot) {
                        CoinBalance currentCoinBalance;
                        if (snapshot.hasData) {
                          for (CoinBalance coinBalance in snapshot.data) {
                            if (coinBalance.coin.abbr ==
                                widget.coinBalance.coin.abbr) {
                              currentCoinBalance = coinBalance;
                            }
                          }
                        }
                        return TextFormField(
                          //  key: const Key('send-amount-field'),
                          inputFormatters: <TextInputFormatter>[
                            DecimalTextInputFormatter(
                                decimalRange: appConfig.tradeFormPrecision),
                            FilteringTextInputFormatter.allow(RegExp(
                                '^\$|^(0|([1-9][0-9]{0,12}))([.,]{1}[0-9]{0,8})?\$'))
                          ],
                          focusNode: widget.focusNode,
                          controller: widget.controller,
                          autofocus: widget.autoFocus,
                          textInputAction: TextInputAction.done,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.end,
                          onChanged: (String amount) {
                            coinsDetailBloc.setAmountToSend(amount);
                            onChange(isDropdownChange: true);
                          },
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).amount,
                              suffixIcon: Padding(
                                padding: EdgeInsets.only(right: 6.0),
                                child: DropdownButton<String>(
                                  underline: SizedBox(),
                                  alignment: Alignment.centerRight,
                                  value: currencyType,
                                  items: [
                                    'USD',
                                    widget.coinBalance.coin.abbr.toUpperCase(),
                                    if (cexProvider.selectedFiat != 'USD')
                                      cexProvider.selectedFiat,
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (a) {
                                    setState(() {
                                      currencyType = a;
                                      widget.cryptoListener.text = currencyType;
                                    });
                                    onChange();
                                  },
                                ),
                              )),
                          // The validator receives the text the user has typed in
                          validator: (String value) {
                            if (value.isEmpty && coinsDetailBloc.isCancel) {
                              return null;
                            }
                            value = value.replaceAll(',', '.');

                            if (value.isEmpty || double.parse(value) <= 0) {
                              return AppLocalizations.of(context)
                                  .errorValueNotEmpty;
                            }

                            final double currentAmount = double.parse(value);

                            if (currentAmount >
                                double.parse(
                                    currentCoinBalance.balance.getBalance())) {
                              return AppLocalizations.of(context)
                                  .errorAmountBalance;
                            }
                            return null;
                          },
                        );
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CexFiatPreview(
                  amount: amountPreview,
                  coinAbbr: widget.coinBalance.coin.abbr,
                  currencyType: currencyType,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
