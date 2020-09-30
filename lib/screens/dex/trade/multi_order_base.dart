import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class MultiOrderBase extends StatefulWidget {
  @override
  _MultiOrderBaseState createState() => _MultiOrderBaseState();
}

class _MultiOrderBaseState extends State<MultiOrderBase> {
  MultiOrderProvider multiOrderProvider;
  CoinBalance baseCoin;
  List<CoinBalance> coins = coinsBloc.coinBalance;
  bool isDialogOpen = false;

  @override
  void initState() {
    coinsBloc.outCoins.listen((data) {
      if (coins == data) return;

      setState(() {
        coins = data;
      });
      if (isDialogOpen) {
        dialogBloc.closeDialog(context);
        _showCoinSelectDialog();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    multiOrderProvider ??= Provider.of<MultiOrderProvider>(context);
    baseCoin = multiOrderProvider.baseCoin;

    return Container(
      width: double.infinity,
      child: Card(
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                child: Text(
                  'Sell:',
                  style: Theme.of(context).textTheme.body2,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(flex: 5, child: _buildCoinSelect()),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: _buildCoinAmount()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinSelect() {
    return InkWell(
      onTap: () {
        _showCoinSelectDialog();
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Theme.of(context).highlightColor,
        ))),
        child: Opacity(
          opacity: baseCoin == null ? 0.3 : 1,
          child: Row(
            children: <Widget>[
              CircleAvatar(
                maxRadius: 12,
                backgroundColor:
                    baseCoin == null ? Theme.of(context).accentColor : null,
                backgroundImage: baseCoin == null
                    ? null
                    : AssetImage(
                        'assets/${baseCoin.coin.abbr.toLowerCase()}.png'),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  baseCoin?.coin?.abbr ?? 'Coin', // TODO(yurii): localization
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoinSelectDialog() {
    dialogBloc.dialog = showDialog(
        context: context,
        builder: (context) {
          if (coins == null)
            return const Center(
              child: CircularProgressIndicator(),
            );

          final List<CoinBalance> availableForSell =
              coins.where((CoinBalance coin) {
            return coin.balance.balance.toDouble() > 0;
          }).toList();

          if (availableForSell.isEmpty) {
            return _buildNoFundsAlert();
          }

          return SimpleDialog(
            // TODO(yurii): localization
            title: const Text('Sell'),
            children: coinsBloc
                .sortCoins(availableForSell)
                .map<Widget>((CoinBalance item) {
              return InkWell(
                onTap: () {
                  multiOrderProvider.baseCoin = item;
                  dialogBloc.closeDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        maxRadius: 12,
                        backgroundImage: AssetImage(
                            'assets/${item.coin.abbr.toLowerCase()}.png'),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.coin.abbr, // TODO(yurii): localization
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Text(item.balance.balance.toString()),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        });
  }

  Widget _buildNoFundsAlert() {
    return SimpleDialog(
      title: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 48,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(AppLocalizations.of(context).noFunds,
              style: Theme.of(context).textTheme.title),
        ],
      ),
      contentPadding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(AppLocalizations.of(context).noFundsDetected,
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(
          height: 24,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: AppLocalizations.of(context).goToPorfolio,
                onPressed: () {
                  Navigator.of(context).pop();
                  mainBloc.setCurrentIndexTab(0);
                },
                backgroundColor: Theme.of(context).accentColor,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCoinAmount() {
    return Opacity(
      opacity: baseCoin == null ? 0.3 : 1,
      child: InkWell(
        onTap: baseCoin == null
            ? null
            : () {
                // TODO: show max volume info dialog
              },
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Text(
            // TODO: calculate actual max available balance
            baseCoin == null ? 'Amount' : baseCoin.balance.balance.toString(),
            style: Theme.of(context).textTheme.subtitle,
          ),
        ),
      ),
    );
  }
}
