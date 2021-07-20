import 'package:flutter/material.dart';
import 'package:komodo_dex/widgets/cex_data_marker.dart';
import 'package:rational/rational.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/model/app_config.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/widgets/auto_scroll_text.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuyForm extends StatefulWidget {
  @override
  _BuyFormState createState() => _BuyFormState();
}

class _BuyFormState extends State<BuyForm> {
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
      if (_constrProvider.sellCoin == null) {
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

    return Container(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoin(),
          SizedBox(height: 6),
          _buildAmt(),
        ],
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
          suffixIcon: _constrProvider.buyAmount == null || !_showClearButton
              ? null
              : InkWell(
                  child: Icon(
                    Icons.clear,
                    size: 13,
                    color: Theme.of(context).textTheme.caption.color,
                  ),
                  onTap: () {
                    _constrProvider.buyAmount = null;
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
            _constrProvider.buyCoin = null;
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
                                'assets/${_constrProvider.buyCoin.toLowerCase()}.png'),
                          ),
                          SizedBox(width: 4),
                          Text(
                            _constrProvider.buyCoin,
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
    final Rational buyAmount = _constrProvider.buyAmount;
    final double usdPrice = _cexProvider.getUsdPrice(_constrProvider.buyCoin);
    double usdAmt = 0.0;
    if (buyAmount != null && buyAmount.toDouble() > 0) {
      usdAmt = buyAmount.toDouble() * usdPrice;
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
                      text: '${cutTrailingZeros(formatPrice(buyAmount))}'
                          ' ${_constrProvider.buyCoin}',
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
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: _getFiatColor()),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Color _getFiatColor() {
    final String sellCoin = _constrProvider.sellCoin;
    final String buyCoin = _constrProvider.buyCoin;
    final Rational buyAmount = _constrProvider.buyAmount;
    final Rational sellAmount = _constrProvider.sellAmount;
    if (sellCoin == null) return null;
    if (buyCoin == null) return null;
    if (sellAmount == null || sellAmount.toDouble() == 0) return null;
    if (buyAmount == null || buyAmount.toDouble() == 0) return null;

    final sellCoinUsdPrice = _cexProvider.getUsdPrice(sellCoin);
    final buyCoinUsdPrice = _cexProvider.getUsdPrice(buyCoin);

    if (sellCoinUsdPrice == 0 || buyCoinUsdPrice == 0) return null;

    final double sellAmtUsd = sellAmount.toDouble() * sellCoinUsdPrice;
    final double buyAmtUsd = buyAmount.toDouble() * buyCoinUsdPrice;

    if (sellAmtUsd > buyAmtUsd) {
      return Colors.orange;
    } else if (sellAmtUsd < buyAmtUsd) {
      return Colors.green;
    } else {
      return null;
    }
  }

  void _onDataChange() {
    if (_constrProvider.buyAmount == null) {
      _amtCtrl.text = '';
      return;
    }

    final String newFormatted = cutTrailingZeros(_constrProvider.buyAmount
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
      _constrProvider.onBuyAmtFieldChange(_amtCtrl.text);
    });
  }

  void _fillForm() {
    _onDataChange();
    setState(() {});
  }
}
