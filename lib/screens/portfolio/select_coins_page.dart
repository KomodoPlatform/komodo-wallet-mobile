import 'dart:async';

import 'package:flutter/material.dart';
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
                                  style: Theme.of(context).textTheme.body2,
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
        coinsToActivate.add(BuildHeaderChain(
          type: tmpType,
        ));
      }
      for (Coin coin in currentCoins) {
        if (coin.type != tmpType) {
          coinsToActivate.add(BuildHeaderChain(
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
        style: Theme.of(context).textTheme.body2,
      ));
    }
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({
    Key key,
    @required this.appLoc,
    @required this.onCancel,
  }) : super(key: key);

  final AppLocalizations appLoc;
  final Function onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        onTap: onCancel,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            '${appLoc.cancel[0].toUpperCase()}${appLoc.cancel.substring(1)}',
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Theme.of(context).accentColor),
          )),
        ),
      ),
    );
  }
}

class BuildHeaderChain extends StatefulWidget {
  const BuildHeaderChain({Key key, this.type}) : super(key: key);

  final String type;

  @override
  _BuildHeaderChainState createState() => _BuildHeaderChainState();
}

class _BuildHeaderChainState extends State<BuildHeaderChain> {
  bool isActive = false;

  String getTitleText() {
    switch (widget.type) {
      case 'erc':
        return AppLocalizations.of(context).searchFilterSubtitleERC;
        break;
      case 'utxo':
        return AppLocalizations.of(context).searchFilterSubtitleutxo;
        break;
      case 'smartChain':
        return AppLocalizations.of(context).searchFilterSubtitleSmartChain;
        break;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        switch (widget.type) {
          case 'erc':
            isActive
                ? coinsBloc.setIsERCActive(true)
                : coinsBloc.setIsERCActive(false);
            break;
          case 'utxo':
            isActive
                ? coinsBloc.setIsutxoActive(true)
                : coinsBloc.setIsutxoActive(false);
            break;
          case 'smartChain':
            isActive
                ? coinsBloc.setIsAllSmartChainActive(true)
                : coinsBloc.setIsAllSmartChainActive(false);
            break;
          default:
        }
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
            Text(
              getTitleText(),
              style: Theme.of(context).textTheme.subtitle,
            )
          ],
        ),
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
  void initState() {
    isActive = false;
    switch (widget.coin.type) {
      case 'erc':
        isActive = !coinsBloc.isERCActive;
        coinsBloc.outIsERCActive.listen((bool onData) {
          listenActiveCoin(onData);
        });
        break;
      case 'utxo':
        isActive = !coinsBloc.isutxoActive;
        coinsBloc.outIsutxoActive.listen((bool onData) {
          listenActiveCoin(onData);
        });
        break;
      case 'smartChain':
        isActive = !coinsBloc.isAllSmartChainActive;

        coinsBloc.outIsAllSmartChainActive.listen((bool onData) {
          listenActiveCoin(onData);
        });
        break;
      default:
    }
    super.initState();
  }

  void listenActiveCoin(bool onData) {
    if (!mounted) {
      return;
    }
    setState(() {
      isActive = onData;
    });
    activeCoin(isActive);
  }

  void activeCoin(bool forceActive) {
    setState(() {
      final CoinToActivate coinToActivate = coinsBloc.coinBeforeActivation
          .firstWhere(
              (CoinToActivate item) => item.coin.abbr == widget.coin.abbr);
      if (forceActive != null) {
        coinsBloc.setCoinBeforeActivation(widget.coin, forceActive);
      } else {
        coinsBloc.setCoinBeforeActivation(
            widget.coin, !coinToActivate.isActive);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        activeCoin(null);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(top: 16, bottom: 16, left: 50, right: 16),
        child: Row(
          children: <Widget>[
            StreamBuilder<List<CoinToActivate>>(
                initialData: coinsBloc.coinBeforeActivation,
                stream: coinsBloc.outCoinBeforeActivation,
                builder: (BuildContext context,
                    AsyncSnapshot<List<CoinToActivate>> snapshot) {
                  final CoinToActivate coinToActivate = snapshot.data
                      .firstWhere((CoinToActivate item) =>
                          item.coin.abbr == widget.coin.abbr);
                  return Container(
                    height: 15,
                    width: 15,
                    color: coinToActivate.isActive
                        ? Theme.of(context).accentColor
                        : Theme.of(context).primaryColor,
                  );
                }),
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
  const SearchFieldFilterCoin({
    Key key,
    this.onFilterCoins,
    this.clear,
  }) : super(key: key);

  final Function(List<Coin>) onFilterCoins;
  final Function clear;

  @override
  _SearchFieldFilterCoinState createState() => _SearchFieldFilterCoinState();
}

class _SearchFieldFilterCoinState extends State<SearchFieldFilterCoin> {
  final FocusNode _focus = FocusNode();
  bool isEmptyQuery = true;
  final TextEditingController _controller = TextEditingController();

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search,
              size: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextFormField(
                textInputAction: TextInputAction.search,
                autofocus: true,
                controller: _controller,
                focusNode: _focus,
                maxLength: 50,
                maxLines: 1,
                cursorColor: Theme.of(context).accentColor,
                decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.body2,
                    labelStyle: Theme.of(context).textTheme.body1,
                    hintText: AppLocalizations.of(context).searchFilterCoin,
                    labelText: null),
                onChanged: (String query) async {
                  isEmptyQuery = query.isEmpty;
                  widget.onFilterCoins(
                      await coinsBloc.getAllNotActiveCoinsWithFilter(query));
                },
              ),
            ),
            InkWell(
              onTap: () {
                if (!isEmptyQuery) {
                  widget.clear();
                  _controller.clear();
                  setState(() {
                    isEmptyQuery = true;
                  });
                } else {
                  FocusScope.of(context).requestFocus(_focus);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: isEmptyQuery
                    ? null
                    : RotationTransition(
                        turns: const AlwaysStoppedAnimation<double>(45 / 360),
                        child: Icon(Icons.add_circle)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
