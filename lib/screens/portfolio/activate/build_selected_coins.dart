import 'package:flutter/material.dart';
import '../../../generic_blocs/coins_bloc.dart';
import '../../../utils/utils.dart';

class BuildSelectedCoins extends StatelessWidget {
  final List<CoinToActivate> coins;

  const BuildSelectedCoins(this.coins);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      centerTitle: false,
      toolbarHeight: 40,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: SingleChildScrollView(
          key: Key('selected-coins-preview'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: coins
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Chip(
                      key: Key('selected-chip-${e.coin!.abbr}'),
                      backgroundColor: Theme.of(context).toggleableActiveColor,
                      avatar: Image.asset(
                        getCoinIconPath(e.coin!.abbr),
                        height: 20,
                        width: 20,
                      ),
                      label: Text(
                        e.coin!.name!,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      deleteIcon: Icon(Icons.cancel),
                      onDeleted: () {
                        coinsBloc.setCoinBeforeActivation(e.coin, false);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      leadingWidth: 0,
      leading: SizedBox(),
      titleSpacing: 0,
    );
  }
}
