import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/setprice_response.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/authentification/lock_screen.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page.dart';
import 'package:komodo_dex/screens/dex/trade/trade_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

enum SwapStatus { BUY, SELL }

class SwapConfirmation extends StatefulWidget {
  final SwapStatus swapStatus;
  final String amountToSell;
  final String amountToBuy;
  final Function orderSuccess;

  SwapConfirmation(
      {this.amountToSell,
      this.amountToBuy,
      @required this.swapStatus,
      this.orderSuccess});

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      child: WillPopScope(
        onWillPop: () {
          _resetSwapPage();
          Navigator.pop(context);
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

  _resetSwapPage() {
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    swapBloc.updateReceiveCoin(null);
    swapBloc.enabledReceiveField = false;
  }

  _buildTitle() {
    return Column(
      children: <Widget>[
        SizedBox(
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
        SizedBox(
          height: 24,
        )
      ],
    );
  }

  _buildCoinSwapDetail() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
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
                              '${widget.amountToSell} ${swapBloc.orderCoin.coinRel.abbr}',
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
                SizedBox(
                  height: 2,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
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
                              '${widget.amountToBuy} ${swapBloc.orderCoin.coinBase.abbr}',
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
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      color: Theme.of(context).backgroundColor,
                      child: SvgPicture.asset("assets/icon_swap.svg")),
                ))
          ],
        )
      ],
    );
  }

  _buildInfoSwap() {
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
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                      child: Column(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).infoTrade1,
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          SizedBox(
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
                  borderRadius: BorderRadius.all(Radius.circular(52)),
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

  _buildButtons() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        isSwapMaking
            ? CircularProgressIndicator()
            : RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text(AppLocalizations.of(context).confirm.toUpperCase()),
                onPressed: isSwapMaking ? null : _makeASwap,
              ),
        SizedBox(
          height: 8,
        ),
        FlatButton(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Text(AppLocalizations.of(context).cancel.toUpperCase()),
          onPressed: () {
            swapBloc.updateSellCoin(null);
            swapBloc.updateBuyCoin(null);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  _makeASwap() {
    setState(() {
      isSwapMaking = true;
    });
    double amountToSell =
        double.parse(widget.amountToSell.replaceAll(",", "."));
    double amountToBuy = (amountToSell *
        (amountToSell / (amountToSell * swapBloc.orderCoin.bestPrice)));
    Coin coinBase = swapBloc.orderCoin.coinBase;
    Coin coinRel = swapBloc.orderCoin.coinRel;
    double price = swapBloc.orderCoin.bestPrice * 1.01;

    if (widget.swapStatus == SwapStatus.BUY) {
      mm2.postBuy(coinBase, coinRel, amountToBuy, price).then(
          (onValue) => _goToNextScreen(onValue, amountToSell, amountToBuy));
    } else if (widget.swapStatus == SwapStatus.SELL) {
      mm2.postSell(coinRel, coinBase, amountToSell, swapBloc.orderCoin.bestPrice).then(
          (onValue) => _goToNextScreen(onValue, amountToSell, amountToBuy));
    }
  }

  _goToNextScreen(dynamic onValue, double amountToSell, double amountToBuy) {
    if (onValue is BuyResponse) {
      if (widget.swapStatus == SwapStatus.BUY) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SwapDetailPage(
                    swap: new Swap(
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
    } else {
      setState(() {
        isSwapMaking = false;
      });
      String timeSecondeLeft = onValue.error;
      print(timeSecondeLeft);
      timeSecondeLeft = timeSecondeLeft.substring(
          timeSecondeLeft.lastIndexOf(" "), timeSecondeLeft.length);
      print(timeSecondeLeft);
      Scaffold.of(context).showSnackBar(new SnackBar(
        duration: Duration(seconds: 2),
        content: new Text(AppLocalizations.of(context)
            .buySuccessWaitingError(timeSecondeLeft)),
      ));
    }
  }
}
