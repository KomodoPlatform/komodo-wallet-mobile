import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';

class BuildItemCoin extends StatefulWidget {
  const BuildItemCoin({Key key, this.coin}) : super(key: key);

  final Coin coin;

  @override
  _BuildItemCoinState createState() => _BuildItemCoinState();
}

class _BuildItemCoinState extends State<BuildItemCoin> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinToActivate>>(
        initialData: coinsBloc.coinBeforeActivation,
        stream: coinsBloc.outCoinBeforeActivation,
        builder: (context, snapshot) {
          final CoinToActivate coinToActivate = snapshot.data
              .firstWhere((item) => item.coin.abbr == widget.coin.abbr);

          return InkWell(
            onTap: () {
              coinsBloc.setCoinBeforeActivation(
                  widget.coin, !coinToActivate.isActive);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 50, right: 16),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 15,
                    width: 15,
                    color: coinToActivate.isActive
                        ? Theme.of(context).accentColor
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 24),
                  Image.asset(
                    'assets/${widget.coin.abbr.toLowerCase()}.png',
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 24),
                  Text('${widget.coin.name} (${widget.coin.abbr})')
                ],
              ),
            ),
          );
        });
  }
}
