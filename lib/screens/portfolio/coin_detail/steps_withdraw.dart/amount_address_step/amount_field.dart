import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class AmountField extends StatefulWidget {
  const AmountField(
      {Key key,
      this.onMaxValue,
      this.focusNode,
      this.controller,
      this.autoFocus = false,
      this.coinAbbr})
      : super(key: key);

  final Function onMaxValue;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool autoFocus;
  final String coinAbbr;

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  double amountUsd = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_calculateFiat);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_calculateFiat);
    super.dispose();
  }

  void _calculateFiat() {
    final amount = widget.controller.text;

    final cexProvider = Provider.of<CexProvider>(context, listen: false);
    final double price = cexProvider.getUsdPrice(widget.coinAbbr);

    final amountParsed = double.tryParse(amount) ?? 0.0;

    final r = amountParsed * price;

    setState(() {
      amountUsd = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cexProvider = Provider.of<CexProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Container(
                height: 60,
                child: ButtonTheme(
                  minWidth: 50,
                  child: FlatButton(
                    padding: const EdgeInsets.only(
                      left: 6,
                      right: 6,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0)),
                    child: Text(
                      AppLocalizations.of(context).max,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    onPressed: widget.onMaxValue,
                  ),
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
                              decimalRange: tradeForm.precision),
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
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor)),
                            hintStyle: Theme.of(context).textTheme.bodyText2,
                            labelStyle: Theme.of(context).textTheme.bodyText2,
                            labelText: AppLocalizations.of(context).amount),
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              CexMarker(context, size: Size.fromHeight(12)),
              SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  cexProvider.convert(amountUsd),
                  style: TextStyle(
                      fontSize: 14,
                      color: settingsBloc.isLightTheme
                          ? cexColorLight.withAlpha(150)
                          : cexColor.withAlpha(150)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
