import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/portfolio/coin_detail/coin_detail.dart';
import 'package:komodo_dex/screens/portfolio/select_coins_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/widgets/photo_widget.dart';

class CoinsPage extends StatefulWidget {
  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  ScrollController _scrollController;
  double _heightFactor = 7;
  BuildContext contextMain;
  NumberFormat f = NumberFormat('###,##0.0#');
  double _heightScreen;
  double _heightSliver;
  double _widthScreen;

  void _scrollListener() {
    setState(() {
      _heightFactor = (exp(-_scrollController.offset / 60) * 6) + 1;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    if (mmSe.running) coinsBloc.updateCoinBalances();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _heightScreen = MediaQuery.of(context).size.height;
    _widthScreen = MediaQuery.of(context).size.width;
    _heightSliver = _heightScreen * 0.25;
    if (_heightSliver < 125) _heightSliver = 125;

    return Scaffold(
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  expandedHeight: _heightSliver,
                  pinned: true,
                  flexibleSpace: Builder(
                    builder: (BuildContext context) {
                      return FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          centerTitle: true,
                          title: Container(
                            padding: const EdgeInsets.only(top: 35),
                            width: _widthScreen * 0.5,
                            child: Center(
                              heightFactor: _heightFactor,
                              child: StreamBuilder<List<CoinBalance>>(
                                  initialData: coinsBloc.coinBalance,
                                  stream: coinsBloc.outCoins,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<CoinBalance>>
                                          snapshot) {
                                    if (snapshot.data != null) {
                                      double totalBalanceUSD = 0;

                                      for (CoinBalance coinBalance
                                          in snapshot.data) {
                                        totalBalanceUSD +=
                                            coinBalance.balanceUSD;
                                      }
                                      return AutoSizeText(
                                        '\$${f.format(totalBalanceUSD)} USD',
                                        maxFontSize: 18,
                                        minFontSize: 12,
                                        style:
                                            Theme.of(context).textTheme.title,
                                        maxLines: 1,
                                      );
                                    } else {
                                      return Center(
                                          child: Container(
                                        child:
                                            const CircularProgressIndicator(),
                                      ));
                                    }
                                  }),
                            ),
                          ),
                          background: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const LoadAsset(),
                                  const SizedBox(
                                    height: 14.0,
                                  ),
                                  BarGraph()
                                ],
                              ),
                            ),
                            height: _heightScreen * 0.35,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              stops: const <double>[0.01, 1],
                              colors: <Color>[
                                const Color.fromRGBO(39, 71, 110, 1),
                                Theme.of(context).accentColor,
                              ],
                            )),
                          ));
                    },
                  ),
                ),
              ];
            },
            body: Container(
                color: Theme.of(context).backgroundColor,
                child: const ListCoins())));
  }
}

class BarGraph extends StatefulWidget {
  @override
  BarGraphState createState() {
    return BarGraphState();
  }
}

class BarGraphState extends State<BarGraph> {
  @override
  Widget build(BuildContext context) {
    final double _widthScreen = MediaQuery.of(context).size.width;
    final double _widthBar = _widthScreen - 32;

    return StreamBuilder<List<CoinBalance>>(
      initialData: coinsBloc.coinBalance,
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        final bool _isVisible = snapshot.data != null;
        final List<Container> barItem = <Container>[];

        if (snapshot.data != null) {
          double sumOfAllBalances = 0;

          for (CoinBalance coinBalance in snapshot.data) {
            sumOfAllBalances += coinBalance.balanceUSD;
          }

          for (CoinBalance coinBalance in snapshot.data) {
            if (coinBalance.balanceUSD > 0) {
              barItem.add(Container(
                color: Color(int.parse(coinBalance.coin.colorCoin)),
                width: _widthBar *
                    (((coinBalance.balanceUSD * 100) / sumOfAllBalances) / 100),
              ));
            }
          }
        }

        return AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Container(
              width: _widthBar,
              height: 16,
              child: Row(
                children: barItem,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoadAsset extends StatefulWidget {
  const LoadAsset({
    Key key,
  }) : super(key: key);

  @override
  LoadAssetState createState() {
    return LoadAssetState();
  }
}

class LoadAssetState extends State<LoadAsset> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      initialData: coinsBloc.coinBalance,
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        final List<Widget> listRet = <Widget>[];
        if (snapshot.data != null) {
          int assetNumber = 0;

          for (CoinBalance coinBalance in snapshot.data) {
            if (double.parse(coinBalance.balance.getBalance()) > 0) {
              assetNumber++;
            }
          }

          listRet.add(Icon(
            Icons.show_chart,
            color: Colors.white.withOpacity(0.8),
          ));
          listRet.add(Text(
            AppLocalizations.of(context).numberAssets(assetNumber.toString()),
            style: Theme.of(context).textTheme.caption,
          ));
          listRet.add(Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.8),
          ));
        } else {
          listRet.add(Container(
              height: 10,
              width: 10,
              child: const CircularProgressIndicator(
                strokeWidth: 1.0,
              )));
        }
        return Container(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: listRet,
          ),
        );
      },
    );
  }
}

class ListCoins extends StatefulWidget {
  const ListCoins({
    Key key,
  }) : super(key: key);

  @override
  ListCoinsState createState() {
    return ListCoinsState();
  }
}

class ListCoinsState extends State<ListCoins> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final SlidableController slidableController = SlidableController();

  @override
  void initState() {
    if (mmSe.running) coinsBloc.updateCoinBalances();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CoinBalance>>(
      initialData: coinsBloc.coinBalance,
      stream: coinsBloc.outCoins,
      builder:
          (BuildContext context, AsyncSnapshot<List<CoinBalance>> snapshot) {
        return RefreshIndicator(
            backgroundColor: Theme.of(context).backgroundColor,
            key: _refreshIndicatorKey,
            onRefresh: () => coinsBloc.updateCoinBalances(),
            child: Builder(builder: (BuildContext context) {
              if (snapshot.data != null && snapshot.data.isNotEmpty) {
                final List<dynamic> datas = <dynamic>[];

                final List<CoinBalance> _sorted =
                    coinsBloc.sortCoins(snapshot.data);

                datas.addAll(_sorted);
                datas.add(true);
                return ListView.builder(
                  key: const Key('list-view-coins'),
                  itemCount: datas.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (BuildContext context, int index) {
                    if (datas[index] is bool) {
                      return const AddCoinButton(key: Key('add-coin'));
                    } else {
                      return ItemCoin(
                        key: Key('coin-list-${datas[index].coin.abbr}'),
                        mContext: context,
                        coinBalance: datas[index],
                        slidableController: slidableController,
                      );
                    }
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingCoin();
              } else if (snapshot.data.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    AddCoinButton(),
                    Text('Please Add A Coin'),
                  ],
                );
              } else {
                return Container();
              }
            }));
      },
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
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
        showAddressDialog(context, balance.address, coin);
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
                await showConfirmationRemoveCoin(context, coin);
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
                          Builder(builder: (BuildContext context) {
                            return PhotoHero(
                              radius: 28,
                              tag: 'assets/${balance.coin.toLowerCase()}.png',
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            coin.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle
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
                            child: AutoSizeText(
                              '${f.format(double.parse(balance.getBalance()))} ${coin.abbr}',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.subtitle,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Builder(builder: (BuildContext context) {
                            final NumberFormat f = NumberFormat('###,##0.##');
                            return Text(
                              '\$${f.format(widget.coinBalance.balanceUSD)} USD',
                              style: Theme.of(context).textTheme.body2,
                            );
                          }),
                          widget.coinBalance.coin.abbr == 'KMD' &&
                                  double.parse(widget.coinBalance.balance
                                          .getBalance()) >=
                                      10
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: OutlineButton(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).accentColor),
                                    highlightedBorderColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    onPressed: () {
                                      CoinDetail(
                                              coinBalance: widget.coinBalance)
                                          .showDialogClaim(context);
                                    },
                                    child: Text(
                                      'CLAIM YOUR REWARDS',
                                      style: Theme.of(context)
                                          .textTheme
                                          .body1
                                          .copyWith(fontSize: 12),
                                    ),
                                  ),
                                )
                              : Container(),
                          (widget.coinBalance.coin.type == 'erc' ||
                                      widget.coinBalance.coin.type ==
                                          'smartChain') &&
                                  widget.coinBalance.coin.abbr != 'KMD' &&
                                  widget.coinBalance.coin.abbr != 'ETH'
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                    child: Container(
                                        color: widget.coinBalance.coin.type ==
                                                'erc'
                                            ? const Color.fromRGBO(
                                                20, 117, 186, 1)
                                            : Theme.of(context).backgroundColor,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          child: widget.coinBalance.coin.type ==
                                                  'erc'
                                              ? Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .tagERC20,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      'assets/kmd.png',
                                                      width: 18,
                                                      height: 18,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .tagKMD,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                  ],
                                                ),
                                        )),
                                  ),
                                )
                              : Container()
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
}

class AddCoinButton extends StatefulWidget {
  const AddCoinButton({Key key}) : super(key: key);

  @override
  _AddCoinButtonState createState() => _AddCoinButtonState();
}

class _AddCoinButtonState extends State<AddCoinButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StreamBuilder<CoinToActivate>(
            initialData: coinsBloc.currentActiveCoin,
            stream: coinsBloc.outcurrentActiveCoin,
            builder:
                (BuildContext context, AsyncSnapshot<CoinToActivate> snapshot) {
              if (snapshot.data != null) {
                return Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 16,
                    ),
                    const CircularProgressIndicator(),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(snapshot.data.currentStatus ?? AppLocalizations.of(context).connecting),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                );
              } else {
                return FutureBuilder<bool>(
                  future: _buildAddCoinButton(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.data != null && snapshot.data) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                              child: FloatingActionButton(
                            key: const Key('adding-coins'),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).accentColor,
                            child: Icon(
                              Icons.add,
                            ),
                            onPressed: () {
                              if (mainBloc.isNetworkOffline) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Theme.of(context).errorColor,
                                  content: Text(
                                      AppLocalizations.of(context).noInternet),
                                ));
                              } else {
                                Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          const SelectCoinsPage()),
                                );
                              }
                            },
                          )),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }
            }),
      ],
    );
  }

  /// Returns `true` if there are coins we can still activate, `false` if all of them activated.
  Future<bool> _buildAddCoinButton() async {
    final active = await Db.activeCoins;
    final known = await coins;
    return active.length < known.length;
  }
}
