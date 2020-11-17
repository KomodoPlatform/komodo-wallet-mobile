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
          child: Text(
            '${AppLocalizations.of(context).tradeDetail}:',
            style: Theme.of(context).textTheme.subtitle.copyWith(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 4),
          child: Text(
            '${AppLocalizations.of(context).requestedTrade}:',
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
        _buildAmountSwap(),
        Padding(
            padding: const EdgeInsets.only(top: 24),
            child: _buildInfo(
                AppLocalizations.of(context).swapID, widget.swap.result.uuid)),
        widget.swap.status == Status.SWAP_SUCCESSFUL &&
                swapHistoryBloc.isAnimationStepFinalIsFinish
            ? _buildInfosDetail()
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$title:',
                      style: Theme.of(context).textTheme.body2,
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
                          style: Theme.of(context).textTheme.body1.copyWith(
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
                  Db.saveNote(widget.swap.result.uuid,
                      noteText.isNotEmpty ? noteText : null);

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

  Widget _buildInfosDetail() {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildInfo(AppLocalizations.of(context).takerpaymentsID,
                _getTakerpaymentID(widget.swap))),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildInfo(AppLocalizations.of(context).makerpaymentID,
                _getMakerpaymentID(widget.swap))),
      ],
    );
  }

  String _getTakerpaymentID(Swap swap) {
    String takerpaymentID = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'TakerPaymentSent') {
        takerpaymentID = event.event.data.txHash;
      } else if (event.event.type == 'TakerPaymentSpent') {
        takerpaymentID = event.event.data.txHash;
      }
    }
    return takerpaymentID;
  }

  String _getMakerpaymentID(Swap swap) {
    String makepaymentID = '';
    for (SwapEL event in swap.result.events) {
      if (event.event.type == 'MakerPaymentSpent') {
        makepaymentID = event.event.data.txHash;
      } else if (event.event.type == 'MakerPaymentSent') {
        makepaymentID = event.event.data.txHash;
      }
    }
    return makepaymentID;
  }

  Widget _buildInfo(String title, String id) {
    return InkWell(
      onTap: () {
        copyToClipBoard(context, id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$title:',
                style: Theme.of(context).textTheme.body2,
              ),
            ),
            Text(
              id,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
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
                    .body2
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
              _buildTextAmount(widget.swap.result.myInfo.otherCoin,
                  widget.swap.result.myInfo.otherAmount),
              Text(
                '${AppLocalizations.of(context).receive[0].toUpperCase()}${AppLocalizations.of(context).receive.substring(1)}',
                style: Theme.of(context)
                    .textTheme
                    .body2
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
      '${(double.parse(amount) % 1) == 0 ? double.parse(amount) : double.parse(amount).toStringAsFixed(4)} $coin',
      style: Theme.of(context)
          .textTheme
          .body1
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
