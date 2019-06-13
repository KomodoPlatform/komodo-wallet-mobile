import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/order_coin.dart';
import 'package:komodo_dex/screens/dex/trade/swap_confirmation_page.dart';
import 'package:komodo_dex/utils/decimal_text_input_formatter.dart';
import 'package:komodo_dex/widgets/primary_button.dart';
import 'package:komodo_dex/widgets/secondary_button.dart';

class TradeNewPage extends StatefulWidget {
  @override
  _TradeNewPageState createState() => _TradeNewPageState();
}

class _TradeNewPageState extends State<TradeNewPage>
    with TickerProviderStateMixin {
  TextEditingController _controllerAmountSell = new TextEditingController();
  TextEditingController _controllerAmountReceive = new TextEditingController();
  CoinBalance currentCoinBalance;
  Coin currentCoinToBuy;
  String tmpText = "";
  FocusNode _focusSell = new FocusNode();
  FocusNode _focusReceive = new FocusNode();
  Animation<double> animation;
  AnimationController controller;
  String amountToBuy;
  bool enabledReceiceField = false;

  @override
  void initState() {
    super.initState();

    if (coinsBloc.coinBalance != null && coinsBloc.coinBalance.length > 1) {
      swapBloc.updateSellCoin(coinsBloc.coinBalance.first);
    } else {
      swapBloc.updateSellCoin(null);
    }
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);

    _controllerAmountReceive.clear();
    _controllerAmountSell.addListener(onChangeSell);
    _controllerAmountReceive.addListener(onChangeReceive);

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  void onChangeReceive() {
    setState(() {});
  }

  void onChangeSell() {
    swapBloc.updateBuyCoin(null);
    // _controllerAmountReceive.text = "";
    setState(() {});
    String text = _controllerAmountSell.text;
    if (text.isNotEmpty) {
      setState(() {
        if (currentCoinBalance != null &&
            double.parse(text.replaceAll(",", ".")) >
                double.parse(currentCoinBalance.balance.balance)) {
          setMaxValue();
        } else {
          if (text.contains(
              RegExp("^\$|^(0|([1-9][0-9]{0,3}))([.,]{1}[0-9]{0,8})?\$"))) {
          } else {
            _controllerAmountSell.text = tmpText;
            _unfocusFocus();
          }
        }
      });
    }
  }

  void _unfocusFocus() async {
    _focusSell.unfocus();
    await Future.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        FocusScope.of(context).requestFocus(_focusSell);
      });
    });
  }

  void setMaxValue() async {
    _focusSell.unfocus();
    setState(() {
      var txFee = currentCoinBalance.coin.txfee;
      var fee;
      if (txFee == null) {
        fee = 0;
      } else {
        fee = (txFee.toDouble() / 100000000);
      }
      _controllerAmountSell
          .text = ((double.parse(currentCoinBalance.balance.balance) -
                  (double.parse(currentCoinBalance.balance.balance) * 0.01)) -
              fee)
          .toStringAsFixed(8);
    });
    await Future.delayed(const Duration(milliseconds: 0), () {
      setState(() {
        FocusScope.of(context).requestFocus(_focusSell);
      });
    });
  }

  @override
  void dispose() {
    _controllerAmountSell.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16),
      children: <Widget>[_buildExchange(), ExchangeRate(), _buildButton()],
    );
  }

  _buildExchange() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            FadeTransition(
              opacity: animation,
              child: _buildCard(Market.SELL),
            ),
            _buildCard(Market.RECEIVE)
          ],
        ),
        Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(32)),
              color: Theme.of(context).backgroundColor,
            ),
            child: SvgPicture.asset(
              "assets/icon_swap.svg",
              height: 40,
            ))
      ],
    );
  }

  _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: StreamBuilder<CoinBalance>(
          initialData: swapBloc.sellCoin,
          stream: swapBloc.outSellCoin,
          builder: (context, sellCoin) {
            return StreamBuilder<Coin>(
                initialData: swapBloc.receiveCoin,
                stream: swapBloc.outReceiveCoin,
                builder: (context, receiveCoin) {
                  return PrimaryButton(
                    onPressed: _controllerAmountSell.text.length > 0 &&
                            _controllerAmountReceive.text.length > 0 &&
                            sellCoin.hasData &&
                            receiveCoin.hasData
                        ? _confirmSwap
                        : null,
                    text: AppLocalizations.of(context).trade,
                  );
                });
          }),
    );
  }

  _buildCard(Market market) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 8,
        margin: EdgeInsets.all(8),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                market == Market.SELL
                    ? AppLocalizations.of(context).sell
                    : AppLocalizations.of(context).receiveLower,
                style: Theme.of(context).textTheme.body2,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                        scrollPadding: EdgeInsets.only(left: 35),
                        inputFormatters: [
                          DecimalTextInputFormatter(decimalRange: 8),
                          WhitelistingTextInputFormatter(RegExp(
                              "^\$|^(0|([1-9][0-9]{0,12}))([.,]{1}[0-9]{0,8})?\$"))
                        ],
                        focusNode:
                            market == Market.SELL ? _focusSell : _focusReceive,
                        controller: market == Market.SELL
                            ? _controllerAmountSell
                            : _controllerAmountReceive,
                        enabled: market == Market.RECEIVE
                            ? enabledReceiceField
                            : true,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: Theme.of(context).textTheme.title,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                            hintText: market == Market.SELL
                                ? AppLocalizations.of(context).amountToSell
                                : "")),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: 130,
                    child: _buildCoinSelect(market),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildCoinSelect(Market market) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () async {
        if (enabledReceiceField && market == Market.RECEIVE) {
          await _openDialogAllCoins();
        } else {
          if (_controllerAmountSell.text.isEmpty && market == Market.RECEIVE) {
            setState(() {
              FocusScope.of(context).requestFocus(_focusSell);
              controller.reset();
              controller.forward();
            });
          } else {
            _openDialogCoinWithBalance(market);
          }
        }
      },
      child: enabledReceiceField && market == Market.RECEIVE
          ? Container(
              child: StreamBuilder<Coin>(
                initialData: swapBloc.receiveCoin,
                stream: swapBloc.outReceiveCoin,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildSelectorCoin(snapshot.data);
                  } else {
                    return _buildSelectorCoin(null);
                  }
                },
              ),
            )
          : StreamBuilder<dynamic>(
              initialData: market == Market.SELL
                  ? swapBloc.sellCoin
                  : swapBloc.orderCoin,
              stream: market == Market.SELL
                  ? swapBloc.outSellCoin
                  : swapBloc.outOrderCoin,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data is CoinBalance) {
                  CoinBalance coinBalance = snapshot.data;
                  currentCoinBalance = coinBalance;
                  return _buildSelectorCoin(coinBalance.coin);
                } else if (snapshot.hasData && snapshot.data is OrderCoin) {
                  OrderCoin orderCoin = snapshot.data;
                  return _buildSelectorCoin(orderCoin.coinBase);
                } else {
                  return _buildSelectorCoin(null);
                }
              }),
    );
  }

  _buildSelectorCoin(Coin coin) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 19,
        ),
        Row(
          children: <Widget>[
            coin != null
                ? Image.asset(
                    "assets/${coin.abbr.toLowerCase()}.png",
                    height: 25,
                  )
                : CircleAvatar(
                    backgroundColor: Theme.of(context).accentColor,
                    radius: 12,
                  ),
            Expanded(
                child: Center(
                    child: Text(
              coin != null ? coin.abbr : "-",
              style: Theme.of(context).textTheme.subtitle,
              maxLines: 1,
            ))),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Container(
          color: Colors.grey,
          height: 1,
          width: double.infinity,
        )
      ],
    );
  }

  _openDialogAllCoins() async {
    List<Coin> coins = await coinsBloc.readJsonCoin();
    Coin coinToRemove = swapBloc.sellCoin.coin;

    int indexToRemove = 0;
    coins.asMap().forEach((index, c) {
      if (c.abbr == coinToRemove.abbr) {
        indexToRemove = index;
      }
    });
    coins.removeAt(indexToRemove);
    dialogBloc.dialog = showDialog<List<Coin>>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context).receiveLower),
            children: coins.map((item) {
              return InkWell(
                onTap: () {
                  swapBloc.updateReceiveCoin(item);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 16,
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset(
                          "assets/${item.abbr.toLowerCase()}.png",
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }).then((_) {
      dialogBloc.dialog = null;
    });
  }

  _openDialogCoinWithBalance(Market market) async {
    if (market == Market.RECEIVE) {
      if (swapBloc.sellCoin != null && swapBloc.sellCoin.coin != null) {
        swapBloc.getBuyCoins(swapBloc.sellCoin.coin);
      }
    }
    List<SimpleDialogOption> listDialogCoins =
        _createListDialog(context, market, null);

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
                        return DialogLooking(
                          onMakeOrder: () {
                            setState(() {
                              enabledReceiceField = true;
                            });
                            FocusScope.of(this.context)
                                .requestFocus(_focusReceive);
                          },
                        );
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
    if (orderbooks != null && market == Market.RECEIVE) {
      orderbooks.forEach((orderbooks) {
        if (orderbooks.coinBase.abbr != swapBloc.sellCoin.coin.abbr &&
            double.parse(orderbooks.getBuyAmount(double.parse(
                    _controllerAmountSell.text.replaceAll(",", ".")))) >
                0) {
          SimpleDialogOption dialogItem = SimpleDialogOption(
            onPressed: () {
              setState(() {});
              if (_controllerAmountSell.text.isNotEmpty) {
                amountToBuy = orderbooks.getBuyAmount(double.parse(
                    _controllerAmountSell.text.replaceAll(",", ".")));
                _controllerAmountReceive.text = amountToBuy;
              }
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
                        _controllerAmountSell.text.replaceAll(",", ".")))),
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
        if (double.parse(coin.balance.balance) > 0) {
          SimpleDialogOption dialogItem = SimpleDialogOption(
            onPressed: () {
              _controllerAmountReceive.text = "";
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

  _confirmSwap() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SwapConfirmation(
                amountToSell: _controllerAmountSell.text,
                amountToBuy: amountToBuy,
              )),
    ).then((_) {
      _controllerAmountReceive.clear();
      _controllerAmountSell.clear();
    });
  }
}

enum Market {
  SELL,
  RECEIVE,
}

class DialogLooking extends StatefulWidget {
  final Function onMakeOrder;

  const DialogLooking({Key key, this.onMakeOrder}) : super(key: key);

  @override
  _DialogLookingState createState() => _DialogLookingState();
}

class _DialogLookingState extends State<DialogLooking> {
  var timerGetOrderbook;
  var isTimeOut = false;

  @override
  void initState() {
    int timeOutSeconds = 1;
    int timeOutCurrent = 0;

    setState(() {
      isTimeOut = true;
    });
    timerGetOrderbook = Timer.periodic(Duration(seconds: 5), (_) {
      print(timeOutCurrent);
      if (timeOutCurrent >= timeOutSeconds - 5) {
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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: isTimeOut
            ? _buildSellDialogContent()
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: isTimeOut
                        ? Container(
                            height: 16,
                          )
                        : CircularProgressIndicator(),
                  ),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context).loadingOrderbook,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  )
                ],
              ),
      ),
    );
  }

  _buildSellDialogContent() {
    return Wrap(
      direction: Axis.horizontal,
      children: <Widget>[
        Text(
          AppLocalizations.of(context).noOrder(swapBloc.sellCoin.coin.name),
          style: Theme.of(context).textTheme.subtitle,
        ),
        Container(
          height: 16,
        ),
        PrimaryButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onMakeOrder();
            // disabled the input
            // display in real time the price exchange
            // go to confirmation with tag SELL
          },
          text: AppLocalizations.of(context).makeAorder,
        ),
        Container(
          height: 8,
        ),
        SecondaryButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          text: AppLocalizations.of(context).cancel,
        ),
      ],
    );
  }
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
