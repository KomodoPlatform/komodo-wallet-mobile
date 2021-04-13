import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/trade_preimage.dart';
import 'package:komodo_dex/screens/dex/trade/confirm/build_detailed_fees.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class MultiOrderRelItem extends StatefulWidget {
  const MultiOrderRelItem({
    this.item,
    this.color,
    this.controller,
    this.focusNode,
    this.onSelectChange,
  });

  final CoinBalance item;
  final Color color;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(bool) onSelectChange;

  @override
  _MultiOrderRelItemState createState() => _MultiOrderRelItemState();
}

class _MultiOrderRelItemState extends State<MultiOrderRelItem> {
  MultiOrderProvider _multiOrderProvider;
  CexProvider _cexProvider;
  bool _showDetailedError = false;

  @override
  Widget build(BuildContext context) {
    _multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);
    _cexProvider ??= Provider.of<CexProvider>(context);

    return Container(
      color: widget.color,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTitle(),
              Expanded(child: _buildAmount()),
              _buildSwitch(),
            ],
          ),
          _buildFees(),
          _buildError(),
        ],
      ),
    );
  }

  Widget _buildError() {
    final String error = _multiOrderProvider.getError(widget.item.coin.abbr);

    return error == null
        ? SizedBox()
        : InkWell(
            onTap: () =>
                setState(() => _showDetailedError = !_showDetailedError),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '$error',
                      maxLines: _showDetailedError ? null : 1,
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
                  Icon(
                    _showDetailedError
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 14,
                  )
                ],
              ),
            ),
          );
  }

  Widget _buildFees() {
    final TradePreimage preimage =
        _multiOrderProvider.getPreimage(widget.item.coin.abbr);

    return preimage == null
        ? SizedBox()
        : Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: BuildDetailedFees(
              preimage: preimage,
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                  ),
            ),
          );
  }

  Widget _buildTitle() {
    return Opacity(
      opacity: _multiOrderProvider.isRelCoinSelected(widget.item.coin.abbr)
          ? 1
          : 0.5,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 6, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    maxRadius: 6,
                    backgroundImage: AssetImage(
                        'assets/${widget.item.coin.abbr.toLowerCase()}.png'),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.item.coin.abbr,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                  padding: EdgeInsets.only(left: 2), child: _buildPrice()),
              // _buildFee(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrice() {
    final double sellAmt = _multiOrderProvider.baseAmt;
    final double relAmt =
        _multiOrderProvider.getRelCoinAmt(widget.item.coin.abbr);
    if (relAmt == null || relAmt == 0) return Container();
    if (sellAmt == null || sellAmt == 0) return Container();

    final double price = relAmt / sellAmt;
    final double cexPrice = _cexProvider.getCexRate(CoinsPair(
        buy: widget.item.coin,
        sell: coinsBloc.getCoinByAbbr(_multiOrderProvider.baseCoin)));
    double delta;
    if (cexPrice != null && cexPrice != 0) {
      delta = (price - cexPrice) * 100 / cexPrice;
      if (delta > 99.99) delta = 99.99;
      if (delta < -99.99) delta = -99.99;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          formatPrice(price),
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).disabledColor,
          ),
        ),
        _buildDelta(delta),
      ],
    );
  }

  Widget _buildDelta(double delta) {
    if (delta == null) return Container();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: delta.abs() < 0.01
          ? <Widget>[
              const SizedBox(width: 3),
              Text(
                '≈0.00%',
                style: TextStyle(
                  fontSize: 10,
                  color: settingsBloc.isLightTheme
                      ? cexColorLight.withAlpha(150)
                      : cexColor.withAlpha(150),
                ),
              ),
            ]
          : <Widget>[
              const SizedBox(width: 3),
              Text(
                delta > 0 ? '+' : '',
                style: TextStyle(
                  fontSize: 10,
                  color: delta > 0 ? Colors.green : Colors.orange,
                ),
              ),
              Text(
                '${formatPrice(delta, 2)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: delta > 0 ? Colors.green : Colors.orange,
                ),
              ),
            ],
    );
  }

  Widget _buildAmount() {
    if (!_multiOrderProvider.isRelCoinSelected(widget.item.coin.abbr))
      return Container();

    final double usdPrice =
        _cexProvider.getUsdPrice(widget.item.coin.abbr) ?? 0;
    final double usdAmt =
        (_multiOrderProvider.getRelCoinAmt(widget.item.coin.abbr) ?? 0) *
            usdPrice;
    final String convertedAmt =
        usdAmt > 0 ? _cexProvider.convert(usdAmt) : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 32,
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textAlign: TextAlign.right,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: settingsBloc.isLightTheme
                          ? getThemeLight().accentColor
                          : getThemeDark().accentColor),
                ),
                contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
              ),
              maxLines: 1,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(16),
                DecimalTextInputFormatter(decimalRange: 8),
              ],
              onChanged: (String value) {
                final double amnt = double.tryParse(value ?? '');
                _multiOrderProvider.setRelCoinAmt(widget.item.coin.abbr, amnt);
              },
            ),
          ),
          if (convertedAmt != null)
            Text(
              convertedAmt,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: settingsBloc.isLightTheme
                    ? cexColorLight.withAlpha(150)
                    : cexColor.withAlpha(150),
                fontSize: 10,
                height: 1.2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitch() {
    return Switch(
        value: _multiOrderProvider.isRelCoinSelected(widget.item.coin.abbr),
        onChanged: widget.onSelectChange);
  }
}
