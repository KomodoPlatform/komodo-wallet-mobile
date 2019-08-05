import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page.dart';
import 'package:komodo_dex/screens/dex/trade/trade_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

enum SwapStatus { BUY, SELL }

class SwapConfirmation extends StatefulWidget {
  const SwapConfirmation(
      {@required this.bestPrice,
      @required this.coinBase,
      @required this.coinRel,
      @required this.amountToSell,
      @required this.amountToBuy,
      @required this.swapStatus,
      this.orderSuccess});

  final SwapStatus swapStatus;
  final String amountToSell;
  final String amountToBuy;
  final Function orderSuccess;
  final String bestPrice;
  final Coin coinBase;
  final Coin coinRel;

  @override
  _SwapConfirmationState createState() => _SwapConfirmationState();
}

class _SwapConfirmationState extends State<SwapConfirmation> {
  bool isSwapMaking = false;

  @override
  void dispose() {
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.setEnabledSellField(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      context: context,
      child: WillPopScope(
        onWillPop: () {
          _resetSwapPage();
          Navigator.pop(context);
          return;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  _resetSwapPage();
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back)),
          ),
          body: ListView(
            children: <Widget>[
              _buildTitle(),
              _buildCoinSwapDetail(),
              ExchangeRate(),
              _buildButtons(),
              _buildInfoSwap()
            ],
          ),
        ),
      ),
    );
  }

  void _resetSwapPage() {
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.enabledReceiveField = false;
  }

  Widget _buildTitle() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 24,
        ),
        Text(
          AppLocalizations.of(context).swapDetailTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .title
              .copyWith(color: Theme.of(context).accentColor),
        ),
        const SizedBox(
          height: 24,
        )
      ],
    );
  }

  Widget _buildCoinSwapDetail() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    child: Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.white.withOpacity(0.15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${widget.amountToSell} ${widget?.coinRel?.abbr}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.title,
                            ),
                            Text(AppLocalizations.of(context).sell,
                                style:
                                    Theme.of(context).textTheme.body1.copyWith(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w100,
                                        ))
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    child: Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.white.withOpacity(0.15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${widget.amountToBuy} ${widget.coinBase.abbr}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.title,
                            ),
                            Text(
                                AppLocalizations.of(context)
                                        .receive
                                        .substring(0, 1) +
                                    AppLocalizations.of(context)
                                        .receive
                                        .toLowerCase()
                                        .substring(1),
                                style:
                                    Theme.of(context).textTheme.body1.copyWith(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w100,
                                        ))
                          ],
                        )),
                  ),
                ),
              ],
            ),
            Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 43,
                top: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      color: Theme.of(context).backgroundColor,
                      child: SvgPicture.asset('assets/icon_swap.svg')),
                ))
          ],
        )
      ],
    );
  }

  Widget _buildInfoSwap() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  color: Theme.of(context).backgroundColor,
                  height: 32,
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 32),
                      child: Column(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).infoTrade1,
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            AppLocalizations.of(context).infoTrade2,
                            style: Theme.of(context).textTheme.body1,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
                left: 32,
                top: 8,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(52)),
                  child: Container(
                    height: 52,
                    width: 52,
                    color: Theme.of(context).backgroundColor,
                    child: Icon(
                      Icons.info,
                      size: 48,
                    ),
                  ),
                )),
          ],
        )
      ],
    );
  }

  Widget _buildButtons() {
    return Builder(builder: (BuildContext context) {
      return Column(
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          isSwapMaking
              ? const CircularProgressIndicator()
              : RaisedButton(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child:
                      Text(AppLocalizations.of(context).confirm.toUpperCase()),
                  onPressed: isSwapMaking ? null : () => _makeASwap(context),
                ),
          const SizedBox(
            height: 8,
          ),
          FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Text(AppLocalizations.of(context).cancel.toUpperCase()),
            onPressed: () {
              swapBloc.updateSellCoin(null);
              swapBloc.updateBuyCoin(null);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  Future<void> _makeASwap(BuildContext mContext) async {
    setState(() {
      isSwapMaking = true;
    });

    final Coin coinBase = widget.coinBase;
    final Coin coinRel = widget.coinRel;
    String price = '0';

    try {
      final Orderbook orderbook = await mm2.getOrderbook(coinBase, coinRel);
      double maxVolume = 0;
      int i = 0;

      for (Ask ask in orderbook.asks) {
        if (ask.address != swapBloc.sellCoin.balance.address) {
          if (i == 0) {
            maxVolume = ask.maxvolume;
            price = ask.price;
          } else if (Decimal.parse(ask.price) <= Decimal.parse(price) &&
              ask.maxvolume > maxVolume) {
            maxVolume = ask.maxvolume;
            price = ask.price;
          }
          i++;
        }
      }
    } catch (e) {
      print(e.toString());
    }

    final String amountToSell = widget.amountToSell.replaceAll(',', '.');
    final Decimal satoshi = Decimal.parse('100000000');
    final Decimal satoshiSellAmount =
        Decimal.parse(widget.amountToSell.replaceAll(',', '.')) * satoshi;
    Decimal satoshiBuyAmount = price != '0'
        ? Decimal.parse((Decimal.parse(amountToSell) / Decimal.parse(price))
                .toStringAsFixed(8)) *
            satoshi
        : Decimal.parse(Decimal.parse(widget.amountToBuy).toStringAsFixed(8)) *
            satoshi;
    final Decimal satoshiPrice = price != '0'
        ? Decimal.parse(Decimal.parse(price).toStringAsFixed(8)) * satoshi
        : Decimal.parse(Decimal.parse(widget.bestPrice).toStringAsFixed(8)) *
            satoshi;

    //if the desired sellamount != calculated sellamount this loop fixes the precision errors caused by the above division
    //this is considered a dirty quickfix until a final decision is made ref. num handling - likely should follow @ArtemGr's
    //advice ref. utilizing rational datatype IF we need divisions. We do assume sellamount slightly > calculated_sell_amount isnt an issue
    //since swap is going to match - the other way around its problematic
    //this code needs a full refactor
    while (price != '0' &&
        Decimal.parse((satoshiBuyAmount * satoshiPrice / satoshi)
                .toStringAsFixed(0)) <
            satoshiSellAmount) {
      satoshiBuyAmount += Decimal.parse('1');
    }

    if (widget.swapStatus == SwapStatus.BUY) {
      mm2
          .postBuy(coinBase, coinRel, satoshiBuyAmount / satoshi,
              (satoshiPrice / satoshi).toString())
          .then((BuyResponse onValue) => _goToNextScreen(
              mContext, onValue, amountToSell, satoshiBuyAmount / satoshi))
          .catchError((dynamic onError) => _catchErrorSwap(mContext, onError));
    } else if (widget.swapStatus == SwapStatus.SELL) {
      mm2
          .postSetPrice(coinRel, coinBase, amountToSell,
              Decimal.parse(widget.bestPrice).toStringAsFixed(8), false, false)
          .then((SetPriceResponse onValue) => _goToNextScreen(
              mContext,
              onValue,
              amountToSell,
              Decimal.parse(
                  Decimal.parse(widget.amountToBuy).toStringAsFixed(8))))
          .catchError((dynamic onError) => _catchErrorSwap(mContext, onError));
    }
  }

  void _catchErrorSwap(BuildContext mContext, ErrorString error) {
    setState(() {
      isSwapMaking = false;
    });
    String timeSecondeLeft = error.error;
    print(timeSecondeLeft);
    timeSecondeLeft = timeSecondeLeft.substring(
        timeSecondeLeft.lastIndexOf(' '), timeSecondeLeft.length);
    print(timeSecondeLeft);
    String errorDisplay =
        error.error.substring(error.error.lastIndexOf(r']') + 1).trim();
    if (error.error.contains('is too low, required')) {
      errorDisplay = AppLocalizations.of(context).notEnoughtBalanceForFee;
    }
    Scaffold.of(mContext).showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: Theme.of(context).errorColor,
      content: Text(errorDisplay),
    ));
  }

  void _goToNextScreen(BuildContext mContext, dynamic onValue,
      String amountToSell, Decimal amountToBuy) {
    ordersBloc.updateOrdersSwaps();
    swapHistoryBloc.updateSwaps(50, null);

    if (widget.swapStatus == SwapStatus.BUY) {
      Navigator.pushReplacement<dynamic, dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SwapDetailPage(
                  swap: Swap(
                      status: Status.ORDER_MATCHING,
                      result: ResultSwap(
                        uuid: onValue.result.uuid,
                        myInfo: MyInfo(
                            myAmount: amountToSell.toString(),
                            otherAmount: amountToBuy.toString(),
                            myCoin: onValue.result.rel,
                            otherCoin: onValue.result.base,
                            startedAt: DateTime.now().millisecondsSinceEpoch),
                      )),
                )),
      );
    } else if (widget.swapStatus == SwapStatus.SELL) {
      Navigator.of(context).pop();
      widget.orderSuccess();
    }
  }
}
