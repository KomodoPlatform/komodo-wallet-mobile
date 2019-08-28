import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/get_withdraw.dart';

class CustomFee extends StatefulWidget {
  const CustomFee({Key key, this.amount, this.isERCToken = false})
      : super(key: key);

  final String amount;
  final bool isERCToken;

  @override
  _CustomFeeState createState() => _CustomFeeState();
}

class _CustomFeeState extends State<CustomFee> {
  bool isCustomFeeActive = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Custom fee',
                style: Theme.of(context).textTheme.body2,
              ),
              Switch(
                value: isCustomFeeActive,
                onChanged: (bool value) {
                  setState(() {
                    isCustomFeeActive = !isCustomFeeActive;
                  });
                },
              ),
            ],
          ),
          AnimatedCrossFade(
            crossFadeState: isCustomFeeActive
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            firstChild: Container(),
            secondChild: Column(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).customFeeWarning,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme.of(context).errorColor),
                ),
                widget.isERCToken
                    ? CustomFeeFieldERC(
                        isCustomFeeActive: isCustomFeeActive,
                      )
                    : CustomFeeFieldSmartChain(
                        isCustomFeeActive: isCustomFeeActive),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CustomFeeFieldERC extends StatefulWidget {
  const CustomFeeFieldERC({Key key, this.isCustomFeeActive}) : super(key: key);

  final bool isCustomFeeActive;

  @override
  _CustomFeeFieldERCState createState() => _CustomFeeFieldERCState();
}

class _CustomFeeFieldERCState extends State<CustomFeeFieldERC> {
  final TextEditingController _gasPriceController = TextEditingController();
  final TextEditingController _gasController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _gasController,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter(RegExp('[0-9]'))
            ],
            textInputAction: TextInputAction.done,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColorLight)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                hintStyle: Theme.of(context).textTheme.body1,
                labelStyle: Theme.of(context).textTheme.body1,
                labelText: AppLocalizations.of(context).gas),
            validator: (String value) {
              if (widget.isCustomFeeActive) {
                value = value.replaceAll(',', '.');

                if (value.isEmpty || double.parse(value) <= 0) {
                  return AppLocalizations.of(context).errorValueNotEmpty;
                }

                coinsDetailBloc.setCustomFee(Fee(
                    gas: int.parse(_gasController.text.replaceAll(',', '.')),
                    gasPrice: _gasPriceController.text.replaceAll(',', '.')));
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _gasPriceController,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter(
                  RegExp('^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$'))
            ],
            textInputAction: TextInputAction.done,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.body1,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColorLight)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
                hintStyle: Theme.of(context).textTheme.body1,
                labelStyle: Theme.of(context).textTheme.body1,
                labelText: AppLocalizations.of(context).gasPrice),
            validator: (String value) {
              if (widget.isCustomFeeActive) {
                value = value.replaceAll(',', '.');

                if (value.isEmpty || double.parse(value) <= 0) {
                  return AppLocalizations.of(context).errorValueNotEmpty;
                }

                coinsDetailBloc.setCustomFee(Fee(
                    gas: int.parse(_gasController.text.replaceAll(',', '.')),
                    gasPrice: _gasPriceController.text.replaceAll(',', '.')));
              }
              return null;
            },
          ),
        )
      ],
    );
  }
}

class CustomFeeFieldSmartChain extends StatefulWidget {
  const CustomFeeFieldSmartChain({Key key, this.isCustomFeeActive})
      : super(key: key);

  final bool isCustomFeeActive;

  @override
  _CustomFeeFieldSmartChainState createState() =>
      _CustomFeeFieldSmartChainState();
}

class _CustomFeeFieldSmartChainState extends State<CustomFeeFieldSmartChain> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter(
              RegExp('^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$'))
        ],
        textInputAction: TextInputAction.done,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.body1,
        textAlign: TextAlign.end,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            hintStyle: Theme.of(context).textTheme.body1,
            labelStyle: Theme.of(context).textTheme.body1,
            labelText: AppLocalizations.of(context).customFee),
        // The validator receives the text the user has typed in
        validator: (String value) {
          if (widget.isCustomFeeActive) {
            value = value.replaceAll(',', '.');

            if (value.isEmpty || double.parse(value) <= 0) {
              return AppLocalizations.of(context).errorValueNotEmpty;
            }

            final double currentAmount = double.parse(value);

            if (currentAmount > double.parse(coinsDetailBloc.amountToSend)) {
              return AppLocalizations.of(context).errorAmountBalance;
            }
            coinsDetailBloc.setCustomFee(Fee(amount: value));
          }
          return null;
        },
      ),
    );
  }
}
