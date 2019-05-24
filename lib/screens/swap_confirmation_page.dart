import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/screens/lock_screen.dart';
import 'package:komodo_dex/screens/media_page.dart';
import 'package:komodo_dex/screens/swap_detail_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

class SwapConfirmation extends StatefulWidget {
  final String amountToSell;
  final String amountToBuy;

  SwapConfirmation({this.amountToSell, this.amountToBuy});

  @override
  _SwapConfirmationState createState() => _SwapConfirmationState();
}

class _SwapConfirmationState extends State<SwapConfirmation> {
  @override
  void dispose() {
    swapBloc.updateSellCoin(null);
    swapBloc.updateBuyCoin(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LockScreen(
          child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(),
        body: Column(
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
            ),
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
                            height: 125,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
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
                            height: 125,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
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
                    left: (MediaQuery.of(context).size.width / 2) - 64,
                    top: 101,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 48),
                          color: Theme.of(context).backgroundColor,
                          child: Icon(
                            Icons.swap_vert,
                            size: 32,
                          )),
                    ))
              ],
            ),
            Expanded(child: SizedBox()),
            RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(AppLocalizations.of(context).confirm.toUpperCase()),
              onPressed: () => _makeASwap(),
            ),
            SizedBox(height: 8,),
            FlatButton(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: Text(AppLocalizations.of(context).cancel.toUpperCase()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Expanded(child: SizedBox()),
            Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).backgroundColor,
                      height: 32,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32)),
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 48, horizontal: 32),
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
        ),
      ),
    );
  }

  _makeASwap() {
    double amountToSell =
        double.parse(widget.amountToSell.replaceAll(",", "."));

    mm2
        .postBuy(swapBloc.orderCoin.coinBase, swapBloc.orderCoin.coinRel,
            amountToSell, swapBloc.orderCoin.bestPrice * 1.01)
        .then((onValue) {
      if (onValue is BuyResponse && onValue.result == "success") {
        swapHistoryBloc.saveUUID(
            onValue.pending.uuid,
            swapBloc.orderCoin.coinBase,
            swapBloc.orderCoin.coinRel,
            amountToSell,
            double.parse(swapBloc.orderCoin.getBuyAmount(amountToSell)));
        swapHistoryBloc.updateSwap().then((data) {
          swapHistoryBloc.swaps.forEach((swap) {
            if (swap.uuid.uuid == onValue.pending.uuid) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SwapDetailPage(
                          swap: swap,
                        )),
              );
            }
          });
        });
      } else {
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
    });
  }
}
