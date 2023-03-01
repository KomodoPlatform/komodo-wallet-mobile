import 'package:flutter/material.dart';
import '../../../generic_blocs/coins_bloc.dart';
import '../../../model/coin.dart';
import '../../../utils/utils.dart';
import '../../../widgets/auto_scroll_text.dart';

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

          // todo(MRC): Optimize this to use CheckboxListTile in a future point in time
          return InkWell(
            onTap: () => coinsBloc.setCoinBeforeActivation(
                widget.coin, !coinToActivate.isActive),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, left: 50, right: 16),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: coinToActivate.isActive
                            ? Theme.of(context).toggleableActiveColor
                            : Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                  ),
                  const SizedBox(width: 24),
                  Image.asset(
                    getCoinIconPath(widget.coin.abbr),
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: AutoScrollText(
                      text: '${widget.coin.name} (${widget.coin.abbr})',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
