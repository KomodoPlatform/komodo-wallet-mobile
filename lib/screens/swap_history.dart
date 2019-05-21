import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/swap_detail_page.dart';

class SwapHistory extends StatefulWidget {
  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  @override
  void initState() {
    swapHistoryBloc.updateSwap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: swapHistoryBloc.swaps,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length == 0) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noSwaps,
                style: Theme.of(context).textTheme.body2,
              ),
            );
          }
          if (snapshot.hasData && snapshot.data.length > 0) {
            List<Swap> swaps = snapshot.data;
            swaps.sort((b, a) {
              if (a.uuid.timeStart != null) {
                return a.uuid.timeStart.compareTo(b.uuid.timeStart);
              }
            });
            return RefreshIndicator(
              backgroundColor: Theme.of(context).backgroundColor,
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: swaps.length,
                itemBuilder: (BuildContext context, int index) {
                  Swap swap = swaps[index];
                  String swapStatus =
                      swapHistoryBloc.getSwapStatusString(context, swap.status);
                  Color colorStatus =
                      swapHistoryBloc.getColorStatus(swap.status);
                  String stepStatus =
                      swapHistoryBloc.getStepStatus(swap.status);
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
                              padding:
                                  EdgeInsets.only(top: 16, left: 16, right: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  _buildTextAmount(swap.uuid.rel, amountToBuy),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  _buildIcon(swap.uuid.rel),
                                  Icon(
                                    Icons.sync,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  _buildIcon(swap.uuid.base),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  _buildTextAmount(swap.uuid.base,
                                      swap.uuid.amountToGet.toString())
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  AutoSizeText(
                                    "UUID: " +
                                        swap.uuid.uuid.substring(1, 5) +
                                        "..." +
                                        swap.uuid.uuid.substring(
                                            swap.uuid.uuid.length - 5,
                                            swap.uuid.uuid.length),
                                    maxLines: 1,
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    DateFormat('dd MMM yyyy HH:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            swap.uuid.timeStart * 1000)),
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
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2,
                                  ),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24)),
                                          color: colorStatus,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(stepStatus,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    .copyWith(
                                                        color: Colors.white)),
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
                },
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<Null> _onRefresh() async {
    return await swapHistoryBloc.updateSwap();
  }

  _buildIcon(Coin coin) {
    return Container(
      height: 25,
      width: 25,
      child: Image.asset(
        "assets/${coin.abbr.toLowerCase()}.png",
        fit: BoxFit.cover,
      ),
    );
  }

  _buildTextAmount(Coin coin, String amount) {
    return Text(
      '${(double.parse(amount) % 1) == 0 ? double.parse(amount) : double.parse(amount).toStringAsFixed(4)} ${coin.abbr}',
      style: Theme.of(context).textTheme.body1,
    );
  }

  String getAmountToBuy(Swap swap) => swap.uuid.amountToBuy.toString();
}
