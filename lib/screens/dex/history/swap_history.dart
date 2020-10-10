import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/error_string.dart';
import 'package:komodo_dex/model/recover_funds_of_swap.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/swap_detail_page.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:komodo_dex/model/swap_provider.dart';

class SwapHistory extends StatefulWidget {
  @override
  _SwapHistoryState createState() => _SwapHistoryState();
}

class _SwapHistoryState extends State<SwapHistory> {
  String fromUUID;
  final ScrollController _scrollController = ScrollController();
  bool isLoadingNewSwaps = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Log('swap_history:31', 'scrolling down');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: syncSwaps.swaps,
        builder:
            (BuildContext context, AsyncSnapshot<Iterable<Swap>> snapshot) {
          final List<Swap> swaps = snapshot.data.toList();

          swaps.removeWhere((Swap swap) =>
              swap.result.myInfo == null ||
              (swap.status != Status.SWAP_FAILED &&
                  swap.status != Status.SWAP_SUCCESSFUL &&
                  swap.status != Status.TIME_OUT));
          if (snapshot.data != null &&
              swaps.isEmpty &&
              snapshot.connectionState == ConnectionState.active) {
            return Center(
              child: Text(
                AppLocalizations.of(context).noSwaps,
                style: Theme.of(context).textTheme.body2,
              ),
            );
          } else if (snapshot.data != null && swaps.isNotEmpty) {
            swaps.sort((Swap b, Swap a) {
              if (b is Swap && a is Swap) {
                if (a.result.myInfo.startedAt != null) {
                  return a.result.myInfo.startedAt
                      .compareTo(b.result.myInfo.startedAt);
                }
              }
              return 0;
            });

            final List<Widget> swapsWidget = swaps
                .map((Swap swap) => BuildItemSwap(context: context, swap: swap))
                .toList();

            return RefreshIndicator(
              backgroundColor: Theme.of(context).backgroundColor,
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(8),
                controller: _scrollController,
                children: swapsWidget,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future<Iterable<Swap>> _onRefresh() async => syncSwaps.swaps;
}

class BuildItemSwap extends StatefulWidget {
  const BuildItemSwap({this.context, this.swap});

  final BuildContext context;
  final Swap swap;

  @override
  _BuildItemSwapState createState() => _BuildItemSwapState();
}

class _BuildItemSwapState extends State<BuildItemSwap> {
  bool recoverIsLoading = false;

  @override
  Widget build(BuildContext context) {
    final String swapStatus =
        swapHistoryBloc.getSwapStatusString(context, widget.swap.status);
    final Color colorStatus =
        swapHistoryBloc.getColorStatus(widget.swap.status);
    final String stepStatus = swapHistoryBloc.getStepStatus(widget.swap.status);

    return Card(
        child: InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: () {
        Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => SwapDetailPage(
                    swap: widget.swap,
                  )),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              widget.swap.result.myInfo.myCoin,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 2),
                            _buildIcon(widget.swap.result.myInfo.myCoin),
                          ],
                        ),
                        Text(
                          '${formatPrice(widget.swap.result.myInfo.myAmount, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Icon(Icons.swap_horiz),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _buildIcon(widget.swap.result.myInfo.otherCoin),
                            const SizedBox(width: 2),
                            Text(
                              widget.swap.result.myInfo.otherCoin,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Text(
                          '${formatPrice(widget.swap.result.myInfo.otherAmount, 8)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                FutureBuilder<String>(
                    future: Db.getNote(widget.swap.result.uuid),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(snapshot.data),
                      );
                    }),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              widget.swap.result.myInfo.startedAt * 1000)),
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
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
                            const SizedBox(
                              width: 4,
                            ),
                            Text(swapStatus,
                                style:
                                    Theme.of(context).textTheme.body2.copyWith(
                                          color: Colors.white,
                                        ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                if (widget.swap.result.recoverable)
                  recoverIsLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                              height: 25,
                              width: 25,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              )))
                      : Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 16),
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            color: const Color.fromRGBO(191, 191, 191, 1),
                            child: Text(
                              'Unlock Funds',
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () async {
                              // recover call
                              setState(() {
                                recoverIsLoading = true;
                              });
                              swapHistoryBloc
                                  .recoverFund(widget.swap)
                                  .then((dynamic result) {
                                if (result is RecoverFundsOfSwap) {
                                  showMessage(
                                      context,
                                      'Successfully unlocked ' +
                                          result.result.coin +
                                          ' funds - TX: ' +
                                          result.result.txHash);
                                } else if (result is ErrorString) {
                                  showErrorMessage(context, result.error);
                                }
                              }).then((_) => setState(() {
                                        recoverIsLoading = false;
                                      }));
                            },
                          )),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildIcon(String coin) {
    return Container(
      height: 25,
      width: 25,
      child: Image.asset(
        'assets/${coin.toLowerCase()}.png',
        fit: BoxFit.cover,
      ),
    );
  }

  String getAmountToBuy(Swap swap) {
    return swap.result.myInfo.otherAmount;
  }
}
