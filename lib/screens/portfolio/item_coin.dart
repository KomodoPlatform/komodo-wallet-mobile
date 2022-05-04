import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/screens/portfolio/faucet_dialog.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/rewards_provider.dart';
import 'package:komodo_dex/widgets/build_red_dot.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/utils/log.dart';
import 'coin_detail/coin_detail.dart';
import 'copy_dialog.dart';
import 'rewards_page.dart';

class ItemCoin extends StatefulWidget {
  const ItemCoin({
    Key key,
    @required this.mContext,
    this.coinBalance,
  }) : super(key: key);

  final CoinBalance coinBalance;
  final BuildContext mContext;

  @override
  _ItemCoinState createState() => _ItemCoinState();
}

class _ItemCoinState extends State<ItemCoin>
    with SingleTickerProviderStateMixin {
  RewardsProvider rewardsProvider;

  @override
  Widget build(BuildContext context) {
    final CexProvider cexProvider = Provider.of<CexProvider>(context);
    rewardsProvider ??= Provider.of<RewardsProvider>(context);
    final Coin coin = widget.coinBalance.coin;
    final Balance balance = widget.coinBalance.balance;
    final NumberFormat f = NumberFormat('###,##0.########');
    final List<Widget> actions = <Widget>[];
    if (double.parse(balance.getBalance()) > 0) {
      Log(
          'coins_page:379',
          '${coin.abbr} balance: ${balance.balance}'
              '; locked_by_swaps: ${balance.lockedBySwaps}');
      actions.add(SlidableAction(
        label: AppLocalizations.of(context).send,
        backgroundColor: Colors.white,
        icon: Icons.arrow_upward,
        onPressed: (context) {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => CoinDetail(
                      coinBalance: widget.coinBalance,
                      isSendIsActive: true,
                    )),
          );
        },
      ));
    }
    actions.add(SlidableAction(
      label: AppLocalizations.of(context).receive,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      icon: Icons.arrow_downward,
      onPressed: (context) {
        showCopyDialog(context, balance.address, coin);
      },
    ));
    if (!coin.walletOnly && double.parse(balance.getBalance()) > 0) {
      actions.add(SlidableAction(
        label: AppLocalizations.of(context).swap.toUpperCase(),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        icon: Icons.swap_vert,
        onPressed: (context) {
          mainBloc.setCurrentIndexTab(1);
          swapHistoryBloc.isSwapsOnGoing = false;
          Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
            swapBloc.updateSellCoin(widget.coinBalance);
            swapBloc.setEnabledSellField(true);
          });
        },
      ));
    }

    return Slidable(
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: (actions != null && actions.isNotEmpty)
            ? (actions.length * 0.3).clamp(0.3, 1.0)
            : null,
        children: actions,
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            label: AppLocalizations.of(context).remove.toUpperCase(),
            backgroundColor: Theme.of(context).errorColor,
            icon: Icons.delete,
            onPressed: (context) async {
              if (coin.isDefault) {
                await showCantRemoveDefaultCoin(context, coin);
              } else {
                await showConfirmationRemoveCoin(context, coin);
              }
            },
          ),
        ],
      ),
      child: Builder(builder: (BuildContext context) {
        return InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          onLongPress: () => Slidable.of(context).openCurrentActionPane(),
          onTap: () {
            final slidableController = Slidable.of(context);
            if (slidableController != null) {
              slidableController.close();
            }
            Navigator.push<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) =>
                    CoinDetail(coinBalance: widget.coinBalance),
              ),
            );
          },
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: <Widget>[
                Container(
                  height: 128,
                  color: Color(int.parse(coin.colorCoin)),
                  width: 8,
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage('assets/coin-icons/'
                            '${abbr2Ticker(balance.coin.toLowerCase())}.png'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        coin.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      StreamBuilder<bool>(
                          initialData: settingsBloc.showBalance,
                          stream: settingsBloc.outShowBalance,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            String amount =
                                f.format(double.parse(balance.getBalance()));
                            if (snapshot.hasData && !snapshot.data)
                              amount = '**.**';
                            return AutoSizeText(
                              '$amount ${coin.abbr}',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headline6,
                            );
                          }),
                      const SizedBox(height: 8),
                      StreamBuilder(
                          initialData: settingsBloc.showBalance,
                          stream: settingsBloc.outShowBalance,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            bool hidden = false;
                            if (snapshot.hasData && !snapshot.data)
                              hidden = true;
                            return Text(
                              cexProvider.convert(
                                widget.coinBalance.balanceUSD,
                                hidden: hidden,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    color: Colors.grey,
                                  ),
                            );
                          }),
                      _buildClaimButton(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildFaucetButton(),
                          _buildWalletOnly(),
                          _buildNetworkLabel(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClaimButton() {
    final bool needClaimButton = widget.coinBalance.coin.abbr == 'KMD' &&
        double.parse(widget.coinBalance.balance.getBalance()) >= 10;

    if (!needClaimButton) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        onPressed: () async {
          rewardsProvider.update();
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => RewardsPage()),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          textStyle:
              Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12),
          side: BorderSide(color: Theme.of(context).colorScheme.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            if (rewardsProvider.needClaim)
              Container(
                padding: const EdgeInsets.only(right: 4),
                child: Stack(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    buildRedDot(context)
                  ],
                ),
              ),
            Text(AppLocalizations.of(context).rewardsButton.toUpperCase())
          ],
        ),
      ),
    );
  }

  Widget _buildFaucetButton() {
    if (widget.coinBalance.coin.abbr == 'RICK' ||
        widget.coinBalance.coin.abbr == 'MORTY') {
      return Padding(
        padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
        child: OutlinedButton(
          onPressed: () async {
            showFaucetDialog(
                context: context,
                coin: widget.coinBalance.coin.abbr,
                address: widget.coinBalance.balance.address);
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            textStyle:
                Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12),
            side: BorderSide(color: Theme.of(context).colorScheme.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(AppLocalizations.of(context).faucetName),
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildNetworkLabel() {
    final bool needLabel =
        (appConfig.coinTypes.contains(widget.coinBalance.coin.type) ||
                widget.coinBalance.coin.type == 'qrc' ||
                widget.coinBalance.coin.type == 'smartChain') &&
            widget.coinBalance.coin.abbr != 'KMD' &&
            widget.coinBalance.coin.abbr != 'ETH' &&
            widget.coinBalance.coin.abbr != 'BNB' &&
            widget.coinBalance.coin.abbr != 'MATIC' &&
            widget.coinBalance.coin.abbr != 'FTM' &&
            widget.coinBalance.coin.abbr != 'QTUM';

    if (!needLabel) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: appConfig.coinTypes.contains(widget.coinBalance.coin.type) ||
                  widget.coinBalance.coin.type == 'qrc'
              ? const Color.fromRGBO(20, 117, 186, 1)
              : Theme.of(context).scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Builder(
          builder: (context) {
            switch (widget.coinBalance.coin.type) {
              case 'erc':
                {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).tagERC20,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  );
                }
              case 'bep':
                {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).tagBEP20,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  );
                }
              case 'plg':
                {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).tagPLG20,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  );
                }
              case 'ftm':
                {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).tagFTM20,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  );
                }
              case 'qrc':
                {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).tagQRC20,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  );
                }
              default:
                {
                  return InkWell(
                    onTap: () {
                      ScaffoldMessengerState scaffoldMessenger;
                      try {
                        scaffoldMessenger = ScaffoldMessenger.of(context);
                      } catch (_) {}

                      if (scaffoldMessenger != null) {
                        scaffoldMessenger.showSnackBar(const SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text('Built on Komodo'),
                        ));
                      }
                    },
                    child: Image.asset(
                      'assets/coin-icons/kmd.png',
                      width: 18,
                      height: 18,
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  Widget _buildWalletOnly() {
    if (!widget.coinBalance.coin.walletOnly) return SizedBox();

    return Padding(
      padding: EdgeInsets.only(top: 8, left: 4),
      child: InkWell(
          onTap: () {
            ScaffoldMessengerState scaffoldMessenger;
            try {
              scaffoldMessenger = ScaffoldMessenger.of(context);
            } catch (_) {}

            if (scaffoldMessenger != null) {
              scaffoldMessenger.showSnackBar(SnackBar(
                duration: Duration(seconds: 2),
                content: Text(AppLocalizations.of(context).dexIsNotAvailable),
              ));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              AppLocalizations.of(context).walletOnly.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(fontFamily: 'RobotoCondensed'),
            ),
          )),
    );
  }
}
