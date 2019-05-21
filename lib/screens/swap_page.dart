import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/swap_confirmation_page.dart';
import 'package:komodo_dex/screens/swap_detail_page.dart';
import 'package:komodo_dex/screens/swap_history.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

class SwapPage extends StatefulWidget {
  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> with TickerProviderStateMixin {
  TextEditingController _controllerAmount = new TextEditingController();
  Animation<double> animation;
  AnimationController controller;
  bool isSwapProgress = false;
  CoinBalance coinBalance;
  FocusNode _focus = new FocusNode();
  String tmpText = "";
  String amountToBuy;
  @override
  void initState() {
    super.initState();
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    _controllerAmount.addListener(onChange);
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  void onChange() {
    String text = _controllerAmount.text;
    if (text.isNotEmpty) {
      setState(() {
        if (coinBalance != null &&
            double.parse(text.replaceAll(",", ".")) >
                coinBalance.balance.balance) {
          setMaxValue();
        } else {
          if (text.contains(
              RegExp("^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$"))) {
          } else {
            _controllerAmount.text = tmpText;
            _unfocusFocus();
          }
        }
      });
    }
  }

  void _unfocusFocus() async {
    _focus.unfocus();
    await Future.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        FocusScope.of(context).requestFocus(_focus);
      });
    });
  }

  void setMaxValue() async {
    _focus.unfocus();
    setState(() {
      var txFee = coinBalance.coin.txfee;
      var fee;
      if (txFee == null) {
        fee = 0;
      } else {
        fee = (txFee.toDouble() / 100000000);
      }
      _controllerAmount.text = ((coinBalance.balance.balance -
                  (coinBalance.balance.balance * 0.01)) -
              fee)
          .toStringAsFixed(8);
    });
    await Future.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        FocusScope.of(context).requestFocus(_focus);
      });
    });
  }

  @override
  void dispose() {
    _controllerAmount.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: SafeArea(
              child: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(
                      text: AppLocalizations.of(context).create.toUpperCase(),
                    ),
                    Tab(
                        text:
                            AppLocalizations.of(context).history.toUpperCase())
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          body: TabBarView(
            children: <Widget>[_buildSwapScreen(), SwapHistory()],
          ),
        ),
      ),
    );
  }

  _buildSwapScreen() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _buildCardCoin(Market.SELL),
          _buildSwapArrow(),
          _buildCardCoin(Market.BUY),
          _buildSwapButton()
        ],
      ),
    );
  }

  _buildCardCoin(Market market) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16, top: 8),
        child: Container(
          width: double.infinity,
          child: Card(
            elevation: 8.0,
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
                        coinBalance = snapshot.data;
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
                                      AppLocalizations.of(context).max,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .accentColor),
                                    ),
                                    onPressed: () {
                                      setMaxValue();
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    focusNode: _focus,
                                    controller: _controllerAmount,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                    textInputAction: TextInputAction.done,
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
                                        hintText: AppLocalizations.of(context)
                                            .amountToSell),
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

                        
                        if (_controllerAmount.text.isNotEmpty) {
                          amountToBuy = ordercoin.getBuyAmount(double.parse(
                              _controllerAmount.text.replaceAll(",", ".")));
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
                              Text(
                                  AppLocalizations.of(context).youWillReceived),
                              Expanded(
                                child: Container(),
                              ),
                              Text(amountToBuy,
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
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: OverflowBox(
                                    maxHeight: 100,
                                    maxWidth: 100,
                                    minHeight: 0,
                                    minWidth: 0,
                                    child: Image.asset(
                                      "assets/${snapshot.data.coin.abbr.toLowerCase()}.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data is OrderCoin) {
                    OrderCoin orderCoin = snapshot.data;

                    return Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      width: double.infinity,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: OverflowBox(
                                  maxHeight: 100,
                                  maxWidth: 100,
                                  minHeight: 0,
                                  minWidth: 0,
                                  child: Image.asset(
                                    "assets/${orderCoin.coinBase.abbr.toLowerCase()}.png",
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    );
                  } else if (market == Market.SELL) {
                    return Container(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).selectCoinToSell,
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
                                  AppLocalizations.of(context).selectCoinToBuy,
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
                    title: Text(AppLocalizations.of(context).sell),
                    children: _createListDialog(market, null),
                  )
                : StreamBuilder<List<OrderCoin>>(
                    initialData: swapBloc.orderCoins,
                    stream: swapBloc.outListOrderCoin,
                    builder: (context, snapshot) {
                      bool orderHasAsks = false;
                      if (snapshot.hasData && snapshot.data.length > 0) {
                        snapshot.data.forEach((orderbook) {
                          if (orderbook.orderbook.asks.length > 0) {
                            orderHasAsks = true;
                          }
                        });
                        if (orderHasAsks) {
                          return SimpleDialog(
                            title: Text(AppLocalizations.of(context).buy),
                            children: _createListDialog(market, snapshot.data),
                          );
                        } else {
                          return DialogLooking();
                        }
                      } else {
                        return DialogLooking();
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
        if (orderbooks.coinBase.abbr != swapBloc.sellCoin.coin.abbr &&
            double.parse(orderbooks.getBuyAmount(double.parse(
                    _controllerAmount.text.replaceAll(",", ".")))) >
                0) {
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
                    Text(orderbooks.getBuyAmount(double.parse(
                        _controllerAmount.text.replaceAll(",", ".")))),
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
        }
      });
    } else if (market == Market.SELL) {
      coinsBloc.coinBalance.forEach((coin) {
        if (coin.balance.balance > 0) {
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
        } //if
      });
    }

    return listDialog;
  }

  _buildSwapArrow() {
    return Container(
      height: 30,
      child: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Icon(
            Icons.play_arrow,
            size: 30,
            color: Colors.white30,
          ),
        ),
      ),
    );
  }

  _buildSwapButton() {
    return Container(
      height: 70,
      child: Container(
        width: double.infinity,
        child: Builder(builder: (context) {
          if (isSwapProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8))),
              color: Theme.of(context).buttonColor,
              disabledColor: Theme.of(context).disabledColor,
              child: Text(
                AppLocalizations.of(context).swap.toUpperCase(),
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: swapBloc.orderCoin != null &&
                      _controllerAmount.text.isNotEmpty
                  ? _confirmSwap
                  : null,
            );
          }
        }),
      ),
    );
  }

  _confirmSwap() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SwapConfirmation(
                amountToSell: _controllerAmount.text,
                amountToBuy: amountToBuy,
              )),
    );
  }
}

class DialogLooking extends StatefulWidget {
  @override
  _DialogLookingState createState() => _DialogLookingState();
}

class _DialogLookingState extends State<DialogLooking> {
  var timerGetOrderbook;

  @override
  void initState() {
    timerGetOrderbook = Timer.periodic(Duration(seconds: 5), (_) {
      swapBloc.getBuyCoins(swapBloc.sellCoin.coin);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (timerGetOrderbook != null) timerGetOrderbook.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              width: 16,
            ),
            Text(
              AppLocalizations.of(context).loadingOrderbook,
              style: Theme.of(context).textTheme.body1,
            )
          ],
        ),
      ),
    );
  }
}

enum Market {
  SELL,
  BUY,
}
