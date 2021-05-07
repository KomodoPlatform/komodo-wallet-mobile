import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';

class MinVolumeControl extends StatefulWidget {
  const MinVolumeControl({
    @required this.base,
    this.rel,
    this.price,
    this.onChange,
  });

  final String base;
  final String rel;
  final double price;
  final Function(String, bool) onChange;

  @override
  _MinVolumeControlState createState() => _MinVolumeControlState();
}

class _MinVolumeControlState extends State<MinVolumeControl> {
  final TextEditingController _valueCtrl = TextEditingController();
  bool _isActive = false;
  double _defaultValue;
  String _value;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: tradeForm.minVolumeDefault(
          widget.base,
          rel: widget.rel,
          price: widget.price,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          _defaultValue ??= snapshot.data;

          return Column(
            children: [
              if (_isActive) _buildControl(),
              _buildToggle(),
            ],
          );
        });
  }

  Widget _buildControl() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Text(
            '${AppLocalizations.of(context).minVolumeTitle}:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 7,
                          backgroundImage: AssetImage('assets/'
                              '${widget.base.toLowerCase()}.png'),
                        ),
                        SizedBox(width: 2),
                        Text(widget.base),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: TextFormField(
                      controller: _valueCtrl,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).accentColor),
                        ),
                      ),
                      maxLines: 1,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(16),
                        DecimalTextInputFormatter(decimalRange: 8),
                      ],
                      autovalidateMode: AutovalidateMode.always,
                      validator: _validate,
                      onChanged: (String text) {
                        setState(() {
                          _value = text;
                        });
                        widget.onChange(_value, _validate(_value) == null);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildToggle() {
    return FutureBuilder<double>(
        future: tradeForm.minVolumeDefault(
          widget.base,
          rel: widget.rel,
          price: widget.price,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();

          return InkWell(
            onTap: () {
              setState(() => _isActive = !_isActive);

              if (_isActive) {
                setState(() => _value ??=
                    '${cutTrailingZeros(formatPrice(snapshot.data))}');
                _valueCtrl.text = _value;
                widget.onChange(_value, _validate(_value) == null);
              } else {
                widget.onChange(null, true);
              }
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(30, 8, 30, 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    _isActive ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).minVolumeToggle,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  String _validate(String value) {
    if (value == null) return null;

    final double minVolumeValue = double.tryParse(value);
    final double amountToSell = swapBloc.amountSell;

    if (minVolumeValue == null) {
      return AppLocalizations.of(context).nonNumericInput;
    } else if (minVolumeValue < _defaultValue) {
      return AppLocalizations.of(context)
          .minVolumeInput(_defaultValue, swapBloc.sellCoinBalance.coin.abbr);
    } else if (amountToSell != null && minVolumeValue > amountToSell) {
      return AppLocalizations.of(context).minVolumeIsTDH;
    } else {
      return null;
    }
  }
}
