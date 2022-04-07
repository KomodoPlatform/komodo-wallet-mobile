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
     const AmountField(
      {Key key,
      this.onMaxValue,
      this.focusNode,
      this.controller,
      this.autoFocus = false,
      this.coinAbbr, this.isInCrypto,})
      : super(key: key);

  final Function onMaxValue;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool autoFocus;
  final String coinAbbr;
  final Function isInCrypto;

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  String amountPreview = '';
  CexProvider cexProvider;

  bool isInCrypto = true;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_amountPreviewListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_amountPreviewListener);
    super.dispose();
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
                    onPressed: (){
                      widget.onMaxValue();
                      if(isInCrypto){

                      }
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
                            if (coinBalance.coin.abbr == widget.coinAbbr) {
                              currentCoinBalance = coinBalance;
                            }
                          }
                        }
                        return TextFormField(
                          key: const Key('send-amount-field'),
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
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).amount,
                            suffixText:  isInCrypto ? widget.coinAbbr: cexProvider.selectedFiatSymbol.toUpperCase()
                          ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: [
                  Checkbox(
                    key: const Key('specify-in-fiat'),
                    value:  isInCrypto,
                    onChanged: (a){
                      widget.isInCrypto;
                        setState(() {
                          isInCrypto =  ! isInCrypto;
                        });
                    },
                  ),
                  Text(
                    AppLocalizations.of(context).specifyInFiat( isInCrypto ? 'Crypto':'Fiat'),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),

                ],),
                CexFiatPreview(
                  amount: amountPreview,
                  coinAbbr: widget.coinAbbr,
                  isInCrypto: isInCrypto,
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}
