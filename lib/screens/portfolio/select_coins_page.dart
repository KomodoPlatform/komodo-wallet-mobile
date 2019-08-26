import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
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

  @override
  void initState() {
    coinsBloc.setCloseViewSelectCoin(false);
    sub = coinsBloc.outCloseViewSelectCoin.listen((dynamic onData) {
      if (onData != null && onData == true && mounted) {
        Navigator.of(context).pop();
      }
    });
    initCurrentCoins();
    super.initState();
  }

  Future<void> initCurrentCoins() async {
    final List<Coin> getCoins = await coinsBloc.getAllNotActiveCoins();
    setState(() {
      currentCoins = getCoins;
    });
  }

  @override
  void dispose() {
    sub.cancel();
    coinsBloc.resetActivateCoin();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context).selectCoinTitle.toUpperCase(),
            style: Theme.of(context).textTheme.subtitle,
            textAlign: TextAlign.start,
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.close),
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
                            padding:
                                const EdgeInsets.only(bottom: 100, top: 32),
                            children: <Widget>[
                              const SizedBox(
                                height: 32,
                              ),
                              _buildListCoin(),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                                height: 75,
                                color: Theme.of(context).backgroundColor,
                                child: _buildHeader()),
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
                                    child: StreamBuilder<List<Coin>>(
                                        initialData: coinsBloc.coinToActivate,
                                        stream: coinsBloc.outCoinToActivate,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<Coin>>
                                                snapshot) {
                                          return PrimaryButton(
                                            key: const Key(
                                                'done-activate-coins'),
                                            text: AppLocalizations.of(context)
                                                .done,
                                            isLoading: isActive,
                                            onPressed: snapshot.hasData &&
                                                    snapshot.data != null &&
                                                    snapshot.data.isNotEmpty
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
    coinsBloc.activateCoinsSelected(coinsBloc.coinToActivate);
  }

  Widget _buildListCoin() {
    final List<Widget> coinsToActivate = <Widget>[];

    for (Coin coin in currentCoins) {
      coinsToActivate.add(BuildItemCoin(
        key: Key('coin-activate-${coin.abbr}'),
        coin: coin,
      ));
    }
    return Column(
      children: coinsToActivate,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context).selectCoinInfo,
              style: Theme.of(context).textTheme.body2,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SearchFieldFilterCoin(onFilterCoins: (List<Coin> coinsFiltered) {
            setState(() {
              currentCoins = coinsFiltered;
            });
          }),
        ],
      ),
    );
  }
}

class BuildItemCoin extends StatefulWidget {
  const BuildItemCoin({Key key, this.coin}) : super(key: key);

  final Coin coin;

  @override
  _BuildItemCoinState createState() => _BuildItemCoinState();
}

class _BuildItemCoinState extends State<BuildItemCoin> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        isActive
            ? coinsBloc.addActivateCoin(widget.coin)
            : coinsBloc.removeActivateCoin(widget.coin);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        child: Row(
          children: <Widget>[
            Container(
              height: 15,
              width: 15,
              color: isActive
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 24),
            Image.asset(
              'assets/${widget.coin.abbr.toLowerCase()}.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 24),
            Text('${widget.coin.name} (${widget.coin.abbr})')
          ],
        ),
      ),
    );
  }
}

class LoadingCoin extends StatefulWidget {
  @override
  _LoadingCoinState createState() => _LoadingCoinState();
}

class _LoadingCoinState extends State<LoadingCoin> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(
          height: 16,
        ),
        StreamBuilder<CoinToActivate>(
            initialData: coinsBloc.currentActiveCoin,
            stream: coinsBloc.outcurrentActiveCoin,
            builder:
                (BuildContext context, AsyncSnapshot<CoinToActivate> snapshot) {
              if (snapshot.data != null &&
                  snapshot.data.currentStatus != null) {
                return Text(snapshot.data.currentStatus);
              } else {
                return Text(AppLocalizations.of(context).connecting);
              }
            })
      ],
    ));
  }
}

class SearchFieldFilterCoin extends StatefulWidget {
  const SearchFieldFilterCoin({Key key, this.onFilterCoins}) : super(key: key);

  final Function(List<Coin>) onFilterCoins;

  @override
  _SearchFieldFilterCoinState createState() => _SearchFieldFilterCoinState();
}

class _SearchFieldFilterCoinState extends State<SearchFieldFilterCoin> {
  final FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(_focus);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                focusNode: _focus,
                maxLength: 50,
                maxLines: 1,
                cursorColor: Theme.of(context).accentColor,
                decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.body1,
                    labelStyle: Theme.of(context).textTheme.body1,
                    hintText: AppLocalizations.of(context).searchFilterCoin,
                    labelText: null),
                onChanged: (String query) async {
                  widget.onFilterCoins(
                      await coinsBloc.getAllNotActiveCoinsWithFilter(query));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.search),
            )
          ],
        ),
      ),
    );
  }
}
