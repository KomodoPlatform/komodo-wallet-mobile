import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:komodo_dex/widgets/buildRedDot.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/utils/log.dart';
import 'coin_detail/coin_detail.dart';
import 'receive_dialog.dart';
import 'rewards_page.dart';

class ItemCoin extends StatefulWidget {
  const ItemCoin(
      {Key key,
      @required this.mContext,
      this.coinBalance,
      this.slidableController})
      : super(key: key);

  final CoinBalance coinBalance;
  final BuildContext mContext;
  final SlidableController slidableController;

  @override
  _ItemCoinState createState() => _ItemCoinState();
}

class _ItemCoinState extends State<ItemCoin> {
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
      actions.add(IconSlideAction(
        caption: AppLocalizations.of(context).send,
        color: Colors.white,
        icon: Icons.arrow_upward,
        onTap: () {
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
    actions.add(IconSlideAction(
      caption: AppLocalizations.of(context).receive,
      color: Theme.of(context).backgroundColor,
      icon: Icons.arrow_downward,
      onTap: () {
        showReceiveDialog(context, balance.address, coin);
      },
    ));
    if (double.parse(balance.getBalance()) > 0) {
      actions.add(IconSlideAction(
        caption: AppLocalizations.of(context).swap.toUpperCase(),
        color: Theme.of(context).accentColor,
        icon: Icons.swap_vert,
        onTap: () {
          mainBloc.setCurrentIndexTab(1);
          swapHistoryBloc.isSwapsOnGoing = false;
          Future<dynamic>.delayed(const Duration(milliseconds: 100), () {
            swapBloc.updateSellCoin(widget.coinBalance);
            swapBloc.setFocusTextField(true);
            swapBloc.setEnabledSellField(true);
          });
        },
      ));
    }

    return Column(
      children: <Widget>[
        Slidable(
          controller: widget.slidableController,
          actionPane: const SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          actions: actions,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: AppLocalizations.of(context).remove.toUpperCase(),
              color: Theme.of(context).errorColor,
              icon: Icons.delete,
              onTap: () async {
                final abbr = widget.coinBalance.coin.abbr;
                if (abbr == 'BTC' || abbr == 'KMD') {
                  showDialog<dynamic>(
                    context: context,
                    builder: (contex) => AlertDialog(
                      title: Text("Can't disable"),
                      content: Text(
                        'At least two coins must stay enabled at all times, so de-activating KMD or BTC is forbidden',
                      ),
                      actions: [
                        FlatButton(
                          child: Text('Ok'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  await showConfirmationRemoveCoin(context, coin);
                }
              },
            )
          ],
          child: Builder(builder: (BuildContext context) {
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              onLongPress: () {
                Slidable.of(context).open(actionType: SlideActionType.primary);
              },
              onTap: () {
                if (widget.slidableController != null &&
                    widget.slidableController.activeState != null) {
                  widget.slidableController.activeState.close();
                }
                Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) =>
                          CoinDetail(coinBalance: widget.coinBalance)),
                );
              },
              child: Container(
                height: 125,
                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    Container(
                      color: Color(int.parse(coin.colorCoin)),
                      width: 8,
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 110,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(
                                'assets/${balance.coin.toLowerCase()}.png'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            coin.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
                                .copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const SizedBox(
                            height: 4,
                          ),
                          Container(
                            child: StreamBuilder<bool>(
                                initialData: settingsBloc.showBalance,
                                stream: settingsBloc.outShowBalance,
                                builder: (BuildContext context,
                                    AsyncSnapshot<bool> snapshot) {
                                  String amount = f.format(
                                      double.parse(balance.getBalance()));
                                  if (snapshot.hasData && !snapshot.data)
                                    amount = '**.**';
                                  return AutoSizeText(
                                    '$amount ${coin.abbr}',
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  );
                                }),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
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
                                  style: Theme.of(context).textTheme.bodyText1,
                                );
                              }),
                          _buildClaimButton(),
                          Row(
                            children: <Widget>[
                              _buildFaucetButton(),
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
        ),
        const Divider(
          height: 0,
        ),
      ],
    );
  }

  Widget _buildClaimButton() {
    final bool needClaimButton = widget.coinBalance.coin.abbr == 'KMD' &&
        double.parse(widget.coinBalance.balance.getBalance()) >= 10;

    if (!needClaimButton) return Container();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlineButton(
        borderSide: BorderSide(color: Theme.of(context).accentColor),
        highlightedBorderColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        onPressed: () async {
          rewardsProvider.update();
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => RewardsPage()),
          );
        },
        child: Row(
          children: <Widget>[
            if (rewardsProvider.needClaim)
              Container(
                padding: const EdgeInsets.only(right: 4),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 10,
                      height: 10,
                    ),
                    buildRedDot(context)
                  ],
                ),
              ),
            Text(
              AppLocalizations.of(context).rewardsButton.toUpperCase(),
              style:
                  Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFaucetButton() {
    if (widget.coinBalance.coin.abbr == 'RICK' ||
        widget.coinBalance.coin.abbr == 'MORTY') {
      return Padding(
        padding: const EdgeInsets.only(
          top: 12,
          right: 8,
        ),
        child: OutlineButton(
          borderSide: BorderSide(color: Theme.of(context).accentColor),
          highlightedBorderColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          onPressed: () async {
            showFaucetDialog(
                context: context,
                coin: widget.coinBalance.coin.abbr,
                address: widget.coinBalance.balance.address);
          },
          child: Text(
            AppLocalizations.of(context).faucetName,
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildNetworkLabel() {
    final bool needLabel = (widget.coinBalance.coin.type == 'erc' ||
            widget.coinBalance.coin.type == 'qrc' ||
            widget.coinBalance.coin.type == 'smartChain') &&
        widget.coinBalance.coin.abbr != 'KMD' &&
        widget.coinBalance.coin.abbr != 'ETH' &&
        widget.coinBalance.coin.abbr != 'QTUM';

    if (!needLabel) return Container();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Container(
            color: widget.coinBalance.coin.type == 'erc' ||
                    widget.coinBalance.coin.type == 'qrc'
                ? const Color.fromRGBO(20, 117, 186, 1)
                : Theme.of(context).backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Builder(builder: (context) {
                switch (widget.coinBalance.coin.type) {
                  case 'erc':
                    {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).tagERC20,
                            style: Theme.of(context).textTheme.subtitle2,
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
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      );
                    }
                  default:
                    {
                      return InkWell(
                        onTap: () {
                          ScaffoldState scaffold;
                          try {
                            scaffold = Scaffold.of(context);
                          } catch (_) {}

                          if (scaffold != null) {
                            scaffold.showSnackBar(const SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('Built on Komodo'),
                            ));
                          }
                        },
                        child: Image.asset(
                          'assets/kmd.png',
                          width: 18,
                          height: 18,
                        ),
                      );
                    }
                }
              }),
            )),
      ),
    );
  }
}
