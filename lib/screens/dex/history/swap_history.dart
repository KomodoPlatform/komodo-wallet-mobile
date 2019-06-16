import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page.dart';

class SwapHistory extends StatefulWidget {
  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  int LIMIT = 10;
  String fromUUID;
  ScrollController _scrollController = new ScrollController();
  bool isLoadingNewSwaps = false;

  @override
  void initState() {
    swapHistoryBloc.updateSwaps(LIMIT, null);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoadingNewSwaps = true;
        });
        swapHistoryBloc.updateSwaps(LIMIT, fromUUID).then((onValue) {
          setState(() {
            isLoadingNewSwaps = false;
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: swapHistoryBloc.swaps,
        builder: (context, snapshot) {
          print(snapshot.data.length);
          print(snapshot.connectionState);
          if (snapshot.hasData &&
              snapshot.data.length == 0 &&
              snapshot.connectionState == ConnectionState.active) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noSwaps,
                style: Theme.of(context).textTheme.body2,
              ),
            );
          } else if (snapshot.hasData && snapshot.data.length > 0) {
            snapshot.data.sort((b, a) {
              if (b is Swap && a is Swap) {
                if (a.result.myInfo.startedAt != null) {
                  return a.result.myInfo.startedAt
                      .compareTo(b.result.myInfo.startedAt);
                }
              }
            });
            List<Widget> swapsWidget = snapshot.data
                .map((swap) =>
                    _buildItemSwap(context, swap, snapshot.data.length))
                .toList();

            swapsWidget.add(Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Center(
                child: new Opacity(
                  opacity: isLoadingNewSwaps ? 1.0 : 00,
                  child: new CircularProgressIndicator(),
                ),
              ),
            ));

            return RefreshIndicator(
              backgroundColor: Theme.of(context).backgroundColor,
              onRefresh: _onRefresh,
              child: ListView(
                controller: _scrollController,
                children: swapsWidget,
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _buildItemSwap(BuildContext mContext, Swap swap, int length) {
    fromUUID = swap.result.uuid;
    String swapStatus =
        swapHistoryBloc.getSwapStatusString(context, swap.status);
    Color colorStatus = swapHistoryBloc.getColorStatus(swap.status);
    String stepStatus = swapHistoryBloc.getStepStatus(swap.status);
    String amountToBuy = getAmountToBuy(swap);

    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Theme.of(context).primaryColor,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SwapDetailPage(
                        swap: swap,
                      )),
            );
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildTextAmount(swap.result.myInfo.myCoin,
                        swap.result.myInfo.myAmount),
                    Expanded(
                      child: Container(),
                    ),
                    _buildIcon(swap.result.myInfo.myCoin),
                    Icon(
                      Icons.sync,
                      size: 20,
                      color: Colors.white,
                    ),
                    _buildIcon(swap.result.myInfo.otherCoin),
                    Expanded(
                      child: Container(),
                    ),
                    _buildTextAmount(swap.result.myInfo.otherCoin,
                        swap.result.myInfo.otherAmount)
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    AutoSizeText(
                      "UUID: " +
                          swap.result.uuid.substring(0, 5) +
                          "..." +
                          swap.result.uuid.substring(
                              swap.result.uuid.length - 5,
                              swap.result.uuid.length),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              swap.result.myInfo.startedAt * 1000)),
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width / 2,
                    ),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                            color: colorStatus,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(stepStatus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: Colors.white)),
                              SizedBox(
                                width: 4,
                              ),
                              Text(swapStatus,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .copyWith(
                                        color: Colors.white,
                                      ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  Future<List<Swap>> _onRefresh() async {
    return await swapHistoryBloc.updateSwaps(LIMIT, null);
  }

  _buildIcon(String coin) {
    return Container(
      height: 25,
      width: 25,
      child: Image.asset(
        "assets/${coin.toLowerCase()}.png",
        fit: BoxFit.cover,
      ),
    );
  }

  _buildTextAmount(String coin, String amount) {
    return Text(
      '${(double.parse(amount) % 1) == 0 ? double.parse(amount) : double.parse(amount).toStringAsFixed(4)} $coin',
      style: Theme.of(context).textTheme.body1,
    );
  }

  String getAmountToBuy(Swap swap) {
    return swap.result.myInfo.otherAmount;
  }
}
