import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:komodo_dex/packages/rebranding/rebranding_provider.dart';
import 'add_coin_button.dart';
import 'package:komodo_dex/packages/rebranding/rebranding_dialog.dart';
import '../../../../blocs/coins_bloc.dart';
import '../../../../blocs/settings_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/cex_provider.dart';
import '../../../../model/coin_balance.dart';
import '../portfolio/loading_coin.dart';
import '../../../../services/mm_service.dart';
import 'package:provider/provider.dart';

import 'item_coin.dart';

class CoinsPage extends StatefulWidget {
  @override
  _CoinsPageState createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  CexProvider _cexProvider;
  ScrollController _scrollController;
  double _heightFactor = 2.3;
  BuildContext contextMain;
  NumberFormat f = NumberFormat('###,##0.0#');
  double _heightScreen;
  double _heightSliver;
  double _widthScreen;

  // Rebranding
  Future<void> showRebrandingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: true, // allow dismiss when clicking outside
      builder: (BuildContext context) => RebrandingDialog(),
    ).then((_) {
      // This is called when the dialog is dismissed
      Provider.of<RebrandingProvider>(context, listen: false)
          .closeThisSession();
    });
  }

  void _scrollListener() {
    setState(() {
      _heightFactor = (exp(-_scrollController.offset / 60) * 1.3) + 1;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    if (mmSe.running) coinsBloc.updateCoinBalances();

    // Schedule the dialog to show after the current frame
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final rebrandingNotifier =
          Provider.of<RebrandingProvider>(context, listen: false);

      // Wait for the prefs to load
      await rebrandingNotifier.prefsLoaded;

      if (!rebrandingNotifier.closedPermanently &&
          !rebrandingNotifier.closedThisSession) {
        showRebrandingDialog(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _cexProvider = Provider.of<CexProvider>(context);
    _heightScreen = MediaQuery.of(context).size.height;
    _widthScreen = MediaQuery.of(context).size.width;
    _heightSliver = _heightScreen * 0.25 - MediaQuery.of(context).padding.top;
    if (_heightSliver < 125) _heightSliver = 125;

    final bool isCollapsed = _scrollController.hasClients &&
        _scrollController.offset > _heightSliver;

    return Scaffold(
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  expandedHeight: 130,
                  pinned: true,
                  actions: [
                    AnimatedOpacity(
                      opacity: isCollapsed ? 1 : 0,
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeInOutExpo,
                      child: IgnorePointer(
                        ignoring: !isCollapsed,
                        child: AddCoinButton(
                          key: Key('add-coin-button-collapsed'),
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  flexibleSpace: Builder(
                    builder: (BuildContext context) {
                      return Stack(
                        children: <Widget>[
                          FlexibleSpaceBar(
                              collapseMode: CollapseMode.pin,
                              centerTitle: true,
                              titlePadding:
                                  EdgeInsetsDirectional.only(bottom: 4),
                              title: SizedBox(
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
                                          return StreamBuilder<bool>(
                                            initialData:
                                                settingsBloc.showBalance,
                                            stream: settingsBloc.outShowBalance,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<bool> snapshot) {
                                              bool hidden = false;
                                              if (snapshot.hasData &&
                                                  !snapshot.data) {
                                                hidden = true;
                                              }
                                              final String amountText =
                                                  _cexProvider.convert(
                                                totalBalanceUSD,
                                                hidden: hidden,
                                              );
                                              return TextButton(
                                                onPressed: () => _cexProvider
                                                    .switchCurrency(),
                                                style: TextButton.styleFrom(
                                                  primary: isCollapsed
                                                      ? Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.light
                                                          ? Colors.black
                                                              .withOpacity(0.8)
                                                          : Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.8),
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .headline6,
                                                ),
                                                child: AutoSizeText(
                                                  amountText,
                                                  maxFontSize: 18,
                                                  minFontSize: 12,
                                                  maxLines: 1,
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          return Center(
                                              child:
                                                  const CircularProgressIndicator());
                                        }
                                      }),
                                ),
                              ),
                              background: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const LoadAsset(),
                                      const SizedBox(
                                        height: 14.0,
                                      ),
                                      StreamBuilder<bool>(
                                          initialData: settingsBloc.showBalance,
                                          stream: settingsBloc.outShowBalance,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<bool> snapshot) {
                                            return snapshot.hasData &&
                                                    snapshot.data
                                                ? BarGraph()
                                                : SizedBox();
                                          })
                                    ],
                                  ),
                                ),
                                height: _heightScreen * 0.35,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  stops: const <double>[0.01, 1],
                                  colors: const <Color>[
                                    Color.fromRGBO(98, 90, 229, 1),
                                    Color.fromRGBO(45, 184, 240, 1),
                                  ],
                                )),
                              )),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _buildProgressIndicator(),
                          ),
                        ],
                      );
                    },
                  ),
                  automaticallyImplyLeading: false,
                ),
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  toolbarHeight: 48,
                  flexibleSpace: Center(
                    child: IntrinsicWidth(
                      // Child has infite width. We want to change so that it
                      // ignores the infinite width and takes up min width.
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AddCoinButton(key: Key('add-coin-button')),
                      ),
                    ),
                  ),
                  pinned: false,
                ),
              ];
            },
            body: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const ListCoins())));
  }

  Widget _buildProgressIndicator() {
    return StreamBuilder<CoinToActivate>(
        initialData: coinsBloc.currentActiveCoin,
        stream: coinsBloc.outcurrentActiveCoin,
        builder:
            (BuildContext context, AsyncSnapshot<CoinToActivate> snapshot) {
          return snapshot.data != null
              ? const SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(),
                )
              : SizedBox();
        });
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
            child: SizedBox(
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
  const LoadAsset({Key key}) : super(key: key);

  @override
  LoadAssetState createState() {
    return LoadAssetState();
  }
}

class LoadAssetState extends State<LoadAsset> {
  final Color color = Colors.white;

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
            color: color.withOpacity(0.8),
          ));
          listRet.add(
            Text(
              AppLocalizations.of(context).numberAssets(assetNumber.toString()),
              style: Theme.of(context).textTheme.caption.copyWith(color: color),
            ),
          );
          listRet.add(Icon(
            Icons.chevron_right,
            color: color.withOpacity(0.8),
          ));
        } else {
          listRet.add(SizedBox(
              height: 10,
              width: 10,
              child: const CircularProgressIndicator(
                strokeWidth: 1.0,
              )));
        }
        return SizedBox(
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
  const ListCoins({Key key}) : super(key: key);

  @override
  ListCoinsState createState() {
    return ListCoinsState();
  }
}

class ListCoinsState extends State<ListCoins> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            color: Theme.of(context).colorScheme.secondary,
            key: _refreshIndicatorKey,
            onRefresh: () => coinsBloc.updateCoinBalances(),
            child: Builder(builder: (BuildContext context) {
              if (snapshot.data != null && snapshot.data.isNotEmpty) {
                final List<CoinBalance> _coinsSorted =
                    coinsBloc.sortCoins(snapshot.data);

                return SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(0),
                    key: const Key('list-view-coins'),
                    itemCount: _coinsSorted.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ItemCoin(
                        key: Key('coin-list-${_coinsSorted[index].coin.abbr}'),
                        mContext: context,
                        coinBalance: _coinsSorted[index],
                      );
                      // }
                    },
                    separatorBuilder: (context, _) =>
                        Divider(color: Theme.of(context).colorScheme.surface),
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingCoin();
              } else if (snapshot.data.isEmpty) {
                // MRC: Add center to fix random UI glitch
                // due to loading Add Button
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AddCoinButton(
                        key: const Key('add-coin-button-empty'),
                        isCollapsed: true,
                      ),
                      Text(AppLocalizations.of(context).pleaseAddCoin),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            }));
      },
    );
  }
}
