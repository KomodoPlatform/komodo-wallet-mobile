import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../generic_blocs/swap_history_bloc.dart';
import '../../../../model/error_string.dart';
import '../../../../model/recover_funds_of_swap.dart';
import '../../../../model/swap.dart';
import '../../../dex/orders/swap/swap_detail_page.dart';
import '../../../../../services/db/database.dart';
import '../../../../../utils/utils.dart';

import '../../../../localizations.dart';

class BuildItemSwap extends StatefulWidget {
  const BuildItemSwap({this.context, this.swap});

  final BuildContext? context;
  final Swap? swap;

  @override
  _BuildItemSwapState createState() => _BuildItemSwapState();
}

class _BuildItemSwapState extends State<BuildItemSwap> {
  bool recoverIsLoading = false;
  bool isNoteExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String swapStatus =
        swapHistoryBloc.getSwapStatusString(context, widget.swap!.status);
    final Color colorStatus =
        swapHistoryBloc.getColorStatus(widget.swap!.status);
    final String stepStatus = swapHistoryBloc.getStepStatus(widget.swap!.status);

    final myInfo = extractMyInfoFromSwap(widget.swap!.result!);
    final myCoin = myInfo['myCoin']!;
    final myAmount = myInfo['myAmount'];
    final otherCoin = myInfo['otherCoin']!;
    final otherAmount = myInfo['otherAmount'];
    final startedAt = extractStartedAtFromSwap(widget.swap!.result!)!;

    return Card(
        child: InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: () => Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => SwapDetailPage(
            swap: widget.swap,
          ),
        ),
      ),
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
                              myCoin,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            _buildIcon(myCoin),
                          ],
                        ),
                        Text(
                          formatPrice(myAmount, 8)!,
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
                            _buildIcon(otherCoin),
                            const SizedBox(width: 4),
                            Text(
                              otherCoin,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Text(
                          formatPrice(otherAmount, 8)!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                FutureBuilder<String?>(
                    future: Db.getNote(widget.swap!.result!.uuid),
                    builder:
                        (BuildContext context, AsyncSnapshot<String?> snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox();
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            isNoteExpanded = !isNoteExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  snapshot.data!,
                                  style: Theme.of(context).textTheme.bodyText1,
                                  maxLines: isNoteExpanded ? null : 1,
                                  overflow: isNoteExpanded
                                      ? null
                                      : TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              startedAt * 1000)),
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(),
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
                                    .caption!
                                    .copyWith(color: Colors.white)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(swapStatus,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                      color: Colors.white,
                                    ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                if (widget.swap!.result!.recoverable)
                  recoverIsLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                              height: 25,
                              width: 25,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              )))
                      : Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 16),
                          child: TextButton(
                            onPressed: () async {
                              // recover call
                              setState(() {
                                recoverIsLoading = true;
                              });
                              swapHistoryBloc
                                  .recoverFund(widget.swap!)
                                  .then((dynamic result) {
                                if (result is RecoverFundsOfSwap) {
                                  showMessage(
                                      context,
                                      AppLocalizations.of(context)!
                                          .unlockSuccess(result.result!.coin!,
                                              result.result!.txHash!));
                                } else if (result is ErrorString) {
                                  showErrorMessage(context, result.error);
                                }
                              }).then(((_) => setState(() {
                                        recoverIsLoading = false;
                                      })) as FutureOr<_> Function(Null));
                            },
                            style: TextButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              backgroundColor:
                                  const Color.fromRGBO(191, 191, 191, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.unlockFunds),
                          ),
                        ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildIcon(String coin) {
    return SizedBox(
      height: 25,
      width: 25,
      child: Image.asset(
        getCoinIconPath(coin),
        fit: BoxFit.cover,
      ),
    );
  }

  String? getAmountToBuy(Swap swap) {
    final myInfo = extractMyInfoFromSwap(widget.swap!.result!);
    final otherAmount = myInfo['otherAmount'];
    return otherAmount;
  }
}
