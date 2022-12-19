import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../blocs/main_bloc.dart';
import '../../../../blocs/settings_bloc.dart';
import '../../../../blocs/swap_bloc.dart';
import '../../../../blocs/swap_history_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/balance.dart';
import '../../../../model/cex_provider.dart';
import '../../../../model/coin.dart';
import '../../../../model/coin_balance.dart';
import '../../../../model/rewards_provider.dart';
import '../portfolio/faucet_dialog.dart';
import '../../../../utils/log.dart';
import '../../../app_config/app_config.dart';
import '../../utils/utils.dart';
import '../../../../widgets/build_protocol_chip.dart';
import '../../../../widgets/build_red_dot.dart';
import 'package:provider/provider.dart';

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
        onPressed: (context) async {
          await Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => CoinDetail(
                      coinBalance: widget.coinBalance,
                      isSendIsActive: true,
                    )),
          );
          cexProvider.withdrawCurrency = null;
          setState(() {});
        },
      ));
    }
    actions.add(SlidableAction(
      label: AppLocalizations.of(context).receive,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      icon: Icons.arrow_downward,
      onPressed: (mContext) {
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

    return Opacity(
      opacity: coin.suspended ? 0.3 : 1,
      child: Slidable(
        startActionPane: coin.suspended
            ? null
            : ActionPane(
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
              key: Key('disable-coin'),
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
            onLongPress: () => Slidable.of(context).openStartActionPane(),
            onTap: () async {
              //if (coin.suspended) {
              //showSuspendedDilog(context, coin: coin);
              //return;
              //}

              final slidableController = Slidable.of(context);
              if (slidableController != null) {
                slidableController.close();
              }
              await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) =>
                      CoinDetail(coinBalance: widget.coinBalance),
                ),
              );
              cexProvider.withdrawCurrency = null;
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage(getCoinIconPath(balance.coin)),
                            ),
                            if (coin.suspended)
                              Icon(
                                Icons.warning_rounded,
                                size: 20,
                                color: Colors.yellow[600],
                              ),
                          ],
                          alignment: Alignment.bottomRight,
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
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 8, bottom: 8, right: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          StreamBuilder<bool>(
                              initialData: settingsBloc.showBalance,
                              stream: settingsBloc.outShowBalance,
                              builder: (BuildContext context,
                                  AsyncSnapshot<bool> snapshot) {
                                String amount = f
                                    .format(double.parse(balance.getBalance()));
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildFaucetButton(),
                              _buildWalletOnly(),
                              _buildProtocolChip(coin),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClaimButton() {
    final bool needClaimButton = widget.coinBalance.coin.abbr == 'KMD' &&
        double.parse(widget.coinBalance.balance.getBalance()) >= 10;

    if (!needClaimButton) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        onPressed: !widget.coinBalance.coin.suspended
            ? () async {
                rewardsProvider.update();
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => RewardsPage()),
                );
              }
            : null,
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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!widget.coinBalance.coin.suspended && rewardsProvider.needClaim)
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
    return appConfig.defaultTestCoins.contains(widget.coinBalance.coin.abbr) ||
            widget.coinBalance.coin.abbr == 'ZOMBIE'
        ? Padding(
            padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            child: OutlinedButton(
              onPressed: !widget.coinBalance.coin.suspended
                  ? () async {
                      showFaucetDialog(
                          context: context,
                          coin: widget.coinBalance.coin.abbr,
                          address: widget.coinBalance.balance.address);
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 12),
                side:
                    BorderSide(color: Theme.of(context).colorScheme.secondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(AppLocalizations.of(context).faucetName),
            ),
          )
        : SizedBox();
  }

  Widget _buildProtocolChip(Coin coin) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: BuildProtocolChip(coin),
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
