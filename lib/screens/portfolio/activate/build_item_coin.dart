import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/coin.dart';

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
      case 'qrc':
        isActive = !coinsBloc.isQRCActive;
        coinsBloc.outIsQRCActive.listen((bool onData) {
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
