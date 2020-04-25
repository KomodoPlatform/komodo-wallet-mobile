import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_book_provider.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';
import 'package:provider/provider.dart';

class CoinSelect extends StatefulWidget {
  const CoinSelect({
    this.value,
    this.type,
    this.pairedCoin,
    this.autoOpen = false,
    this.compact = false,
    this.hideInactiveCoins = false,
    this.onChange,
  });

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
  StreamSubscription _coinsListener;

  @override
  void initState() {
    super.initState();

    // Using stream listener instead of StreamBuilder in order
    // to make SimpleDialog updatable
    _coinsListener = coinsBloc.outCoins.listen((List<CoinBalance> list) {
      if (_coinsList == list) return;

      if (_isDialogOpen) {
        _closeDialog();
        setState(() => _coinsList = list);
        _showDialog();
      } else {
        setState(() => _coinsList = list);
      }
    });

    if (MMService().running) {
      coinsBloc.loadCoin();
    }

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
    final OrderBookProvider _orderBookProvider =
        Provider.of<OrderBookProvider>(context);
    final Orderbook _orderbook = _orderBookProvider.getOrderBook(pair);
    final List<Swap> _swapHistory = _orderBookProvider.getSwapHistory(pair);

    return !((_swapHistory == null || _swapHistory.isEmpty) &&
        (_orderbook == null ||
            (_orderbook.asks.isEmpty && _orderbook.bids.isEmpty)));
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
        buy: widget.type == CoinType.base ? coin : _coinsList[i],
        sell: widget.type == CoinType.base ? _coinsList[i] : coin,
      );

      if (_isPairSwapable(_pair)) return true; //
    }

    return false; //
  }

  void _showDialog() {
    setState(() {
      _isDialogOpen = true;
    });
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          if (_coinsList != null) {
            if (_coinsList.isEmpty) {
              return const SimpleDialog(
                title: Text('Select Coin'), // TODO(yurii): localization
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Text('No active coins'),
                  ),
                ], // TODO(yurii): localization
              );
            }

            final List<SimpleDialogOption> coinsList = [];
            for (int i = 0; i < _coinsList.length; i++) {
              final CoinBalance coinBalance = _coinsList[i];

              if (widget.hideInactiveCoins &&
                  !_isCoinActive(coinBalance.coin)) {
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

            return SimpleDialog(
              title: const Text('Select Coin'), // TODO(yurii): localization
              children: coinsList,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  void _closeDialog() {
    if (!_isDialogOpen) return;

    setState(() {
      _isDialogOpen = false;
    });
    dialogBloc.closeDialog(context);
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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.compact ? 3 : 6),
      child: _optionTitle,
    );
  }
}

enum CoinType {
  base,
  rel,
}
