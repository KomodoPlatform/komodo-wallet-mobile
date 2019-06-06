import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/screens/swap_confirmation_page.dart';
import 'package:komodo_dex/screens/swap_history.dart';
import 'package:komodo_dex/widgets/primary_button.dart';

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
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 2, vsync: this);
    if (swapHistoryBloc.isSwapsOnGoing) {
      tabController.index = 1;
    }
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
                  controller: tabController,
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
            controller: tabController,
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
          ExchangeRate(),
          _buildSwapButton()
        ],
      ),
    );
  }

  _buildCardCoin(Market market) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: market == Market.SELL ? 0 : 8,
            left: 16,
            right: 16,
            top: market == Market.SELL ? 8 : 0),
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
                                  child: StreamBuilder<bool>(
                                    initialData: swapBloc.focusTextField,
                                    stream: swapBloc.outFocusTextField,
                                    builder: (context, snapshot) {
                                      return TextFormField(
                                        focusNode: _focus,
                                        controller: _controllerAmount,
                                        autofocus: snapshot.data,
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
                                      );
                                    }
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: OverflowBox(
                                        maxHeight: 80,
                                        child: Image.asset(
                                          "assets/${snapshot.data.coin.abbr.toLowerCase()}.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: OverflowBox(
                                    maxHeight: 80,
                                    child: Image.asset(
                                      "assets/${orderCoin.coinBase.abbr.toLowerCase()}.png",
                                      fit: BoxFit.cover,
                                    ),
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
    List<SimpleDialogOption> listDialogCoins = _createListDialog(context, market, null);

    dialogBloc.dialog = showDialog<List<CoinBalance>>(
        context: context,
        builder: (BuildContext context) {
          return market == Market.SELL
              ? listDialogCoins.length > 0
                  ? SimpleDialog(
                      title: Text(AppLocalizations.of(context).sell),
                      children: listDialogCoins,
                    )
                  : SimpleDialog(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(8.0)),
                      backgroundColor: Colors.white,
                      title: Column(
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).accentColor,
                            size: 48,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "No funds",
                            style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(color: Theme.of(context).accentColor),
                          ),
                          SizedBox(
                            height: 16,
                          )
                        ],
                      ),
                      children: <Widget>[
                        Text("No funds detected please add some.",
                            style: Theme.of(context).textTheme.body1.copyWith(
                                color: Theme.of(context).primaryColor)),
                        SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: PrimaryButton(
                                text: "Go to portfolio",
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  mainBloc.setCurrentIndexTab(0);
                                },
                                backgroundColor: Theme.of(context).accentColor,
                                isDarkMode: false,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 24,
                        ),
                      ],
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
                          children:
                              _createListDialog(context, market, snapshot.data),
                        );
                      } else {
                        return DialogLooking();
                      }
                    } else {
                      return DialogLooking();
                    }
                  },
                );
        }).then((_) {
      dialogBloc.dialog = null;
    });
  }

  List<SimpleDialogOption> _createListDialog(
      BuildContext context, Market market, List<OrderCoin> orderbooks) {
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
              setState(() {});
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
      height: 25,
      child: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Icon(
            Icons.play_arrow,
            size: 25,
            color: Colors.white30,
          ),
        ),
      ),
    );
  }

  _buildSwapButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      child: Container(
        width: double.infinity,
        child: Builder(builder: (context) {
          if (isSwapProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return StreamBuilder<Object>(
                stream: swapBloc.outOrderCoin,
                builder: (context, snapshot) {
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
                    onPressed: snapshot.hasData &&
                            snapshot.connectionState ==
                                ConnectionState.active &&
                            _controllerAmount.text.isNotEmpty
                        ? _confirmSwap
                        : null,
                  );
                });
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
  var isTimeOut = false;

  @override
  void initState() {
    int timeOutSeconds = 30;
    int timeOutCurrent = 0;

    timerGetOrderbook = Timer.periodic(Duration(seconds: 5), (_) {
      print(timeOutCurrent);
      if (timeOutCurrent >= timeOutSeconds) {
        _.cancel();
        setState(() {
          isTimeOut = true;
        });
      } else {
        swapBloc.getBuyCoins(swapBloc.sellCoin.coin);
      }
      timeOutCurrent += 5;
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
            isTimeOut
                ? Container(
                    height: 16,
                  )
                : CircularProgressIndicator(),
            SizedBox(
              width: 16,
            ),
            Flexible(
              child: Text(
                isTimeOut
                    ? AppLocalizations.of(context)
                        .noOrder(swapBloc.sellCoin.coin.name)
                    : AppLocalizations.of(context).loadingOrderbook,
                style: Theme.of(context).textTheme.body1,
              ),
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

class ExchangeRate extends StatefulWidget {
  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        initialData: swapBloc.orderCoin,
        stream: swapBloc.outOrderCoin,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: <Widget>[
                Text(
                  snapshot.hasData
                      ? AppLocalizations.of(context).bestAvailableRate
                      : "",
                  style:
                      Theme.of(context).textTheme.body2.copyWith(fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      swapBloc.getExchangeRate(),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      swapBloc.getExchangeRateUSD(),
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}
