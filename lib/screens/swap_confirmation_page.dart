import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komodo_dex/blocs/swap_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/buy_response.dart';
import 'package:komodo_dex/screens/lock_screen.dart';
import 'package:komodo_dex/screens/media_page.dart';
import 'package:komodo_dex/screens/swap_detail_page.dart';
import 'package:komodo_dex/screens/swap_page.dart';
import 'package:komodo_dex/services/market_maker_service.dart';

class SwapConfirmation extends StatefulWidget {
  final String amountToSell;
  final String amountToBuy;

  SwapConfirmation({this.amountToSell, this.amountToBuy});

  @override
  _SwapConfirmationState createState() => _SwapConfirmationState();
}

class _SwapConfirmationState extends State<SwapConfirmation> {
  bool isSwapMaking = false;

  @override
  Widget build(BuildContext context) {
    return LockScreen(
      child: WillPopScope(
        onWillPop: () {
          swapBloc.updateSellCoin(null);
          swapBloc.updateBuyCoin(null);
          Navigator.pop(context);
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            leading: InkWell(
                onTap: () {
                  swapBloc.updateSellCoin(null);
                  swapBloc.updateBuyCoin(null);
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
                      padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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

    mm2
        .postBuy(swapBloc.orderCoin.coinBase, swapBloc.orderCoin.coinRel,
            amountToSell, swapBloc.orderCoin.bestPrice * 1.01)
        .then((onValue) {
      if (onValue is BuyResponse) {
        // swapHistoryBloc.saveUUID(
        //     onValue.result.uuid,
        //     swapBloc.orderCoin.coinBase,
        //     swapBloc.orderCoin.coinRel,
        //     amountToSell,
        //     double.parse(swapBloc.orderCoin.getBuyAmount(amountToSell)));
        swapHistoryBloc.updateSwaps(10, null).then((data) {
          swapHistoryBloc.swaps.forEach((swap) {
            if (swap.uuid.uuid == onValue.result.uuid) {
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
    });
  }
}
