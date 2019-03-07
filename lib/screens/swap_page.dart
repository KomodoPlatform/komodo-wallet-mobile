import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

class SwapPage extends StatefulWidget {
  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> with TickerProviderStateMixin {
  TextEditingController _controllerAmount = new TextEditingController();
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  @override
  void dispose() {
    _controllerAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildCardCoin(Market.SELL),
            _buildSwapArrow(),
            _buildCardCoin(Market.BUY),
            _buildSwapButton()
          ],
        ),
      ),
    );
  }

  _buildCardCoin(Market market) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Card(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _buildInsideCard(market),
                ),
                StreamBuilder<dynamic>(
                    initialData: market == Market.SELL
                        ? swapBloc.sellCoin
                        : swapBloc.orderCoin,
                    stream: market == Market.SELL
                        ? swapBloc.outSellCoin
                        : swapBloc.outOrderCoin,
                    builder: (context, snapshot) {
                      if (snapshot.data is CoinBalance &&
                          snapshot.hasData &&
                          snapshot.data != null) {
                        return Container(
                          height: 70,
                          width: double.infinity,
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.4),
                          child: FadeTransition(
                            opacity: animation,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: double.infinity,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(16))),
                                    child: Text(
                                      "MAX",
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .accentColor),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        var txFee = snapshot.data.coin.txfee;
                                        var fee;
                                        if (txFee == null) {
                                          fee = 0;
                                        } else {
                                          fee = (txFee.toDouble() / 100000000);
                                        }
                                        _controllerAmount.text =
                                            (snapshot.data.balance.balance -
                                                    fee)
                                                .toString();
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _controllerAmount,
                                    onChanged: (data) {
                                      setState(() {
                                        if (double.parse(
                                                _controllerAmount.text) >
                                            snapshot.data.balance.balance) {
                                          _controllerAmount.text =
                                              (snapshot.data.balance.balance)
                                                  .toString();
                                        }
                                      });
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400),
                                        hintText: 'Amount To Sell'),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Container(
                                    child: Text(
                                      snapshot.data.coin.abbr,
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data is OrderCoin) {
                        OrderCoin ordercoin = snapshot.data;

                        String amountBuy = "0";
                        if (_controllerAmount.text.isNotEmpty) {
                          amountBuy = ordercoin.getBuyAmount(
                              double.parse(_controllerAmount.text));
                        }

                        return Container(
                          height: 70,
                          width: double.infinity,
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.4),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 16,
                              ),
                              Text('You will received: '),
                              Expanded(
                                child: Container(),
                              ),
                              Text(amountBuy,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  child: Text(
                                    ordercoin.coinBase.abbr,
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    })
              ],
            ),
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ),
    );
  }

  _buildInsideCard(Market market) {
    return StreamBuilder<dynamic>(
        initialData:
            market == Market.SELL ? swapBloc.sellCoin : swapBloc.orderCoin,
        stream: market == Market.SELL
            ? swapBloc.outSellCoin
            : swapBloc.outOrderCoin,
        builder: (context, snapshot) {
          return InkWell(
            onTap: () {
              if (market == Market.SELL) {
                _openDialogCoinWithBalance(market);
              } else if (market == Market.BUY &&
                  swapBloc.sellCoin != null &&
                  _controllerAmount.text.isNotEmpty) {
                _openDialogCoinWithBalance(market);
              } else if (market == Market.BUY) {
                setState(() {
                  controller.reset();
                  controller.forward();
                });
              }
            },
            borderRadius: BorderRadius.only(
                bottomRight: snapshot.hasData && snapshot.data != null
                    ? Radius.circular(0)
                    : Radius.circular(16),
                bottomLeft: snapshot.hasData && snapshot.data != null
                    ? Radius.circular(0)
                    : Radius.circular(16),
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16)),
            child: StreamBuilder<dynamic>(
                initialData: market == Market.SELL
                    ? swapBloc.sellCoin
                    : swapBloc.orderCoin,
                stream: market == Market.SELL
                    ? swapBloc.outSellCoin
                    : swapBloc.outOrderCoin,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data is CoinBalance) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                    "assets/${snapshot.data.coin.abbr.toLowerCase()}.png"),
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Container()),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    snapshot.data.coin.name.toUpperCase(),
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        snapshot.data.balance.balance
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        snapshot.data.coin.abbr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                      )
                                    ],
                                  ),
                                  Text(
                                    "\$${(snapshot.data.balance.balance * 1.3).toStringAsFixed(2)} USD",
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data is OrderCoin) {
                    OrderCoin orderCoin = snapshot.data;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                    "assets/${orderCoin.coinBase.abbr.toLowerCase()}.png"),
                              ],
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: Container()),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    orderCoin.coinBase.name.toUpperCase(),
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  } else if (market == Market.SELL) {
                    return Container(
                      child: Center(
                        child: Text(
                          'Select the coin you want to SELL',
                          style: Theme.of(context).textTheme.subtitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return StreamBuilder<Object>(
                        initialData: swapBloc.sellCoin,
                        stream: swapBloc.outSellCoin,
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              _controllerAmount.text.isNotEmpty) {
                            return Container(
                              child: Center(
                                child: Text(
                                  'Select the coin you want to BUY',
                                  style: Theme.of(context).textTheme.subtitle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        });
                  }
                }),
          );
        });
  }

  _openDialogCoinWithBalance(Market market) async {
    if (market == Market.BUY) {
      if (swapBloc.sellCoin != null && swapBloc.sellCoin.coin != null) {
        swapBloc.getBuyCoins(swapBloc.sellCoin.coin);
      }
    }
    await showDialog<List<CoinBalance>>(
        context: context,
        builder: (BuildContext context) {
          return Theme(
            data: ThemeData(
                textTheme: Theme.of(context).textTheme,
                dialogBackgroundColor: Theme.of(context).dialogBackgroundColor),
            child: market == Market.SELL
                ? SimpleDialog(
                    title: Text('Sell'),
                    children: _createListDialog(market, null),
                  )
                : StreamBuilder<List<OrderCoin>>(
                    initialData: swapBloc.orderCoins,
                    stream: swapBloc.outListOrderCoin,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print(snapshot.data.length);
                        return SimpleDialog(
                          title: Text('Buy'),
                          children: _createListDialog(market, snapshot.data),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          );
        });
  }

  List<SimpleDialogOption> _createListDialog(
      Market market, List<OrderCoin> orderbooks) {
    List<SimpleDialogOption> listDialog = new List<SimpleDialogOption>();

    if (orderbooks != null && market == Market.BUY) {
      orderbooks.forEach((orderbooks) {
        SimpleDialogOption dialogItem = SimpleDialogOption(
          onPressed: () {
            setState(() {});
            swapBloc.updateBuyCoin(orderbooks);
            Navigator.pop(context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 30,
                  width: 30,
                  child: Image.asset(
                    "assets/${orderbooks.coinBase.abbr.toLowerCase()}.png",
                  )),
              Expanded(
                child: Container(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(orderbooks
                      .getBuyAmount(double.parse(_controllerAmount.text))),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    orderbooks.coinBase.abbr,
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              )
            ],
          ),
        );
        listDialog.add(dialogItem);
      });
    } else if (market == Market.SELL) {
      coinsBloc.coinBalance.forEach((coin) {
        SimpleDialogOption dialogItem = SimpleDialogOption(
          onPressed: () {
            _controllerAmount.text = '';
            swapBloc.updateSellCoin(coin);
            swapBloc.updateBuyCoin(null);
            Navigator.pop(context);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 30,
                  width: 30,
                  child: Image.asset(
                    "assets/${coin.coin.abbr.toLowerCase()}.png",
                  )),
              Expanded(
                child: Container(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(coin.balance.balance.toString()),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    coin.coin.abbr,
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              )
            ],
          ),
        );
        listDialog.add(dialogItem);
      });
    }

    return listDialog;
  }

  _buildSwapArrow() {
    return Container(
      height: 50,
      child: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Icon(
            Icons.play_arrow,
            size: 50,
            color: Colors.white30,
          ),
        ),
      ),
    );
  }

  _buildSwapButton() {
    return Container(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          width: double.infinity,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8), topLeft: Radius.circular(8))),
            color: Theme.of(context).buttonColor,
            disabledColor: Theme.of(context).disabledColor,
            child: Text(
              'SWAP',
              style: Theme.of(context).textTheme.button,
            ),
            onPressed:
                swapBloc.orderCoin != null && _controllerAmount.text.isNotEmpty
                    ? _makeASwap
                    : null,
          ),
        ),
      ),
    );
  }

  _makeASwap() {
    mm2
        .postBuy(
            swapBloc.orderCoin.coinBase,
            swapBloc.orderCoin.coinRel,
            double.parse(_controllerAmount.text),
            double.parse(swapBloc.orderCoin
                    .getBuyAmount(double.parse(_controllerAmount.text))) +
                (double.parse(swapBloc.orderCoin
                        .getBuyAmount(double.parse(_controllerAmount.text))) *
                    0.01))
        .then((onValue) {
      if (onValue is BuyResponse && onValue.result == "success") {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("Buy success, waiting for swap..."),
        ));
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("A error happened please wait."),
        ));
      }
    });
  }
}

enum Market {
  SELL,
  BUY,
}
