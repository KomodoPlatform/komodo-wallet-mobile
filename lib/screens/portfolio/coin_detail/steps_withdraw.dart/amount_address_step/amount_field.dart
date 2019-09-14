import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coin_detail_bloc.dart';
import 'package:komodo_dex/localizations.dart';

class AmountField extends StatefulWidget {
  const AmountField(
      {Key key,
      this.onMaxValue,
      this.focusNode,
      this.controller,
      this.autoFocus = false,
      this.balance})
      : super(key: key);

  final Function onMaxValue;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool autoFocus;
  final double balance;

  @override
  _AmountFieldState createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: <Widget>[
          Container(
            height: 60,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
              child: Text(
                AppLocalizations.of(context).max,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Theme.of(context).accentColor),
              ),
              onPressed: widget.onMaxValue,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: TextFormField(
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter(
                    RegExp('^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$'))
              ],
              focusNode: widget.focusNode,
              controller: widget.controller,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.done,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.body1,
              textAlign: TextAlign.end,
              onChanged: (String amount) {
                coinsDetailBloc.setAmountToSend(amount);
              },
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).primaryColorLight)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor)),
                  hintStyle: Theme.of(context).textTheme.body1,
                  labelStyle: Theme.of(context).textTheme.body1,
                  labelText: AppLocalizations.of(context).amount),
              // The validator receives the text the user has typed in
              validator: (String value) {
                value = value.replaceAll(',', '.');

                if (value.isEmpty || double.parse(value) <= 0) {
                  return AppLocalizations.of(context).errorValueNotEmpty;
                }

                final double currentAmount = double.parse(value);

                if (currentAmount > widget.balance) {
                  return AppLocalizations.of(context).errorAmountBalance;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
