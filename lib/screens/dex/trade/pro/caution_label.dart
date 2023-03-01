import 'package:flutter/material.dart';
import 'package:komodo_dex/generic_blocs/coins_bloc.dart';
import 'package:komodo_dex/generic_blocs/swap_bloc.dart';

import '../../../../localizations.dart';

class CautionLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String _buyAbbr = swapBloc.receiveCoinBalance?.coin?.abbr;
    String _sellAbbr = swapBloc.sellCoinBalance?.coin?.abbr;
    List<String> coins = [];

    if (coinsBloc.coinsWithLessThan10kVol.contains(_buyAbbr)) {
      coins.add(_buyAbbr);
    }
    if (coinsBloc.coinsWithLessThan10kVol.contains(_sellAbbr)) {
      coins.add(_sellAbbr);
    }
    if (coins.isEmpty) return SizedBox();
    return Text(
      AppLocalizations.of(context).lessThanCaution(coins.join(',')),
      style: Theme.of(context).textTheme.subtitle2,
      textAlign: TextAlign.center,
    );
  }
}
