import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/candles_icon.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class CoinSelect extends StatefulWidget {
  const CoinSelect(
      {this.value,
      this.type,
      this.pairedCoin,
      this.autoOpen = false,
      this.compact = false,
      this.hideInactiveCoins = false,
      this.onChange,
      Key key})
      : super(key: key);

  final Coin value;
  final CoinType type;
  final Coin pairedCoin;
  final bool autoOpen;
  final bool compact;
  // Only show coins with at least one order or swap
  final bool hideInactiveCoins;
  final Function(Coin) onChange;

  @override
  _CoinSelectState createState() => _CoinSelectState();
}

class _CoinSelectState extends State<CoinSelect> {
  List<CoinBalance> _coinsList;
  bool _isDialogOpen = false;
  bool _orderBooksLoaded = false;
  StreamSubscription _coinsListener;
  OrderBookProvider _orderBookProvider;

  @override
  void initState() {
    super.initState();

    // Using stream listener instead of StreamBuilder in order
    // to make SimpleDialog updatable
    _coinsListener = coinsBloc.outCoins.listen((List<CoinBalance> list) {
      if (_coinsList == list) return;

      setState(() => _coinsList = list);
      _refreshDialog();
    });

    if (mmSe.running) coinsBloc.updateCoinBalances();

    if (widget.autoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _coinsListener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _orderBookProvider = Provider.of<OrderBookProvider>(context);
    return InkWell(
      onTap: () {
        setState(() {
          _orderBooksLoaded = false;
        });
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
                            .subtitle
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

  bool _isPairSwapable(CoinsPair pair) {
    final Orderbook _orderbook = _orderBookProvider.getOrderBook(pair);
    final List<Swap> _swapHistory = _orderBookProvider.getSwapHistory(pair);

    return !((_swapHistory == null || _swapHistory.isEmpty) &&
        (_orderbook == null ||
            ((_orderbook.asks == null || _orderbook.asks.isEmpty) &&
                (_orderbook.bids == null || _orderbook.bids.isEmpty))));
  }

  bool _isCoinActive(Coin coin) {
    if (widget.pairedCoin != null) {
      final _pair = CoinsPair(
        buy: widget.type == CoinType.base ? coin : widget.pairedCoin,
        sell: widget.type == CoinType.base ? widget.pairedCoin : coin,
      );

      return _isPairSwapable(_pair); //
    }

    for (int i = 0; i < _coinsList.length; i++) {
      final _pair = CoinsPair(
        buy: widget.type == CoinType.base ? coin : _coinsList[i].coin,
        sell: widget.type == CoinType.base ? _coinsList[i].coin : coin,
      );

      if (_isPairSwapable(_pair)) return true; //
    }

    return false; //
  }

  Future<void> _loadOrderBooks() async {
    await _orderBookProvider.subscribeCoin(widget.pairedCoin, widget.type);
    setState(() {
      _orderBooksLoaded = true;
    });
    _refreshDialog();
  }

  void _refreshDialog() {
    if (!_isDialogOpen) return;

    _closeDialog();
    _showDialog();
  }

  void _showDialog() {
    setState(() {
      _isDialogOpen = true;
    });

    dialogBloc.dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          if (_coinsList == null) {
            if (!_orderBooksLoaded) _loadOrderBooks();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (widget.pairedCoin != null && !_orderBooksLoaded) {
            _loadOrderBooks();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<CoinBalance> _sortedList = coinsBloc.sortCoins(_coinsList);
          if (_sortedList.isEmpty) {
            return const SimpleDialog(
              title: Text('Select Coin'), // TODO(yurii): localization
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text('No active coins'), // TODO(yurii): localization
                ),
              ],
            );
          }

          final List<SimpleDialogOption> resetSelect = widget.value == null
              ? []
              : [
                  SimpleDialogOption(
                    onPressed: () {
                      _closeDialog();
                      if (widget.onChange != null) {
                        widget.onChange(null);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cancel),
                        const SizedBox(width: 8),
                        const Text('Clear'),
                      ],
                    ),
                  ),
                ];

          final List<SimpleDialogOption> coinsList = [];
          for (int i = 0; i < _sortedList.length; i++) {
            final CoinBalance coinBalance = _sortedList[i];

            if (widget.hideInactiveCoins && !_isCoinActive(coinBalance.coin)) {
              continue;
            }

            coinsList.add(SimpleDialogOption(
              key: Key('coin-select-option-${coinBalance.coin.abbr}'),
              onPressed: _isOptionDisabled(coinBalance.coin)
                  ? null
                  : () {
                      _closeDialog();
                      if (widget.onChange != null) {
                        widget.onChange(coinBalance.coin);
                      }
                    },
              child: _buildOption(coinBalance),
            ));
          }

          if (coinsList.isEmpty) {
            coinsList.add(
              const SimpleDialogOption(
                child: Text('No coins to show'), // TODO(yurii): localization
              ),
            );
          }

          return SimpleDialog(
            title: const Text('Select Coin'), // TODO(yurii): localization
            children: [
              ...resetSelect,
              ...coinsList,
            ],
          );
        });
  }

  void _closeDialog() {
    if (!_isDialogOpen) return;

    dialogBloc.closeDialog(context);
    setState(() {
      _isDialogOpen = false;
    });
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

      final Orderbook orderbook = _orderBookProvider.getOrderBook(CoinsPair(
        sell:
            widget.type == CoinType.base ? widget.pairedCoin : coinBalance.coin,
        buy: widget.type == CoinType.rel ? widget.pairedCoin : coinBalance.coin,
      ));

      if (orderbook == null) return Container();

      return Row(
        children: <Widget>[
          Text(
            '${orderbook.asks.length}',
            style: TextStyle(
              color: orderbook.asks.isNotEmpty
                  ? Colors.red
                  : Theme.of(context).highlightColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 1,
            height: 10,
            color: orderbook.asks.isNotEmpty && orderbook.bids.isNotEmpty
                ? cexColor.withAlpha(100)
                : Theme.of(context).highlightColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${orderbook.bids.length}',
            style: TextStyle(
              color: orderbook.bids.isNotEmpty
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
            color: cexColor.withAlpha(120),
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
}

enum CoinType {
  base,
  rel,
}
