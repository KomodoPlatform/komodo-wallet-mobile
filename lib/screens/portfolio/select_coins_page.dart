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
                                const EdgeInsets.only(bottom: 100, top: 52),
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
    bool headerSmartChain = true;
    bool headerERC = true;

    if (currentCoins.length == 1) {
      headerSmartChain = false;
      headerERC = false;
    }
    for (Coin coin in currentCoins) {
      if (coin.swapContractAddress.isEmpty && headerSmartChain) {
        coinsToActivate.add(const BuildHeaderChain(
          isSmartChainHeader: true,
        ));
        headerSmartChain = false;
      }
      if (coin.swapContractAddress.isNotEmpty && headerERC) {
        coinsToActivate.add(const BuildHeaderChain(
          isSmartChainHeader: false,
        ));
        headerERC = false;
      }
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
          SearchFieldFilterCoin(clear: () {
            initCoinList();
          }, onFilterCoins: (List<Coin> coinsFiltered) {
            setState(() {
              currentCoins = coinsFiltered;
            });
          }),
        ],
      ),
    );
  }
}

class BuildHeaderChain extends StatefulWidget {
  const BuildHeaderChain({Key key, this.isSmartChainHeader}) : super(key: key);

  final bool isSmartChainHeader;

  @override
  _BuildHeaderChainState createState() => _BuildHeaderChainState();
}

class _BuildHeaderChainState extends State<BuildHeaderChain> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        if (widget.isSmartChainHeader) {
          isActive
              ? coinsBloc.setIsAllSmartChainActive(true)
              : coinsBloc.setIsAllSmartChainActive(false);
        } else {
          isActive
              ? coinsBloc.setIsERCActive(true)
              : coinsBloc.setIsERCActive(false);
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
            widget.isSmartChainHeader
                ? Text(
                    AppLocalizations.of(context).searchFilterSubtitleSmartChain,
                    style: Theme.of(context).textTheme.subtitle,
                  )
                : Text(AppLocalizations.of(context).searchFilterSubtitleERC,
                    style: Theme.of(context).textTheme.subtitle)
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

    if (widget.coin.swapContractAddress.isNotEmpty) {
      isActive = !coinsBloc.isAllSmartChainActive;

      coinsBloc.outIsERCActive.listen((bool onData) {
        if (!mounted) {
          return;
        }
        setState(() {
          isActive = onData;
        });
        activeCoin(isActive);
      });
    } else {
      isActive = !coinsBloc.isERCActive;
      coinsBloc.outIsAllSmartChainActive.listen((bool onData) {
        if (!mounted) {
          return;
        }
        setState(() {
          isActive = onData;
        });
        activeCoin(isActive);
      });
    }

    super.initState();
  }

  void activeCoin(bool forceActive) {
    setState(() {
      final CoinToActivate coinToActivate = coinsBloc.coinBeforeActivation
          .firstWhere(
              (CoinToActivate item) => item.coin.abbr == widget.coin.abbr);
      if (forceActive != null) {
      coinsBloc.setCoinBeforeActivation(widget.coin, forceActive);

      } else {
              coinsBloc.setCoinBeforeActivation(widget.coin, !coinToActivate.isActive);

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
  const SearchFieldFilterCoin({Key key, this.onFilterCoins, this.clear})
      : super(key: key);

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
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: _controller,
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
                child:
                    isEmptyQuery ? Icon(Icons.search) : const Icon(Icons.close),
              ),
            )
          ],
        ),
      ),
    );
  }
}
