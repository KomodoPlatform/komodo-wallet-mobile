import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';

class CoinSelect extends StatefulWidget {
  const CoinSelect({this.value, this.disabledOption, this.onChange});

  final Coin value;
  final Coin disabledOption;
  final Function(Coin) onChange;

  @override
  _CoinSelectState createState() => _CoinSelectState();
}

class _CoinSelectState extends State<CoinSelect> {
  List<CoinBalance> _balanceList;
  Coin _selected;

  @override
  void initState() {
    super.initState();

    _selected = widget.value;

    coinsBloc.outCoins.listen((List<CoinBalance> list) {
      setState(() {
        _balanceList = list;
      });
    });

    if (MMService().running) {
      coinsBloc.loadCoin();
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
                  _selected != null
                      ? Image.asset(
                          'assets/${_selected.abbr.toLowerCase()}.png',
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
                        _selected != null ? _selected.abbr : '-',
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

  void _showDialog() {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          if (_balanceList != null && _balanceList.isNotEmpty) {
            final List<SimpleDialogOption> coinsList = [];
            for (int i = 0; i < _balanceList.length; i++) {
              final CoinBalance coinBalance = _balanceList[i];

              coinsList.add(SimpleDialogOption(
                key: Key('coin-select-option-${coinBalance.coin.abbr}'),
                onPressed: coinBalance.coin == widget.disabledOption
                    ? null
                    : () {
                        dialogBloc.closeDialog(context);
                        setState(() {
                          _selected = coinBalance.coin;
                        });
                        if (widget.onChange != null) {
                          widget.onChange(coinBalance.coin);
                        }
                      },
                child: Opacity(
                  opacity: coinBalance.coin == widget.disabledOption ? 0.4 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: <Widget>[
                        PhotoHero(
                          radius: 14,
                          tag:
                              'assets/${coinBalance.balance.coin.toLowerCase()}.png',
                        ),
                        const SizedBox(width: 12),
                        Text(coinBalance.coin.name.toUpperCase()),
                      ],
                    ),
                  ),
                ),
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
}
