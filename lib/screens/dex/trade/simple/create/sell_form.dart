import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/model/app_config.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/widgets/auto_scroll_text.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:rational/rational.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class SellForm extends StatefulWidget {
  @override
  _SellFormState createState() => _SellFormState();
}

class _SellFormState extends State<SellForm> {
  final _amtCtrl = TextEditingControllerWorkaroud();
  final _focusNode = FocusNode();
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;
  bool _showClearButton = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _constrProvider.addListener(_onDataChange);
      _amtCtrl.addListener(_onAmtFieldChange);

      _fillForm();
      if (_constrProvider.buyCoin == null) {
        _focusNode.requestFocus();
      } else {
        FocusScope.of(context).requestFocus(FocusNode());
      }

      _focusNode.addListener(() {
        setState(() => _showClearButton = _focusNode.hasFocus);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _cexProvider ??= Provider.of<CexProvider>(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCoin(),
          SizedBox(height: 6),
          _buildAmt(),
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
    final Rational buttonAmt = _constrProvider.maxSellAmt *
        Rational.parse('$pct') /
        Rational.parse('100');
    final String formattedButtonAmt = cutTrailingZeros(
        buttonAmt.toStringAsFixed(appConfig.tradeFormPrecision));
    final bool isActive = formattedButtonAmt == _amtCtrl.text;

    return Expanded(
      child: GestureDetector(
        onTap: isActive
            ? null
            : () {
                _constrProvider.sellAmount = buttonAmt;
              },
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? Theme.of(context).accentColor.withAlpha(200)
                  : Theme.of(context).primaryColor,
            ),
            alignment: Alignment(0, 0),
            padding: EdgeInsets.fromLTRB(1, 3, 1, 3),
            child: Text(
              '${cutTrailingZeros(pct.toString())}%',
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .color
                      .withAlpha(isActive ? 255 : 180)),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmt() {
    return TextFormField(
        controller: _amtCtrl,
        focusNode: _focusNode,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: appConfig.tradeFormPrecision),
          FilteringTextInputFormatter.allow(RegExp(
              '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?\$'))
        ],
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(12, 16, 0, 16),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                  color: Theme.of(context).highlightColor, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).accentColor,
          )),
          suffixIcon: _constrProvider.sellAmount == null || !_showClearButton
              ? null
              : InkWell(
                  child: Icon(
                    Icons.clear,
                    size: 13,
                    color: Theme.of(context).textTheme.caption.color,
                  ),
                  onTap: () {
                    _constrProvider.sellAmount = null;
                  },
                ),
        ));
  }

  Widget _buildCoin() {
    return Card(
        margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            _constrProvider.sellCoin = null;
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 50),
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundImage: AssetImage(
                                'assets/${_constrProvider.sellCoin.toLowerCase()}.png'),
                          ),
                          SizedBox(width: 4),
                          Text(
                            _constrProvider.sellCoin,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ),
                      _buildFiatAmt(),
                    ]),
                  ),
                  Icon(
                    Icons.clear,
                    size: 13,
                    color: Theme.of(context).textTheme.caption.color,
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildFiatAmt() {
    final Rational sellAmount = _constrProvider.sellAmount;
    final double usdPrice = _cexProvider.getUsdPrice(_constrProvider.sellCoin);
    double usdAmt = 0.0;
    if (sellAmount != null && sellAmount.toDouble() > 0) {
      usdAmt = _constrProvider.sellAmount.toDouble() * usdPrice;
    } else {
      return SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 4),
        usdAmt == 0
            ? Row(
                children: [
                  Expanded(
                    child: AutoScrollText(
                      text: '${cutTrailingZeros(formatPrice(sellAmount))}'
                          ' ${_constrProvider.sellCoin}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  CexMarker(
                    context,
                    size: Size.fromRadius(6),
                  ),
                  SizedBox(width: 2),
                  Expanded(
                    child: AutoScrollText(
                      text: _cexProvider.convert(usdAmt),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  void _onDataChange() {
    if (_constrProvider.sellAmount == null) {
      _amtCtrl.text = '';
      return;
    }

    final String newFormatted = cutTrailingZeros(_constrProvider.sellAmount
        .toStringAsFixed(appConfig.tradeFormPrecision));
    final String currentFormatted = cutTrailingZeros(_amtCtrl.text);

    if (currentFormatted != newFormatted) {
      _amtCtrl.setTextAndPosition(newFormatted);

      Future<dynamic>.delayed(Duration.zero).then((dynamic _) {
        if (!_focusNode.hasFocus) {
          _amtCtrl.selection = TextSelection.collapsed(offset: 0);
        }
      });
    }
  }

  void _onAmtFieldChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _constrProvider.onSellAmtFieldChange(_amtCtrl.text);
    });
  }

  void _fillForm() {
    _onDataChange();
    setState(() {});
  }
}
