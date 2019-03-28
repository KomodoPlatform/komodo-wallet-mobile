import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/swap.dart';

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
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.length == 0) {
            return Center(
              child: Text(
                "No Swaps",
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
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: swaps.length,
              itemBuilder: (BuildContext context, int index) {
                Swap swap = swaps[index];
                String swapStatus = getSwapStatusString(swap.status);
                Color colorStatus = getColorStatus(swap.status);
                String stepStatus = getStepStatus(swap.status);
                String amountToBuy = getAmountToBuy(swap);

                return Card(
                    elevation: 8.0,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Theme.of(context).primaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      onTap: () {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content: new Text(
                              AppLocalizations.of(context).commingsoonGeneral),
                        ));
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            children: <Widget>[
                              Expanded(
                                child: Container(),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24)),
                                    color: colorStatus,
                                  ),
                                  child: Row(
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
                              )
                            ],
                          )
                        ],
                      ),
                    ));
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
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

  String getSwapStatusString(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return AppLocalizations.of(context).orderMatching;
        break;
      case Status.ORDER_MATCHED:
        return AppLocalizations.of(context).orderMatched;
        break;
      case Status.SWAP_ONGOING:
        return AppLocalizations.of(context).swapOngoing;
        break;
      case Status.SWAP_SUCCESSFUL:
        return AppLocalizations.of(context).swapSucceful;
        break;
      case Status.TIME_OUT:
        return AppLocalizations.of(context).timeOut;
        break;
      default:
    }
    return "";
  }

  Color getColorStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return Colors.orangeAccent;
        break;
      case Status.ORDER_MATCHED:
        return Colors.orangeAccent;
        break;
      case Status.SWAP_ONGOING:
        return Colors.orangeAccent;
        break;
      case Status.SWAP_SUCCESSFUL:
        return Colors.green.shade500;
        break;
      case Status.TIME_OUT:
        return Colors.redAccent;
        break;
      default:
    }
    return Colors.redAccent;
  }

  String getStepStatus(Status status) {
    switch (status) {
      case Status.ORDER_MATCHING:
        return "0/3";
        break;
      case Status.ORDER_MATCHED:
        return "1/3";
        break;
      case Status.SWAP_ONGOING:
        return "2/3";
        break;
      case Status.SWAP_SUCCESSFUL:
        return "✓";
        break;
      case Status.TIME_OUT:
        return "";
        break;
      default:
    }
    return "";
  }

  String getAmountToBuy(Swap swap) => swap.uuid.amountToBuy.toString();
}
