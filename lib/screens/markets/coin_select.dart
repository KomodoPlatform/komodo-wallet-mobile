import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook_depth.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/candles_icon.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:komodo_dex/app_config/theme_data.dart';
import 'package:provider/provider.dart';

class CoinSelect extends StatefulWidget {
  const CoinSelect(
      {this.value,
      this.type,
      this.pairedCoin,
      this.autoOpen = false,
      this.compact = false,
      this.onChange,
      Key key})
      : super(key: key);

  final Coin value;
  final CoinType type;
  final Coin pairedCoin;
  final bool autoOpen;
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

    if (widget.autoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _orderBookProvider = Provider.of<OrderBookProvider>(context);
    return InkWell(
      onTap: () {
        _showDialog();
      },
      child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  widget.value != null
                      ? Image.asset(
                          'assets/${widget.value.abbr.toLowerCase()}.png',
                          height: widget.compact ? 16 : 24,
                        )
                      : CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          radius: widget.compact ? 8 : 12,
                        ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: widget.compact ? 34 : 50),
                      child: Center(
                          child: Text(
                        widget.value != null ? widget.value.abbr : '-',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(fontSize: widget.compact ? 14 : null),
                        maxLines: 1,
                      ))),
                  Icon(
                    Icons.arrow_drop_down,
                    size: widget.compact ? 14 : null,
                  ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
          )),
    );
  }

  bool _isOptionDisabled(Coin coin) {
    return coin == widget.pairedCoin;
  }

  Future<bool> _loadDepths() async {
    if (widget.pairedCoin == null) return true;
    await _orderBookProvider.subscribeDepth([
      {
        widget.pairedCoin.abbr:
            widget.type == CoinType.rel ? CoinType.base : CoinType.rel
      }
    ]);
    return true;
  }

  void _showDialog() {
    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return StreamBuilder(
            initialData: coinsBloc.coinBalance,
            stream: coinsBloc.outCoins,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return _buildProgressDialog();
              }

              return _buildList(snapshot.data);
            },
          );
        }).then((dynamic _) => dialogBloc.dialog = null);
  }

  Widget _buildList(List<CoinBalance> coins) {
    if (context == null) return SizedBox();

    final List<CoinBalance> sortedList = coinsBloc.sortCoins(coins);

    if (sortedList.isEmpty) {
      return SimpleDialog(
        title: Text(AppLocalizations.of(context).coinSelectTitle),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(AppLocalizations.of(context).coinSelectNotFound),
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

        return SimpleDialog(
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
                      tag:
                          'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Text(
                      coinBalance.coin.abbr.toUpperCase(),
                      style: TextStyle(
                        fontSize: widget.compact ? 14 : null,
                        color: coinBalance.coin == widget.value
                            ? Theme.of(context).accentColor
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: 0.4,
                child: widget.pairedCoin != null
                    ? Text(
                        '  /  ${widget.pairedCoin.abbr}',
                        style: TextStyle(fontSize: widget.compact ? 14 : null),
                      )
                    : Container(),
              ),
            ],
          );
          break;
        }

      case CoinType.rel:
        {
          _optionTitle = Row(
            children: <Widget>[
              Opacity(
                opacity: 0.4,
                child: widget.pairedCoin != null
                    ? Text(
                        '${widget.pairedCoin.abbr}  /  ',
                        style: TextStyle(fontSize: widget.compact ? 14 : null),
                      )
                    : Container(),
              ),
              Opacity(
                opacity: _isOptionDisabled(coinBalance.coin) ? 0.4 : 1,
                child: Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: widget.compact ? 8 : 12,
                      tag:
                          'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                    ),
                    SizedBox(width: widget.compact ? 6 : 8),
                    Text(
                      coinBalance.coin.abbr.toUpperCase(),
                      style: TextStyle(
                        color: coinBalance.coin == widget.value
                            ? Theme.of(context).accentColor
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
                  tag: 'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                ),
                SizedBox(width: widget.compact ? 6 : 8),
                Text(
                  coinBalance.coin.name.toUpperCase(),
                  style: TextStyle(
                    color: coinBalance.coin == widget.value
                        ? Theme.of(context).accentColor
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
      if (widget.pairedCoin == null) return Container();
      if (widget.pairedCoin.abbr == coinBalance.coin.abbr) return Container();

      final OrderbookDepth obDepth = _orderBookProvider.getDepth(CoinsPair(
        sell:
            widget.type == CoinType.rel ? widget.pairedCoin : coinBalance.coin,
        buy:
            widget.type == CoinType.base ? widget.pairedCoin : coinBalance.coin,
      ));

      if (obDepth == null) return Container();

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
                    ? settingsBloc.isLightTheme
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
      if (widget.pairedCoin == null) return Container();
      if (widget.pairedCoin.abbr == coinBalance.coin.abbr) return Container();

      final CexProvider cexProvider = Provider.of<CexProvider>(context);
      final String pair =
          '${widget.pairedCoin.abbr.toLowerCase()}-${coinBalance.coin.abbr.toLowerCase()}';
      final bool available = cexProvider.isChartAvailable(pair);

      if (!available) return Container();

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CandlesIcon(
            size: 14,
            color: settingsBloc.isLightTheme
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
    return Dialog(
      child: Container(
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
    );
  }
}

enum CoinType {
  base,
  rel,
}
