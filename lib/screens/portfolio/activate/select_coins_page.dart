import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/settings_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/app_config.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/screens/portfolio/activate/build_item_coin.dart';
import 'package:komodo_dex/screens/portfolio/activate/build_type_header.dart';
import 'package:komodo_dex/screens/portfolio/activate/search_filter.dart';
import 'package:komodo_dex/screens/portfolio/loading_coin.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class SelectCoinsPage extends StatefulWidget {
  const SelectCoinsPage({this.coinsToActivate});

  final Function(List<Coin>) coinsToActivate;

  @override
  _SelectCoinsPageState createState() => _SelectCoinsPageState();
}

class _SelectCoinsPageState extends State<SelectCoinsPage> {
  bool _isDone = false;
  StreamSubscription<bool> _listenerClosePage;
  List<Coin> _currentCoins = <Coin>[];

  @override
  void initState() {
    coinsBloc.setCloseViewSelectCoin(false);
    _listenerClosePage =
        coinsBloc.outCloseViewSelectCoin.listen((dynamic onData) {
      if (onData != null && onData == true && mounted) {
        Navigator.of(context).pop();
      }
    });
    coinsBloc.initCoinBeforeActivation().then((_) {
      _initCoinList();
    });
    super.initState();
  }

  @override
  void dispose() {
    _listenerClosePage.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 6.0,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: SearchFieldFilterCoin(
            clear: () {
              _initCoinList();
            },
            onFilterCoins: (List<Coin> coinsFiltered) {
              setState(() {
                _currentCoins = coinsFiltered;
              });
            },
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: StreamBuilder<CoinToActivate>(
            initialData: coinsBloc.currentActiveCoin,
            stream: coinsBloc.outcurrentActiveCoin,
            builder:
                (BuildContext context, AsyncSnapshot<CoinToActivate> snapshot) {
              if (snapshot.data != null) {
                return LoadingCoin();
              } else {
                return _isDone
                    ? LoadingCoin()
                    : Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: <Widget>[
                          ListView(
                            padding: const EdgeInsets.only(bottom: 100),
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  AppLocalizations.of(context).selectCoinInfo,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              ..._coinListItems(),
                            ],
                          ),
                          _buildDoneButton(),
                        ],
                      );
              }
            }));
  }

  void _initCoinList() {
    setState(() {
      for (CoinToActivate coinToActivate in coinsBloc.coinBeforeActivation) {
        _currentCoins
            .removeWhere((Coin coin) => coin.abbr == coinToActivate.coin.abbr);
        _currentCoins.add(coinToActivate.coin);
      }
    });
  }

  List<Widget> _coinListItems() {
    final List<Widget> list = <Widget>[];

    if (_currentCoins.isNotEmpty) {
      _currentCoins.sort((Coin a, Coin b) => b.type.compareTo(a.type));

      String tmpType = _currentCoins.first.type;
      if (tmpType != null && tmpType.isNotEmpty && _currentCoins.length > 1) {
        list.add(BuildTypeHeader(
          type: tmpType,
        ));
      }

      // Loop through all inactive coins, except test coins (testCoin == true)
      for (Coin coin in _currentCoins) {
        if (coin.testCoin) continue;

        if (coin.type != tmpType) {
          list.add(BuildTypeHeader(
            type: coin.type,
          ));
        }
        tmpType = coin.type;

        list.add(BuildItemCoin(
          key: Key('coin-activate-${coin.abbr}'),
          coin: coin,
        ));
      }

      // Add test coins in a separate group
      final Iterable<Coin> testCoins = _currentCoins.where((Coin c) {
        return (c.testCoin && settingsBloc.enableTestCoins) ||
            c.abbr == 'RICK' ||
            c.abbr == 'MORTY';
      });
      if (testCoins.isNotEmpty) {
        list.add(BuildTypeHeader(
          type: null,
        ));

        for (Coin testCoin in testCoins) {
          list.add(BuildItemCoin(
            key: Key('coin-activate-${testCoin.abbr}'),
            coin: testCoin,
          ));
        }
      }

      return list;
    } else {
      return [
        Center(
            child: Text(
          'No coin found',
          style: Theme.of(context).textTheme.bodyText1,
        ))
      ];
    }
  }

  Widget _buildDoneButton() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Container(
          height: 60,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<CoinToActivate>>(
                  initialData: coinsBloc.coinBeforeActivation,
                  stream: coinsBloc.outCoinBeforeActivation,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<CoinToActivate>> snapshot) {
                    bool isButtonActive = false;
                    if (snapshot.hasData) {
                      for (CoinToActivate coinToActivate in snapshot.data) {
                        if (coinToActivate.isActive) {
                          isButtonActive = true;
                        }
                      }
                    }
                    return PrimaryButton(
                      key: const Key('done-activate-coins'),
                      text: AppLocalizations.of(context).done,
                      isLoading: _isDone,
                      onPressed: isButtonActive ? _pressDoneButton : null,
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  void _pressDoneButton() {
    final numCoinsEnabled = coinsBloc.coinBalance.length;
    final numCoinsTryingEnable =
        coinsBloc.coinBeforeActivation.where((c) => c.isActive).toList().length;
    final maxCoinPerPlatform = Platform.isAndroid
        ? appConfig.maxCoinsEnabledAndroid
        : appConfig.maxCoinEnabledIOS;
    if (numCoinsEnabled + numCoinsTryingEnable > maxCoinPerPlatform) {
      dialogBloc.closeDialog(context);
      dialogBloc.dialog = showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text(AppLocalizations.of(context).enablingTooManyAssetsTitle),
            content: Text(
                AppLocalizations.of(context).enablingTooManyAssetsSpan1 +
                    numCoinsEnabled.toString() +
                    AppLocalizations.of(context).enablingTooManyAssetsSpan2 +
                    numCoinsTryingEnable.toString() +
                    AppLocalizations.of(context).enablingTooManyAssetsSpan3 +
                    maxCoinPerPlatform.toString() +
                    AppLocalizations.of(context).enablingTooManyAssetsSpan4),
            actions: [
              FlatButton(
                child: Text(AppLocalizations.of(context).warningOkBtn),
                onPressed: () {
                  dialogBloc.closeDialog(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() => _isDone = true);
      coinsBloc.activateCoinsSelected();
    }
  }
}
