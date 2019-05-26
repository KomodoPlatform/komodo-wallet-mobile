import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

class SelectCoinsPage extends StatefulWidget {
  @override
  _SelectCoinsPageState createState() => _SelectCoinsPageState();
}

class _SelectCoinsPageState extends State<SelectCoinsPage> {
  bool isActivate = false;

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
      body: SafeArea(
        child: isActivate
            ? LoadingCoin()
            : Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  ListView(
                    padding: EdgeInsets.only(bottom: 100, top: 32),
                    children: <Widget>[
                      _buildHeader(),
                      SizedBox(
                        height: 32,
                      ),
                      _buildListCoin(),
                    ],
                  ),
                  Container(
                    height: 100,
                    color: Theme.of(context).primaryColor,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: StreamBuilder<List<Coin>>(
                          initialData: coinsBloc.coinToActivate,
                          stream: coinsBloc.outCoinToActivate,
                          builder: (context, snapshot) {
                            return PrimaryButton(
                              text: AppLocalizations.of(context).done,
                              onPressed: snapshot.hasData && snapshot.data.length > 0 ? _pressDoneButton : null,
                            );
                          }
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  _pressDoneButton() async {
    setState(() {
      isActivate = true;
    });
    print(coinsBloc.coinToActivate.length);
    await coinsBloc.addMultiCoins(coinsBloc.coinToActivate).then((onValue) {
      _closeSelectCoinsPage();
    }).timeout(Duration(seconds: 20), onTimeout: () {
      _closeSelectCoinsPage();
    });
  }

  _closeSelectCoinsPage() {
    coinsBloc.resetActivateCoin();
    setState(() {
      isActivate = false;
    });
    Navigator.pop(context);
  }

  _buildListCoin() {
    return FutureBuilder<List<Coin>>(
      future: coinsBloc.getAllNotActiveCoins(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> coinsToActivate = new List<Widget>();
          snapshot.data.forEach((coin) {
            coinsToActivate.add(BuildItemCoin(
              coin: coin,
            ));
          });
          return Column(
            children: coinsToActivate,
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            AppLocalizations.of(context).selectCoinInfo,
            style: Theme.of(context).textTheme.body2,
          )
        ],
      ),
    );
  }
}

class BuildItemCoin extends StatefulWidget {
  final Coin coin;

  BuildItemCoin({this.coin});

  @override
  _BuildItemCoinState createState() => _BuildItemCoinState();
}

class _BuildItemCoinState extends State<BuildItemCoin> {
  bool isActivate = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isActivate = !isActivate;
        });
        isActivate
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
              color: isActivate
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
            ),
            SizedBox(width: 24),
            Image.asset(
              "assets/${widget.coin.abbr.toLowerCase()}.png",
              height: 40,
              width: 40,
            ),
            SizedBox(width: 24),
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
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(height: 16,),
        StreamBuilder<Coin>(
          stream: coinsBloc.outcurrentActiveCoin,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Activate: ${snapshot.data.name}');
            } else {
              return Container();
            }
          }
        )
      ],
    ));
  }
}