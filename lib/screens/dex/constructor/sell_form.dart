import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/swap_constructor_bloc.dart';
import 'package:komodo_dex/screens/dex/trade/trade_form.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';

class SellForm extends StatefulWidget {
  const SellForm({this.coin});

  final String coin;

  @override
  _SellFormState createState() => _SellFormState();
}

class _SellFormState extends State<SellForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          _buildCoin(),
          SizedBox(height: 8),
          _buildAmt(),
          SizedBox(height: 4),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton(10),
        SizedBox(width: 4),
        _buildButton(25),
        SizedBox(width: 4),
        _buildButton(50),
        SizedBox(width: 4),
        _buildButton(100),
      ],
    );
  }

  Widget _buildButton(double pct) {
    return Expanded(
      child: Material(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          onTap: () {},
          child: Container(
            alignment: Alignment(0, 0),
            padding: EdgeInsets.fromLTRB(1, 2, 1, 2),
            child: Text(
              '${cutTrailingZeros(pct.toString())}%',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withAlpha(180)),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmt() {
    return TextFormField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: tradeForm.precision),
          FilteringTextInputFormatter.allow(RegExp(
              '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${tradeForm.precision}})?\$'))
        ],
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                  color: Theme.of(context).highlightColor, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).accentColor,
          )),
        ));
  }

  Widget _buildCoin() {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
      child: InkWell(
        onTap: () {
          constructorBloc.sellCoin = null;
        },
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundImage:
                      AssetImage('assets/${widget.coin.toLowerCase()}.png'),
                ),
                SizedBox(width: 4),
                Text(
                  widget.coin,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Expanded(child: SizedBox()),
                Icon(
                  Icons.clear,
                  size: 12,
                  color: Theme.of(context).textTheme.caption.color,
                ),
              ],
            )),
      ),
    );
  }
}
