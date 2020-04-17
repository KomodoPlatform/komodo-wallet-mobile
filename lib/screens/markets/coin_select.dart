import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';

class CoinSelect extends StatefulWidget {
  const CoinSelect({
    this.value,
    this.type,
    this.pairedCoin,
    this.autoOpen = false,
    this.onChange,
  });

  final Coin value;
  final CoinType type;
  final Coin pairedCoin;
  final bool autoOpen;
  final Function(Coin) onChange;

  @override
  _CoinSelectState createState() => _CoinSelectState();
}

class _CoinSelectState extends State<CoinSelect> {
  List<CoinBalance> _coinsList;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();

    coinsBloc.outCoins.listen((List<CoinBalance> list) {
      setState(() {
        if (_isDialogOpen && (_coinsList != list)) {
          _closeDialog();
          _coinsList = list;
          _showDialog();
        } else {
          _coinsList = list;
        }
      });
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
                          height: 25,
                        )
                      : CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          radius: 12,
                        ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 50),
                      child: Center(
                          child: Text(
                        widget.value != null ? widget.value.abbr : '-',
                        style: Theme.of(context).textTheme.subtitle,
                        maxLines: 1,
                      ))),
                  Icon(Icons.arrow_drop_down),
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

  void _showDialog() {
    setState(() {
      _isDialogOpen = true;
    });
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          if (_coinsList != null && _coinsList.isNotEmpty) {
            final List<SimpleDialogOption> coinsList = [];
            for (int i = 0; i < _coinsList.length; i++) {
              final CoinBalance coinBalance = _coinsList[i];

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
                      radius: 12,
                      tag:
                          'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      coinBalance.coin.abbr.toUpperCase(),
                      style: TextStyle(
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
                    ? Text('  /  ${widget.pairedCoin.abbr}')
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
                    ? Text('${widget.pairedCoin.abbr}  /  ')
                    : Container(),
              ),
              Opacity(
                opacity: _isOptionDisabled(coinBalance.coin) ? 0.4 : 1,
                child: Row(
                  children: <Widget>[
                    PhotoHero(
                      radius: 12,
                      tag:
                          'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                    ),
                    const SizedBox(width: 8),
                    Text(
                      coinBalance.coin.abbr.toUpperCase(),
                      style: TextStyle(
                        color: coinBalance.coin == widget.value
                            ? Theme.of(context).accentColor
                            : null,
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
                  radius: 14,
                  tag: 'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                ),
                const SizedBox(width: 12),
                Text(
                  coinBalance.coin.name.toUpperCase(),
                  style: TextStyle(
                    color: coinBalance.coin == widget.value
                        ? Theme.of(context).accentColor
                        : null,
                  ),
                ),
              ],
            ),
          );
        }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _optionTitle,
    );
  }
}

enum CoinType {
  base,
  rel,
}
