import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
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
  bool isActive = false;
  StreamSubscription<bool> sub;
  List<Coin> currentCoins = <Coin>[];
  bool isSearchActive = false;

  @override
  void initState() {
    coinsBloc.setCloseViewSelectCoin(false);
    sub = coinsBloc.outCloseViewSelectCoin.listen((dynamic onData) {
      if (onData != null && onData == true && mounted) {
        Navigator.of(context).pop();
      }
    });
    coinsBloc.initCoinBeforeActivation().then((_) {
      initCoinList();
    });
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  void initCoinList() {
    setState(() {
      for (CoinToActivate coinToActivate in coinsBloc.coinBeforeActivation) {
        currentCoins
            .removeWhere((Coin coin) => coin.abbr == coinToActivate.coin.abbr);
        currentCoins.add(coinToActivate.coin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 6.0,
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: SearchFieldFilterCoin(clear: () {
            initCoinList();
          }, onFilterCoins: (List<Coin> coinsFiltered) {
            setState(() {
              currentCoins = coinsFiltered;
            });
          }),
          leading: isSearchActive
              ? null
              : Builder(
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
                return isActive
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
                              _buildListCoin(),
                            ],
                          ),
                          Container(
                            color: Theme.of(context).primaryColor,
                            child: SafeArea(
                              child: Container(
                                height: 60,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: StreamBuilder<List<CoinToActivate>>(
                                        initialData:
                                            coinsBloc.coinBeforeActivation,
                                        stream:
                                            coinsBloc.outCoinBeforeActivation,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<CoinToActivate>>
                                                snapshot) {
                                          bool isButtonActive = false;
                                          if (snapshot.hasData) {
                                            for (CoinToActivate coinToActivate
                                                in snapshot.data) {
                                              if (coinToActivate.isActive) {
                                                isButtonActive = true;
                                              }
                                            }
                                          }
                                          return PrimaryButton(
                                            key: const Key(
                                                'done-activate-coins'),
                                            text: AppLocalizations.of(context)
                                                .done,
                                            isLoading: isActive,
                                            onPressed: isButtonActive
                                                ? _pressDoneButton
                                                : null,
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
              }
            }));
  }

  void _pressDoneButton() {
    setState(() {
      isActive = true;
    });
    coinsBloc.activateCoinsSelected();
  }

  Widget _buildListCoin() {
    final List<Widget> coinsToActivate = <Widget>[];

    if (currentCoins.isNotEmpty) {
      currentCoins.sort((Coin a, Coin b) => b.type.compareTo(a.type));

      String tmpType = currentCoins.first.type;
      if (tmpType != null && tmpType.isNotEmpty && currentCoins.length > 1) {
        coinsToActivate.add(BuildTypeHeader(
          type: tmpType,
        ));
      }
      for (Coin coin in currentCoins) {
        if (coin.type != tmpType) {
          coinsToActivate.add(BuildTypeHeader(
            type: coin.type,
          ));
        }
        tmpType = coin.type;

        coinsToActivate.add(BuildItemCoin(
          key: Key('coin-activate-${coin.abbr}'),
          coin: coin,
        ));
      }
      return Column(
        children: coinsToActivate,
      );
    } else {
      return Center(
          child: Text(
        'No coin found',
        style: Theme.of(context).textTheme.bodyText1,
      ));
    }
  }
}
