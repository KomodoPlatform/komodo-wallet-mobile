import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/progress_step.dart';
import 'package:komodo_dex/utils/utils.dart';

import 'detailed_swap_steps.dart';

class DetailedSwapStep extends StatelessWidget {
  const DetailedSwapStep({
    this.title,
    this.txHash,
    this.isStepWithTransaction,
    this.explorerUrl,
    this.status,
    this.estimatedSpeed,
    this.estimatedDeviation,
    this.actualSpeed,
    this.estimatedTotalSpeed,
    this.actualTotalSpeed,
    this.index,
  });

  final String title;
  final String txHash;
  final bool isStepWithTransaction;
  final String explorerUrl;
  final SwapStepStatus status;
  final Duration estimatedSpeed;
  final Duration estimatedDeviation;
  final Duration actualSpeed;
  final Duration estimatedTotalSpeed;
  final Duration actualTotalSpeed;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color _disabledColor = Theme.of(context).textTheme.bodyText1.color;
    final Color _accentColor = Theme.of(context).accentColor;

    Widget _buildStepStatusIcon(SwapStepStatus status) {
      Widget icon = Container();
      switch (status) {
        case SwapStepStatus.pending:
          icon = Icon(
            Icons.radio_button_unchecked,
            size: 15,
            color: _disabledColor,
          );
          break;
        case SwapStepStatus.success:
          icon = Icon(Icons.check_circle, size: 15, color: _accentColor);
          break;
        case SwapStepStatus.inProgress:
          icon = Icon(Icons.swap_horiz, size: 15, color: _accentColor);
          break;
        case SwapStepStatus.failed:
          icon =
              Icon(Icons.cancel, size: 15, color: Theme.of(context).errorColor);
          break;
        case SwapStepStatus.handled:
          icon = Icon(Icons.check_circle,
              size: 15, color: Theme.of(context).errorColor);
          break;
        default:
          {}
      }

      return Container(
        child: icon,
      );
    }

    Widget _buildViewInExplorer() {
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
              explorerUrl + 'tx/' + txHash,
            );
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(6, 2, 4, 2),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 2, 0),
                  child: Text(
                    AppLocalizations.of(context).viewInExplorerButton,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontSize: 11),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Icon(
                    Icons.open_in_browser,
                    color: Theme.of(context).accentColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildTxDetails() {
      return Padding(
        padding: EdgeInsets.fromLTRB(30, 4, 0, 0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  copyToClipBoard(context, txHash ?? '');
                  Future.delayed(Duration(seconds: 2), () {
                    Scaffold.of(context).hideCurrentSnackBar();
                  });
                },
                child: Text(
                  txHash ?? '',
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            _buildViewInExplorer(),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 8),
            _buildStepStatusIcon(status),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                        color: status == SwapStepStatus.pending
                            ? _disabledColor
                            : (status == SwapStepStatus.inProgress
                                ? _disabledColor
                                : null),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: estimatedTotalSpeed == null
                        ? Container()
                        : ProgressStep(
                            estimatedTotalSpeed: estimatedTotalSpeed,
                            actualTotalSpeed: actualTotalSpeed,
                            estimatedStepSpeed: estimatedSpeed,
                            actualStepSpeed: actualSpeed,
                          ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).swapCurrent + ': ',
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : _accentColor,
                          )),
                      Text(
                        durationFormat(actualSpeed),
                        style: TextStyle(
                          fontSize: 13,
                          color: status == SwapStepStatus.pending
                              ? _disabledColor
                              : null,
                        ),
                      ),
                      const SizedBox(width: 4),
                      estimatedSpeed == null
                          ? Container()
                          : Row(
                              children: <Widget>[
                                Text('|',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: status == SwapStepStatus.pending
                                          ? _disabledColor
                                          : null,
                                    )),
                                const SizedBox(width: 4),
                                Text(
                                    AppLocalizations.of(context).swapEstimated +
                                        ': ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: status == SwapStepStatus.pending
                                          ? _disabledColor
                                          : _accentColor,
                                    )),
                                Text(
                                  durationFormat(estimatedSpeed),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: status == SwapStepStatus.pending
                                        ? _disabledColor
                                        : null,
                                  ),
                                ),
                                estimatedDeviation == null
                                    ? Container()
                                    : Row(
                                        children: <Widget>[
                                          Text(' ±',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _disabledColor,
                                              )),
                                          Text(
                                            durationFormat(estimatedDeviation),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _disabledColor,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        //const SizedBox(height: 2),
        //if (title == 'TakerFeeSent' || title == 'TakerFeeValidated' ||
        //    title == 'MakerPaymentReceived' || title == 'MakerPaymentSent ||
        //    title == '')
        isStepWithTransaction == true && txHash != ''
            ? _buildTxDetails()
            : Container(),

        const SizedBox(height: 16),
      ],
    );
  }
}
