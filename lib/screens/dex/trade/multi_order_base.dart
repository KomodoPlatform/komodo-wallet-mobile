import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/multi_order_provider.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/theme_data.dart';
import 'package:provider/provider.dart';

class MultiOrderBase extends StatefulWidget {
  @override
  _MultiOrderBaseState createState() => _MultiOrderBaseState();
}

class _MultiOrderBaseState extends State<MultiOrderBase> {
  MultiOrderProvider multiOrderProvider;
  CexProvider cexProvider;
  String baseCoin;
  List<CoinBalance> coins = coinsBloc.coinBalance;
  bool isDialogOpen = false;
  bool showDetailedFees = false;

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
    cexProvider ??= Provider.of<CexProvider>(context);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 5, child: _buildCoinSelect()),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: _buildSellAmount()),
                ],
              ),
              _buildFees(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFees() {
    return FutureBuilder(
      future: multiOrderProvider.getTxFee(),
      builder: (context, snapshot) {
        final double tradeFee = multiOrderProvider.getTradeFee();
        if (!snapshot.hasData ||
            snapshot.data == 0 ||
            tradeFee == null ||
            tradeFee == 0) return const SizedBox();

        return GestureDetector(
          onTap: () {
            setState(() {
              showDetailedFees = !showDetailedFees;
            });
          },
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).txFeeTitle,
                              style: Theme.of(context).textTheme.caption),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${cutTrailingZeros(formatPrice(snapshot.data))} ${multiOrderProvider.baseCoin}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              if (showDetailedFees)
                                Text(
                                  cexProvider.convert(
                                    snapshot.data,
                                    from: multiOrderProvider.baseCoin,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: cexColor),
                                ),
                            ],
                          )),
                        ],
                      ),
                      if (showDetailedFees) const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Text(AppLocalizations.of(context).tradingFee,
                              style: Theme.of(context).textTheme.caption),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${cutTrailingZeros(formatPrice(multiOrderProvider.getTradeFee()))} ${multiOrderProvider.baseCoin}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                              if (showDetailedFees)
                                Text(
                                  cexProvider.convert(
                                    multiOrderProvider.getTradeFee(),
                                    from: multiOrderProvider.baseCoin,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: cexColor),
                                ),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    showDetailedFees ? Icons.unfold_less : Icons.unfold_more,
                    color: Theme.of(context).textTheme.caption.color,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                    : AssetImage('assets/${baseCoin.toLowerCase()}.png'),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  baseCoin ?? 'Coin', // TODO(yurii): localization
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
                  multiOrderProvider.baseCoin = item.coin.abbr;
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
                      Text(
                        item.coin.abbr, // TODO(yurii): localization
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      Expanded(
                          child: Text(
                        cutTrailingZeros(
                            formatPrice(item.balance.balance.toDouble(), 8)),
                        textAlign: TextAlign.right,
                      )),
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

  Widget _buildSellAmount() {
    final double usdPrice =
        cexProvider.getUsdPrice(multiOrderProvider?.baseCoin) ?? 0;
    final double usdAmt = (multiOrderProvider?.baseAmt ?? 0) * usdPrice;
    final String convertedAmt = usdAmt > 0 ? cexProvider.convert(usdAmt) : null;

    return Opacity(
      opacity: baseCoin == null ? 0.3 : 1,
      child: InkWell(
        onTap: baseCoin == null
            ? null
            : () {
                // TODO: show max volume info dialog
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 7),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1, color: Theme.of(context).highlightColor))),
              child: Text(
                multiOrderProvider.baseAmt == null
                    ? 'Amount'
                    : '${formatPrice(multiOrderProvider.baseAmt, 8)} ',
                style: Theme.of(context).textTheme.subtitle,
                textAlign: TextAlign.right,
                maxLines: 1,
              ),
            ),
            if (convertedAmt != null)
              Text(
                convertedAmt,
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: cexColor),
              ),
          ],
        ),
      ),
    );
  }
}
