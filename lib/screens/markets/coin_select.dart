import 'dart:async';

import 'package:flutter/material.dart';
import '../../blocs/coins_bloc.dart';
import '../../blocs/dialog_bloc.dart';
import '../../localizations.dart';
import '../../model/cex_provider.dart';
import '../../model/coin.dart';
import '../../model/coin_balance.dart';
import '../../model/order_book_provider.dart';
import '../../model/orderbook_depth.dart';
import '../../services/mm_service.dart';
import '../../utils/utils.dart';
import '../../widgets/auto_scroll_text.dart';
import '../../widgets/candles_icon.dart';
import '../../widgets/custom_simple_dialog.dart';
import '../../widgets/photo_widget.dart';
import '../../app_config/theme_data.dart';
import 'package:provider/provider.dart';

class CoinSelect extends StatefulWidget {
  const CoinSelect({
    Key key,
    this.value,
    this.type,
    this.pairedCoin,
    this.compact = false,
    this.onChange,
  }) : super(key: key);

  final Coin value;
  final CoinType type;
  final Coin pairedCoin;
  final bool compact;
  final Function(Coin) onChange;

  @override
  _CoinSelectState createState() => _CoinSelectState();
}

class _CoinSelectState extends State<CoinSelect> {
  OrderBookProvider _orderBookProvider;

  @override
  void initState() {
    super.initState();

    if (mmSe.running) coinsBloc.updateCoinBalances();
  }

  @override
  Widget build(BuildContext context) {
    _orderBookProvider = Provider.of<OrderBookProvider>(context);
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      minLeadingWidth: 16,
      horizontalTitleGap: 8,
      onTap: () => _showDialog(),
      leading: widget.value != null
          ? Image.asset(
              getCoinIconPath(widget.value.abbr),
              height: widget.compact ? 16 : 24,
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              radius: widget.compact ? 8 : 12,
            ),
      title: AutoScrollText(
        text: widget.value != null ? widget.value.abbr : '-',
      ),
      trailing: Icon(Icons.arrow_drop_down),
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey,
        ),
      ),
    );
  }

  bool _isOptionDisabled(Coin coin) {
    return coin == widget.pairedCoin;
  }

  Future<bool> _loadDepths() async {
    if (widget.pairedCoin == null) return true;
    await _orderBookProvider.subscribeDepth(
      widget.pairedCoin.abbr,
      widget.type == CoinType.rel ? CoinType.base : CoinType.rel,
    );
    return true;
  }

  void _showDialog() {
    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder<List<CoinBalance>>(
            initialData: coinsBloc.coinBalance,
            stream: coinsBloc.outCoins,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return _buildProgressDialog();
              }
              List<CoinBalance> data = snapshot.data;
              data.removeWhere((e) => e.coin.walletOnly);

              return _buildList(data);
            },
          );
        }).then((dynamic _) => dialogBloc.dialog = null);
  }

  Widget _buildList(List<CoinBalance> coins) {
    if (context == null) return SizedBox();

    final List<CoinBalance> sortedList = coinsBloc.sortCoins(coins);

    if (sortedList.isEmpty) {
      return CustomSimpleDialog(
        title: Text(AppLocalizations.of(context).coinSelectTitle),
        children: <Widget>[
          Text(AppLocalizations.of(context).coinSelectNotFound),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).okButton),
              ),
            ],
          ),
        ],
      );
    }

    return FutureBuilder<bool>(
      future: _loadDepths(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildProgressDialog();

        final List<SimpleDialogOption> resetSelect = widget.value == null
            ? []
            : [
                SimpleDialogOption(
                  onPressed: () {
                    dialogBloc.closeDialog(context);
                    if (widget.onChange != null) {
                      widget.onChange(null);
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.cancel),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context).coinSelectClear),
                    ],
                  ),
                ),
              ];

        final List<SimpleDialogOption> coinsList = [];
        for (int i = 0; i < sortedList.length; i++) {
          final CoinBalance coinBalance = sortedList[i];

          coinsList.add(SimpleDialogOption(
            key: Key('coin-select-option-${coinBalance.coin.abbr}'),
            onPressed: _isOptionDisabled(coinBalance.coin)
                ? null
                : () {
                    dialogBloc.closeDialog(context);
                    if (widget.onChange != null) {
                      widget.onChange(coinBalance.coin);
                    }
                  },
            child: _buildOption(coinBalance),
          ));
        }

        if (coinsList.isEmpty) {
          coinsList.add(
            SimpleDialogOption(
              child: Text(AppLocalizations.of(context).coinSelectNotFound),
            ),
          );
        }

        return CustomSimpleDialog(
          hasHorizontalPadding: false,
          title: Text(AppLocalizations.of(context).coinSelectTitle),
          children: [
            ...resetSelect,
            ...coinsList,
          ],
        );
      },
    );
  }

  Widget _buildOption(CoinBalance coinBalance) {
    Widget _optionTitle;

    switch (widget.type) {
      case CoinType.base:
        {
          _optionTitle = Row(
            children: <Widget>[
              Opacity(
                opacity: _isOptionDisabled(coinBalance.coin) ? 0.4 : 1,
                child: Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: widget.compact ? 8 : 12,
                      tag: getCoinIconPath(coinBalance.balance.coin),
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Text(
                      coinBalance.coin.abbr.toUpperCase(),
                      style: TextStyle(
                        fontSize: widget.compact ? 14 : null,
                        color: coinBalance.coin == widget.value
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.pairedCoin != null)
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    '  /  ${widget.pairedCoin.abbr}',
                    style: TextStyle(fontSize: widget.compact ? 14 : null),
                  ),
                ),
            ],
          );
          break;
        }

      case CoinType.rel:
        {
          _optionTitle = Row(
            children: <Widget>[
              if (widget.pairedCoin != null)
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    '${widget.pairedCoin.abbr}  /  ',
                    style: TextStyle(fontSize: widget.compact ? 14 : null),
                  ),
                ),
              Opacity(
                opacity: _isOptionDisabled(coinBalance.coin) ? 0.4 : 1,
                child: Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: widget.compact ? 8 : 12,
                      tag: getCoinIconPath(coinBalance.balance.coin),
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Text(
                      coinBalance.coin.abbr.toUpperCase(),
                      style: TextStyle(
                        color: coinBalance.coin == widget.value
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                        fontSize: widget.compact ? 14 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          break;
        }

      default:
        {
          _optionTitle = Opacity(
            opacity: _isOptionDisabled(coinBalance.coin) ? 0.4 : 1,
            child: Row(
              children: <Widget>[
                PhotoHero(
                  radius: widget.compact ? 8 : 12,
                  tag: getCoinIconPath(coinBalance.balance.coin),
                ),
                SizedBox(width: widget.compact ? 6 : 8),
                Text(
                  coinBalance.coin.name.toUpperCase(),
                  style: TextStyle(
                    color: coinBalance.coin == widget.value
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                    fontSize: widget.compact ? 14 : null,
                  ),
                ),
              ],
            ),
          );
        }
    }

    Widget _bildOrdersNumber() {
      if (widget.pairedCoin == null) return SizedBox();
      if (widget.pairedCoin.abbr == coinBalance.coin.abbr) return SizedBox();

      final OrderbookDepth obDepth = _orderBookProvider.getDepth(CoinsPair(
        sell:
            widget.type == CoinType.rel ? widget.pairedCoin : coinBalance.coin,
        buy:
            widget.type == CoinType.base ? widget.pairedCoin : coinBalance.coin,
      ));

      if (obDepth == null) return SizedBox();

      return Row(
        children: <Widget>[
          Text(
            '${obDepth.depth.asks}',
            style: TextStyle(
              color: (obDepth.depth.asks ?? 0) > 0
                  ? Colors.red
                  : Theme.of(context).highlightColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 1,
            height: 10,
            color:
                (obDepth.depth.asks ?? 0) > 0 && (obDepth.depth.bids ?? 0) > 0
                    ? Theme.of(context).brightness == Brightness.light
                        ? cexColorLight.withAlpha(100)
                        : cexColor.withAlpha(100)
                    : Theme.of(context).highlightColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${obDepth.depth.bids}',
            style: TextStyle(
              color: (obDepth.depth.bids ?? 0) > 0
                  ? Colors.green
                  : Theme.of(context).highlightColor,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    Widget _buildCandlesIcon() {
      if (widget.pairedCoin == null) return SizedBox();
      if (widget.pairedCoin.abbr == coinBalance.coin.abbr) return SizedBox();

      final CexProvider cexProvider = Provider.of<CexProvider>(context);
      final String pair =
          '${widget.pairedCoin.abbr.toLowerCase()}-${coinBalance.coin.abbr.toLowerCase()}';
      final bool available = cexProvider.isChartAvailable(pair);

      if (!available) return SizedBox();

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CandlesIcon(
            size: 14,
            color: Theme.of(context).brightness == Brightness.light
                ? cexColorLight.withAlpha(50)
                : cexColor.withAlpha(50),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.compact ? 3 : 6),
      child: Row(
        children: <Widget>[
          Expanded(child: _optionTitle),
          _buildCandlesIcon(),
          const SizedBox(width: 2),
          _bildOrdersNumber(),
        ],
      ),
    );
  }

  Widget _buildProgressDialog() {
    return CustomSimpleDialog(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(
                width: 16,
              ),
              Text(
                AppLocalizations.of(context).loading,
                style: Theme.of(context).textTheme.bodyText2,
              )
            ],
          ),
        ),
      ],
    );
  }
}

enum CoinType {
  base,
  rel,
}
