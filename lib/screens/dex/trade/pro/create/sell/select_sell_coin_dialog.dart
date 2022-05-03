import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';

void openSelectSellCoinDialog({
  BuildContext context,
  Function(CoinBalance) onDone,
}) {
  final List<SimpleDialogOption> coinItemsList =
      _coinItemsList(context: context, onSelected: onDone);

  dialogBloc.dialog = showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return coinItemsList.isNotEmpty
            ? CustomSimpleDialog(
                hasHorizontalPadding: false,
                title: Text(AppLocalizations.of(context).sell),
                children: coinItemsList,
              )
            : CustomSimpleDialog(
                title: Column(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      size: 48,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(AppLocalizations.of(context).noFunds,
                        style: Theme.of(context).textTheme.headline6),
                    const SizedBox(
                      height: 16,
                    )
                  ],
                ),
                children: <Widget>[
                  Text(AppLocalizations.of(context).noFundsDetected,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          mainBloc.setCurrentIndexTab(0);
                        },
                        child: Text(AppLocalizations.of(context).goToPorfolio),
                      )
                    ],
                  ),
                ],
              );
      }).then((dynamic _) => dialogBloc.dialog = null);
}

List<SimpleDialogOption> _coinItemsList({
  BuildContext context,
  Function(CoinBalance) onSelected,
}) {
  final List<SimpleDialogOption> listDialog = <SimpleDialogOption>[];
  for (CoinBalance coin in coinsBloc.coinBalance) {
    if (!coin.coin.walletOnly && double.parse(coin.balance.getBalance()) > 0) {
      final SimpleDialogOption dialogItem = SimpleDialogOption(
        key: Key('item-dialog-${coin.coin.abbr.toLowerCase()}-sell'),
        onPressed: () {
          onSelected(coin);

          Navigator.pop(context);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                height: 30,
                width: 30,
                child: Image.asset(
                  'assets/coin-icons/${abbr2Ticker(coin.coin.abbr.toLowerCase())}.png',
                )),
            Expanded(child: SizedBox()),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                StreamBuilder<bool>(
                    initialData: settingsBloc.showBalance,
                    stream: settingsBloc.outShowBalance,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      String amount = coin.balance.getBalance();
                      if (snapshot.hasData && snapshot.data == false) {
                        amount = '**.**';
                      }
                      return Text(amount);
                    }),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  coin.coin.abbr,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            )
          ],
        ),
      );
      listDialog.add(dialogItem);
    }
  }
  return listDialog;
}
