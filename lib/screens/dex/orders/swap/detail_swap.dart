import 'package:flutter/material.dart';
import '../../../../app_config/app_config.dart';
import '../../../../blocs/camo_bloc.dart';
import '../../../../localizations.dart';
import '../../../../model/swap.dart';
import '../../../dex/orders/swap/detailed_swap_steps.dart';
import '../../../dex/orders/swap/swap_detail_note.dart';
import '../../../../utils/utils.dart';

class DetailSwap extends StatefulWidget {
  const DetailSwap({@required this.swap});

  final Swap swap;

  @override
  _DetailSwapState createState() => _DetailSwapState();
}

class _DetailSwapState extends State<DetailSwap> {
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
                      color: Theme.of(context).colorScheme.secondary,
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
        SwapDetailNote(widget.swap.result.uuid),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _buildInfo(
            AppLocalizations.of(context).swapUUID,
            widget.swap.result.uuid,
          ),
        ),
        const SizedBox(
          height: 8,
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

  Widget _buildInfo(
    String title,
    String id,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title + ':',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          InkWell(
            onTap: () => copyToClipBoard(context, id),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child:
                        Text(id, style: Theme.of(context).textTheme.bodyText2),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAmountSwap() {
    final myInfo = extractMyInfoFromSwap(widget.swap.result);
    final myCoin = myInfo['myCoin'];
    final myAmount = myInfo['myAmount'];
    final otherCoin = myInfo['otherCoin'];
    final otherAmount = myInfo['otherAmount'];

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(flex: 1),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(flex: 1),
          },
          children: [
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: _buildTextAmount(myCoin, myAmount),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Row(
                    children: [
                      _buildIcon(myCoin),
                      Icon(Icons.sync, size: 20),
                      _buildIcon(otherCoin),
                    ],
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: _buildTextAmount(otherCoin, otherAmount,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
            TableRow(
              children: [
                Text(
                  AppLocalizations.of(context).sell.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.w400),
                ),
                SizedBox(),
                Text(
                  AppLocalizations.of(context).receive.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontWeight: FontWeight.w400),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildTextAmount(String coin, String amount,
      {TextAlign textAlign = TextAlign.left}) {
    // Only apply camouflage to swap history,
    // show current active swaps as is
    final bool shouldCamouflage = camoBloc.isCamoActive &&
        (widget.swap.status == Status.SWAP_SUCCESSFUL ||
            widget.swap.status == Status.SWAP_FAILED ||
            widget.swap.status == Status.TIME_OUT);

    if (shouldCamouflage) {
      amount = (double.parse(amount) * camoBloc.camoFraction / 100).toString();
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            cutTrailingZeros(double.parse(amount)
                    .toStringAsFixed(appConfig.tradeFormPrecision)) +
                ' ' +
                coin,
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: textAlign,
          ),
        )
      ],
    );
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
}
