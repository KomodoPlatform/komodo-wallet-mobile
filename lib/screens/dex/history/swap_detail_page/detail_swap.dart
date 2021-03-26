import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/camo_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/detailed_swap_steps.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/utils.dart';

class DetailSwap extends StatefulWidget {
  const DetailSwap({@required this.swap});

  final Swap swap;

  @override
  _DetailSwapState createState() => _DetailSwapState();
}

class _DetailSwapState extends State<DetailSwap> {
  String noteText;
  bool isNoteEdit = false;
  bool isNoteExpanded = false;
  final noteTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Db.getNote(widget.swap.result.uuid).then((n) {
      setState(() {
        noteText = n;
        noteTextController.text = noteText;
      });
    });
  }

  @override
  void dispose() {
    noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: const Color.fromARGB(255, 52, 62, 76),
          height: 1,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).tradeDetail + ':',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _buildMakerTakerBadge(widget.swap.result.type == 'Maker'),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 4),
          child: Text(
            AppLocalizations.of(context).requestedTrade + ':',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        _buildAmountSwap(),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: _buildInfo(
            AppLocalizations.of(context).swapUUID,
            widget.swap.result.uuid,
          ),
        ),
        widget.swap.status == Status.SWAP_SUCCESSFUL ||
                swapHistoryBloc.isAnimationStepFinalIsFinish
            ? _buildAdditionalInfoDetails()
            : Container(),
        _buildNote(AppLocalizations.of(context).noteTitle),
        const SizedBox(
          height: 32,
        ),
        DetailedSwapSteps(uuid: widget.swap.result.uuid),
        const SizedBox(
          height: 32,
        ),
      ],
    );
  }

  Widget _buildMakerTakerBadge(bool isMaker) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(
          color: Theme.of(context).textTheme.caption.color.withAlpha(100),
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Text(
          isMaker
              ? AppLocalizations.of(context).makerOrder
              : AppLocalizations.of(context).takerOrder,
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  Widget _buildNote(String title) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: isNoteEdit
                ? null
                : () {
                    if (noteText != null && noteText.isNotEmpty) {
                      setState(() {
                        isNoteExpanded = !isNoteExpanded;
                      });
                    }
                  },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 0, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      title + ':',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  isNoteEdit
                      ? TextField(
                          decoration: const InputDecoration(isDense: true),
                          controller: noteTextController,
                          maxLength: 200,
                          maxLines: 7,
                          minLines: 1,
                        )
                      : Text(
                          (noteText == null || noteText.isEmpty)
                              ? AppLocalizations.of(context).notePlaceholder
                              : noteText,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          maxLines: isNoteExpanded ? null : 1,
                          overflow:
                              isNoteExpanded ? null : TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(isNoteEdit ? Icons.check : Icons.edit),
          onPressed: () {
            setState(
              () {
                if (isNoteEdit) {
                  noteTextController.text = noteTextController.text.trim();
                  noteText = noteTextController.text;

                  noteText.isNotEmpty
                      ? Db.saveNote(widget.swap.result.uuid, noteText)
                      : Db.deleteNote(widget.swap.result.uuid);

                  setState(() {
                    isNoteExpanded = false;
                  });
                }

                setState(() {
                  isNoteEdit = !isNoteEdit;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoDetails() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildInfo(
            AppLocalizations.of(context).takerFeeTx,
            _getTakerFeeTx(widget.swap),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildInfo(
            AppLocalizations.of(context).takerPaymentTx,
            _getTakerPaymentTx(widget.swap),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildInfo(
            AppLocalizations.of(context).makerPaymentTx,
            _getMakerPaymentTx(widget.swap),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildInfo(
            AppLocalizations.of(context).takerPaymentSpentTx,
            _getTakerPaymentSpentTx(widget.swap),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildInfo(
            AppLocalizations.of(context).makerPaymentSpentTx,
            _getMakerPaymentSpentTx(widget.swap),
          ),
        ),
        widget.swap.result.status == Status.SWAP_FAILED
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildInfo(
                  widget.swap.result.type == 'Maker'
                      ? AppLocalizations.of(context).makerPaymentRefundTx
                      : AppLocalizations.of(context).takerPaymentRefundTx,
                  _getRefundTx(widget?.swap),
                ),
              )
            : Container()
      ],
    );
  }

  String _getTakerFeeTx(Swap swap) {
    String takerFeeTx = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'TakerFeeSent') {
        // taker-swap
        takerFeeTx = event.event.data.txHash;
      } else if (event.event.type == 'TakerFeeValidated') {
        // maker-swap
        takerFeeTx = event.event.data.txHash;
      }
    }
    return takerFeeTx;
  }

  String _getTakerPaymentTx(Swap swap) {
    String takerPaymentTx = '';
    for (SwapEL event in swap.result.events) {
      if (event?.event?.type == 'TakerPaymentSent') {
        // taker-swap
        takerPaymentTx = event.event.data.txHash;
      } else if (event.event.type == 'TakerPaymentReceived') {
        // maker-swap
        takerPaymentTx = event.event.data.txHash;
      }
    }
    return takerPaymentTx;
  }

  String _getMakerPaymentTx(Swap swap) {
    String makerPaymentTx = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'MakerPaymentReceived') {
        // taker-swap
        makerPaymentTx = event.event.data.txHash;
      } else if (event.event.type == 'MakerPaymentSent') {
        // maker-swap
        makerPaymentTx = event.event.data.txHash;
      }
    }
    return makerPaymentTx;
  }

  String _getTakerPaymentSpentTx(Swap swap) {
    String takerPaymentSpentID = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'TakerPaymentSpent') {
        if (widget.swap.result.type == 'Taker') {
          // taker-swap
          takerPaymentSpentID = event.event.data.transaction.txHash;
        } else {
          // maker-swap
          takerPaymentSpentID = event.event.data.txHash;
        }
      }
    }
    return takerPaymentSpentID;
  }

  String _getMakerPaymentSpentTx(Swap swap) {
    String makerPaymentSpentTx = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'MakerPaymentSpent') {
        makerPaymentSpentTx = event.event.data.txHash;
      }
    }
    return makerPaymentSpentTx;
  }

  String _getRefundTx(Swap swap) {
    String refundTx = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'MakerPaymentRefunded' ||
          event.event.type == 'TakerPaymentRefunded') {
        refundTx = event.event.data.txHash;
      }
    }
    return refundTx;
  }

  Widget _buildViewInExplorer(String id, String title) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(
            color: Color.fromARGB(0, 0, 0, 0),
            width: 0,
          ),
        ),
        child: InkWell(
          onTap: () {
            launchURL(
              title.contains('Maker')
                  ? widget.swap.makerCoin.explorerUrl.elementAt(0) + 'tx/' + id
                  : widget.swap.takerCoin.explorerUrl.elementAt(0) + 'tx/' + id,
            );
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 2, 4, 2),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 2, 4),
                  child: Text(
                    AppLocalizations.of(context).viewInExplorerButton,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(
                    Icons.open_in_browser,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildInfo(
    String title,
    String id,
  ) {
    return (widget.swap.result.type == 'Maker' &&
                title == 'Maker Payment Spent Tx') ||
            id == ''
        ? Container()
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        title + ':',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      title == 'Swap UUID'
                          ? Container()
                          : _buildViewInExplorer(
                              id,
                              title,
                            )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    copyToClipBoard(
                      context,
                      id,
                    );
                  },
                  child: Text(
                    id,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                )
              ],
            ),
          );
  }

  Widget _buildAmountSwap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextAmount(widget.swap.result.myInfo.myCoin,
                  widget.swap.result.myInfo.myAmount),
              Text(
                AppLocalizations.of(context).sell,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.w400),
              )
            ],
          ),
          Expanded(
            child: Container(),
          ),
          _buildIcon(widget.swap.result.myInfo.myCoin),
          Icon(
            Icons.sync,
            size: 20,
            color: Colors.white,
          ),
          _buildIcon(widget.swap.result.myInfo.otherCoin),
          Expanded(
            child: Container(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _buildTextAmount(
                widget.swap.result.myInfo.otherCoin,
                widget.swap.result.myInfo.otherAmount,
              ),
              Text(
                AppLocalizations.of(context).receive.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontWeight: FontWeight.w400),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextAmount(String coin, String amount) {
    // Only apply camouflage to swap history,
    // show current active swaps as is
    final bool shouldCamouflage = camoBloc.isCamoActive &&
        (widget.swap.status == Status.SWAP_SUCCESSFUL ||
            widget.swap.status == Status.SWAP_FAILED ||
            widget.swap.status == Status.TIME_OUT);

    if (shouldCamouflage) {
      amount = (double.parse(amount) * camoBloc.camoFraction / 100).toString();
    }

    return Text(
      (double.parse(amount) % 1) == 0
          ? double.parse(amount).toString() + ' ' + coin
          : double.parse(amount).toStringAsFixed(4) + ' ' + coin,
      style: Theme.of(context)
          .textTheme
          .bodyText2
          .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
    );
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
}
