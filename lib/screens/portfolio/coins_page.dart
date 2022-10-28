import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/blocs/zcash_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/app_config/app_config.dart';
import 'package:komodo_dex/model/cex_provider.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/screens/portfolio/activate/select_coins_page.dart';
import 'package:komodo_dex/screens/portfolio/loading_coin.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/widgets/custom_simple_dialog.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _cexProvider = Provider.of<CexProvider>(context);
    _heightScreen = MediaQuery.of(context).size.height;
    _widthScreen = MediaQuery.of(context).size.width;
    _heightSliver = _heightScreen * 0.25 - MediaQuery.of(context).padding.top;
    if (_heightSliver < 125) _heightSliver = 125;

    return Scaffold(
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  expandedHeight: _heightSliver,
                  pinned: true,
                  flexibleSpace: Builder(
                    builder: (BuildContext context) {
                      return Stack(
                        children: <Widget>[
                          FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            centerTitle: true,
                            titlePadding:
                                EdgeInsetsDirectional.only(bottom: 10),
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
                                          initialData: settingsBloc.showBalance,
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
                                              onPressed: () =>
                                                  _cexProvider.switchCurrency(),
                                              style: TextButton.styleFrom(
                                                primary: _heightFactor < 1.3
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                ),
                              ),
                            ),
                          ),
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
            child: Column(
              children: [
                _buildZCashProgressIndicator(),
                Expanded(
                  child: Builder(builder: (BuildContext context) {
                    if (snapshot.data != null && snapshot.data.isNotEmpty) {
                      final List<dynamic> datas = <dynamic>[];

                      final List<CoinBalance> _sorted =
                          coinsBloc.sortCoins(snapshot.data);

                      datas.addAll(_sorted);
                      datas.add(true);
                      return SlidableAutoCloseBehavior(
                        child: ListView.separated(
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
                              );
                            }
                          },
                          separatorBuilder: (context, _) => Divider(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return LoadingCoin();
                    } else if (snapshot.data.isEmpty) {
                      // MRC: Add center to fix random UI glitch
                      // due to loading Add Button
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            AddCoinButton(),
                            Text('Please Add A Coin'),
                          ],
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  }),
                ),
              ],
            ));
      },
    );
  }

  Widget _buildZCashProgressIndicator() {
    return StreamBuilder<int>(
        initialData: zcashBloc.totalDownloadSize,
        stream: zcashBloc.outZcashProgress,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          int _received = snapshot.data;
          int _totalDownloadSize = zcashBloc.totalDownloadSize;
          return _totalDownloadSize > 0
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: _received / _totalDownloadSize,
                    ),
                    _received == _totalDownloadSize
                        ? Text('Downloaded Zcash Params')
                        : Text(
                            'Downloading Zcash Parameters: ${_received ~/ 1000000}MB / ${_totalDownloadSize ~/ 1000000}MB',
                          ),
                  ],
                )
              : SizedBox();
        });
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
                    Text(snapshot.data.currentStatus ??
                        AppLocalizations.of(context).connecting),
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
                            child: Icon(Icons.add),
                            onPressed: () {
                              if (mainBloc.networkStatus !=
                                  NetworkStatus.Online) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Theme.of(context).errorColor,
                                  content: Text(
                                      AppLocalizations.of(context).noInternet),
                                ));
                              } else {
                                final numCoinsEnabled =
                                    coinsBloc.coinBalance.length;
                                final maxCoinPerPlatform = Platform.isAndroid
                                    ? appConfig.maxCoinsEnabledAndroid
                                    : appConfig.maxCoinEnabledIOS;
                                if (numCoinsEnabled >= maxCoinPerPlatform) {
                                  dialogBloc.closeDialog(context);
                                  dialogBloc.dialog = showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomSimpleDialog(
                                        title: Text(AppLocalizations.of(context)
                                            .tooManyAssetsEnabledTitle),
                                        children: [
                                          Text(AppLocalizations.of(context)
                                                  .tooManyAssetsEnabledSpan1 +
                                              numCoinsEnabled.toString() +
                                              AppLocalizations.of(context)
                                                  .tooManyAssetsEnabledSpan2 +
                                              maxCoinPerPlatform.toString() +
                                              AppLocalizations.of(context)
                                                  .tooManyAssetsEnabledSpan3),
                                          SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => dialogBloc
                                                    .closeDialog(context),
                                                child: Text(
                                                    AppLocalizations.of(context)
                                                        .warningOkBtn),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ).then(
                                      (dynamic _) => dialogBloc.dialog = null);
                                } else {
                                  Navigator.push<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            const SelectCoinsPage()),
                                  );
                                }
                              }
                            },
                          )),
                        ),
                      );
                    } else {
                      return SizedBox();
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
