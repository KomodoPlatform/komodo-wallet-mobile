import 'package:flutter/material.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/dex/trade/create/auto_scroll_text.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:rational/rational.dart';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/best_order.dart';
import 'package:komodo_dex/model/get_best_orders.dart';
import 'package:komodo_dex/model/swap_constructor_provider.dart';
import 'package:provider/provider.dart';

class CoinsListBestItem extends StatefulWidget {
  const CoinsListBestItem(this.order, {Key key}) : super(key: key);

  final BestOrder order;

  @override
  _CoinsListBestItemState createState() => _CoinsListBestItemState();
}

class _CoinsListBestItemState extends State<CoinsListBestItem>
    with AutomaticKeepAliveClientMixin {
  ConstructorProvider _constrProvider;
  CexProvider _cexProvider;
  String _coin;
  bool _expanded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _constrProvider ??= Provider.of<ConstructorProvider>(context);
    _cexProvider ??= Provider.of<CexProvider>(context);
    _coin = widget.order.action == MarketAction.SELL
        ? widget.order.coin
        : widget.order.forCoin;

    return StreamBuilder<List<CoinBalance>>(
        initialData: coinsBloc.coinBalance,
        stream: coinsBloc.outCoins,
        builder: (context, snapshot) {
          final bool isCoinActive = snapshot.data.firstWhere(
                  (item) => item.coin.abbr == _coin,
                  orElse: () => null) !=
              null;

          return Card(
            margin: EdgeInsets.fromLTRB(0, 6, 12, 0),
            child: InkWell(
              onTap: () => _handleTap(isCoinActive),
              borderRadius: BorderRadius.circular(4),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 50),
                child: Opacity(
                  opacity: isCoinActive
                      ? 1
                      : _expanded
                          ? 0.6
                          : 0.4,
                  child: Container(
                      padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTitle(),
                          SizedBox(height: 4),
                          _buildDetails(isCoinActive),
                        ],
                      )),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildTitle() {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundImage: AssetImage('assets/${_coin.toLowerCase()}.png'),
        ),
        SizedBox(width: 4),
        Text(_coin),
      ],
    );
  }

  void _handleTap(bool isCoinActive) {
    if (isCoinActive) {
      _selectOrder();
    } else {
      setState(() => _expanded = !_expanded);
    }
  }

  void _selectOrder() {}

  Widget _buildDetails(bool isCoinActive) {
    return Column(
      children: [
        _buildAmtDetails(),
        _buildExpanded(isCoinActive),
      ],
    );
  }

  Widget _buildExpanded(bool isCoinActive) {
    if (!_expanded) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //SizedBox(height: 12),
        Divider(),
        Text(
          '$_coin is not active!',
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: _buildButton(
                onPressed: () {
                  setState(() => _expanded = !_expanded);
                },
                child: Text(
                  'Close',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                color: Colors.transparent,
              ),
            ),
            SizedBox(width: 4),
            _buildButton(
              onPressed: _tryActivate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_outlined,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    'Activate',
                    style: Theme.of(context).textTheme.caption.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
      ],
    );
  }

  Future<void> _tryActivate() async {}

  Widget _buildButton({Color color, Function onPressed, Widget child}) {
    color ??= Theme.of(context).accentColor;

    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).accentColor.withAlpha(100)),
          borderRadius: BorderRadius.circular(4),
          color: color,
        ),
        padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
        alignment: Alignment(0, 0),
        child: child,
      ),
    );
  }

  Widget _buildAmtDetails() {
    final String counterCoin = widget.order.action == MarketAction.BUY
        ? _constrProvider.buyCoin
        : _constrProvider.sellCoin;
    final Rational counterAmount = widget.order.action == MarketAction.BUY
        ? _constrProvider.buyAmount
        : _constrProvider.sellAmount;
    final double cexPrice = _cexProvider.getUsdPrice(_coin);
    final double counterCexPrice = _cexProvider.getUsdPrice(counterCoin);

    String receiveStr;
    Widget fiatProfitStr;

    if (cexPrice != 0) {
      final double receiveAmtUsd =
          cexPrice * widget.order.price.toDouble() * counterAmount.toDouble();
      receiveStr = _cexProvider.convert(receiveAmtUsd);

      if (counterCexPrice != 0) {
        final double counterAmtUsd = counterAmount.toDouble() * counterCexPrice;
        double fiatProfitPct =
            (receiveAmtUsd - counterAmtUsd) * 100 / counterAmtUsd;
        if (fiatProfitPct < -99.9) fiatProfitPct = -99.9;
        if (fiatProfitPct > 99.9) fiatProfitPct = 99.9;

        Color color = Theme.of(context).textTheme.caption.color;
        if (fiatProfitPct < 0) {
          color = widget.order.action == MarketAction.BUY
              ? Colors.green
              : Colors.orangeAccent;
        } else if (fiatProfitPct > 0) {
          color = widget.order.action == MarketAction.BUY
              ? Colors.orangeAccent
              : Colors.green;
        }
        fiatProfitStr = Text(
          ' (' +
              _getPctSign(fiatProfitPct) +
              cutTrailingZeros(formatPrice(fiatProfitPct, 3)) +
              '%)',
          style: Theme.of(context).textTheme.caption.copyWith(color: color),
        );
      }
    } else {
      final double receiveAmt =
          widget.order.price.toDouble() * counterAmount.toDouble();
      receiveStr = cutTrailingZeros(formatPrice(receiveAmt)) + ' ' + _coin;
    }

    return Row(
      children: [
        Text(
          (widget.order.action == MarketAction.SELL ? 'Receive' : 'Send') + ':',
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(color: Theme.of(context).textTheme.bodyText1.color),
        ),
        SizedBox(width: 4),
        Flexible(
          child: AutoScrollText(
            text: receiveStr,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        fiatProfitStr ?? SizedBox(),
      ],
    );
  }

  String _getPctSign(double pct) {
    return pct > 0 ? '+' : '';
  }
}
