import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/trade/simple/create/build_rate_simple.dart';
import 'package:rational/rational.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

class BuyForm extends StatefulWidget {
  @override
  _BuyFormState createState() => _BuyFormState();
}

class _BuyFormState extends State<BuyForm> {
  final _amtCtrl = TextEditingController();
  final _focusNode = FocusNode();
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _constrProvider.addListener(_onDataChange);

      _onDataChange(); // fill the form with current data on page load
      if (_constrProvider.sellCoin == null) {
        _focusNode.requestFocus();
      } else {
        unfocusTextField(context);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _constrProvider.removeListener(_onDataChange);
    super.dispose();
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
          SizedBox(height: 2),
          BuildRateSimple(),
        ],
      ),
    );
  }

  Widget _buildAmt() {
    return Stack(
      children: [
        TextFormField(
          controller: _amtCtrl,
          focusNode: _focusNode,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: _constrProvider.onBuyAmtFieldChange,
          inputFormatters: <TextInputFormatter>[
            DecimalTextInputFormatter(
                decimalRange: appConfig.tradeFormPrecision),
            FilteringTextInputFormatter.allow(RegExp(
                '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?'))
          ],
          decoration: InputDecoration(
            isDense: true,
          ),
        ),
        Positioned(
          right: 4,
          bottom: 2,
          child: _buildFiatAmt(),
        )
      ],
    );
  }

  Widget _buildCoin() {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
        horizontalTitleGap: 0,
        onTap: () => _constrProvider.buyCoin = null,
        leading: CircleAvatar(
          radius: 8,
          backgroundImage: AssetImage('assets/coin-icons/'
              '${removeSuffix(_constrProvider.buyCoin)}.png'),
        ),
        title: Text(_constrProvider.buyCoin),
        trailing: Icon(
          Icons.clear,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildFiatAmt() {
    final Rational buyAmount = _constrProvider.buyAmount;
    final double usdPrice = _cexProvider.getUsdPrice(_constrProvider.buyCoin);
    double usdAmt = 0.0;
    if (buyAmount != null && buyAmount.toDouble() > 0) {
      usdAmt = buyAmount.toDouble() * usdPrice;
    }

    if (usdAmt == 0) return SizedBox();

    return Text(
      _cexProvider.convert(usdAmt),
      style: Theme.of(context)
          .textTheme
          .caption
          .copyWith(color: _getFiatColor(), fontSize: 11),
    );
  }

  Color _getFiatColor() {
    Color color = Theme.of(context).textTheme.bodyText1.color;

    final String sellCoin = _constrProvider.sellCoin;
    final String buyCoin = _constrProvider.buyCoin;
    final Rational buyAmount = _constrProvider.buyAmount;
    final Rational sellAmount = _constrProvider.sellAmount;
    if (sellCoin == null) return color;
    if (buyCoin == null) return color;
    if (sellAmount == null || sellAmount.toDouble() == 0) return color;
    if (buyAmount == null || buyAmount.toDouble() == 0) return color;

    final sellCoinUsdPrice = _cexProvider.getUsdPrice(sellCoin);
    final buyCoinUsdPrice = _cexProvider.getUsdPrice(buyCoin);

    if (sellCoinUsdPrice == 0 || buyCoinUsdPrice == 0) return color;

    final double sellAmtUsd = sellAmount.toDouble() * sellCoinUsdPrice;
    final double buyAmtUsd = buyAmount.toDouble() * buyCoinUsdPrice;

    if (sellAmtUsd > buyAmtUsd) {
      color = Colors.orange.withAlpha(200);
    } else if (sellAmtUsd < buyAmtUsd) {
      color = Colors.green.withAlpha(200);
    }

    return color;
  }

  void _onDataChange() {
    if (!mounted) return;

    if (_constrProvider.buyAmount == null) {
      _amtCtrl.clear();
      return;
    }

    final String newFormatted = cutTrailingZeros(_constrProvider.buyAmount
        .toStringAsFixed(appConfig.tradeFormPrecision));
    final String currentFormatted = cutTrailingZeros(_amtCtrl.text);

    if (currentFormatted != newFormatted) {
      _amtCtrl.text = newFormatted;
      moveCursorToEnd(_amtCtrl);
    }
  }
}
