import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/model/cex_provider.dart';
//import 'package:komodo_dex/utils/text_editing_controller_workaroud.dart';
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
  final _amtCtrl = TextEditingController();
  final _focusNode = FocusNode();
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final constrProvider = context.read<ConstructorProvider>();
      constrProvider.addListener(_onDataChange);

      if (constrProvider.buyCoin == null) {
        _focusNode.requestFocus();
      } else {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _constrProvider ??= context.watch<ConstructorProvider>();
    _cexProvider ??= context.watch<CexProvider>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
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
    final bool disabled = (_constrProvider.maxSellAmt?.toDouble() ?? 0) == 0;

    return Expanded(
      child: InkWell(
        onTap: isActive || disabled
            ? null
            : () => _constrProvider.sellAmount = buttonAmt,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: disabled
                ? Theme.of(context).disabledColor
                : isActive
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).unselectedWidgetColor,
          ),
          alignment: Alignment.center,
          child: Text(
            '${cutTrailingZeros(pct.toString())}%',
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: disabled
                      ? Theme.of(context).colorScheme.onSurface
                      : isActive
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSurface,
                ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAmt() {
    return Stack(
      children: [
        TextFormField(
          controller: _amtCtrl,
          onChanged: _constrProvider.onSellAmtFieldChange,
          focusNode: _focusNode,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            DecimalTextInputFormatter(
                decimalRange: appConfig.tradeFormPrecision),
            FilteringTextInputFormatter.allow(RegExp(
                '^\$|^(0|([1-9][0-9]{0,6}))([.,]{1}[0-9]{0,${appConfig.tradeFormPrecision}})?\$'))
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
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        horizontalTitleGap: 0,
        onTap: () => _constrProvider.sellCoin = null,
        leading: CircleAvatar(
          radius: 8,
          backgroundImage: AssetImage('assets/coin-icons/'
              '${_constrProvider.sellCoin.toLowerCase()}.png'),
        ),
        title: Text(_constrProvider.sellCoin),
        trailing: Icon(
          Icons.clear,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildFiatAmt() {
    final Rational sellAmount = _constrProvider.sellAmount;
    final double usdPrice = _cexProvider.getUsdPrice(_constrProvider.sellCoin);
    double usdAmt = 0.0;
    if (sellAmount != null && sellAmount.toDouble() > 0) {
      usdAmt = _constrProvider.sellAmount.toDouble() * usdPrice;
    }

    if (usdAmt == 0) return SizedBox();
    return Text(
      _cexProvider.convert(usdAmt),
      style: Theme.of(context).textTheme.caption.copyWith(
          color: Theme.of(context).textTheme.bodyText1.color, fontSize: 11),
    );
  }

  void _onDataChange() {
    if (!mounted) return;
    final constrProvider = context.read<ConstructorProvider>();
    if (constrProvider.sellAmount == null) {
      _amtCtrl.text = '';
      return;
    }

    final String newFormatted = cutTrailingZeros(constrProvider.sellAmount
        .toStringAsFixed(appConfig.tradeFormPrecision));
    final String currentFormatted = cutTrailingZeros(_amtCtrl.text);

    if (currentFormatted != newFormatted) {
      // MRC: Belong to TextEditingControllerWorkaround only
      //_amtCtrl.setTextAndPosition(newFormatted);

      _amtCtrl.text = newFormatted;

      if (!_focusNode.hasFocus) {
        _amtCtrl.selection = TextSelection.collapsed(offset: 0);
      }
    }
  }
}
