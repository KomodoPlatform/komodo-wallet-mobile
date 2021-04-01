import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/detailed_swap_step.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/progress_step.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

enum SwapStepStatus {
  pending,
  inProgress,
  success,
  failed,
  handled,
}

class DetailedSwapSteps extends StatefulWidget {
  const DetailedSwapSteps({this.uuid});

  final String uuid;

  @override
  _DetailedSwapStepsState createState() => _DetailedSwapStepsState();
}

class _DetailedSwapStepsState extends State<DetailedSwapSteps> {
  Swap swap;
  Timer timer;
  bool isInProgress = true;
  Duration estimatedTotalSpeed;
  Duration actualTotalSpeed;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
      if (!isInProgress) timer.cancel();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    swap = _swapProvider.swap(widget.uuid) ?? Swap();

    if (swap.status == Status.SWAP_SUCCESSFUL ||
        swap.status == Status.SWAP_FAILED) {
      setState(() {
        isInProgress = false;
      });
    }

    SwapStepStatus _getStatus(int index) {
      if (index == swap.step) return SwapStepStatus.inProgress;
      if (index < swap.step) {
        if (index > swap.result.successEvents.length) {
          return SwapStepStatus.failed;
        }
        if (swap.result.events[index].event.type ==
            swap.result.successEvents[index]) {
          return SwapStepStatus.success;
        } else {
          return SwapStepStatus.failed;
        }
      }
      return SwapStepStatus.pending;
    }

    Duration _getEstimatedSpeed(int index) {
      if (index == 0) return const Duration(seconds: 30);

      final StepSpeed stepSpeed = _swapProvider.stepSpeed(
        widget.uuid,
        swap.result.successEvents[index - 1],
        swap.result.successEvents[index],
      );
      return stepSpeed != null ? Duration(milliseconds: stepSpeed.speed) : null;
    }

    Duration _getEstimatedDeviation(int index) {
      if (index == 0) return null;

      final StepSpeed stepSpeed = _swapProvider.stepSpeed(
        widget.uuid,
        swap.result.successEvents[index - 1],
        swap.result.successEvents[index],
      );
      return stepSpeed != null
          ? Duration(milliseconds: stepSpeed.deviation)
          : null;
    }

    Duration _getActualSpeed(int index) {
      if (index == 0 && swap.result == null) return null;
      if (index > swap.step) return null;

      int fromTimestamp;
      if (index == 0) {
        // yurii: for some reason swap.result.myInfo.startedAt
        // returns seconds since epoch instead of milliseconds
        fromTimestamp = swap.result.myInfo.startedAt * 1000;
      } else {
        fromTimestamp = swap.result.events[index - 1].timestamp;
      }
      switch (_getStatus(index)) {
        case SwapStepStatus.inProgress:
          return Duration(
              milliseconds:
                  DateTime.now().millisecondsSinceEpoch - fromTimestamp);
          break;
        case SwapStepStatus.failed:
        case SwapStepStatus.success:
          final int toTimeStamp = swap.result.events[index].timestamp;
          return Duration(milliseconds: toTimeStamp - fromTimestamp);
          break;
        default:
          return null;
      }
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

    String _getTakerPaymentSpentTx(Swap swap) {
      String takerPaymentSpentID = '';
      for (SwapEL event in swap.result.events) {
        if (event.event.type == 'TakerPaymentSpent') {
          if (swap.result.type == 'Taker') {
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

    String _getTxHash(Swap swap, int i) {
      String txHash;
      (swap.isTaker)
          ? swap.result.successEvents[i] == 'TakerFeeSent'
              ? txHash = _getTakerFeeTx(swap)
              : swap.result.successEvents[i] == 'MakerPaymentReceived'
                  ? txHash = _getMakerPaymentTx(swap)
                  : swap.result.successEvents[i] == 'TakerPaymentSent'
                      ? txHash = _getTakerPaymentTx(swap)
                      : swap.result.successEvents[i] == 'TakerPaymentSpent'
                          ? txHash = _getTakerPaymentSpentTx(swap)
                          : swap.result.successEvents[i] == 'MakerPaymentSpent'
                              ? txHash = _getMakerPaymentSpentTx(swap)
                              : swap.result.successEvents[i] ==
                                      'TakerPaymentRefunded'
                                  ? txHash = _getRefundTx(swap)
                                  // ignore: unnecessary_statements
                                  : ''
          : swap.result.successEvents[i] == 'TakerFeeValidated'
              ? txHash = _getTakerFeeTx(swap)
              : swap.result.successEvents[i] == 'MakerPaymentSent'
                  ? txHash = _getMakerPaymentTx(swap)
                  : swap.result.successEvents[i] == 'TakerPaymentReceived'
                      ? txHash = _getTakerPaymentTx(swap)
                      : swap.result.successEvents[i] == 'TakerPaymentSpent'
                          ? txHash = _getTakerPaymentSpentTx(swap)
                          : swap.result.successEvents[i] ==
                                  'MakerPaymentRefunded'
                              ? txHash = _getRefundTx(swap)
                              // ignore: unnecessary_statements
                              : '';
      return txHash;
    }

    List<Widget> _buildFollowingSteps() {
      if (swap.step == 0) return [Container()];

      final List<Widget> list = [];

      int failedOnStep;
      for (int i = 0; i <= swap.step; i++) {
        if (failedOnStep != null) break;
        if (i == swap.steps) break;

        final SwapStepStatus status = _getStatus(i);

        swap.stepsWithTransaction.contains(swap.result.successEvents[i])
            ? list.add(DetailedSwapStep(
                title: swap.result.successEvents[i],
                txHash: _getTxHash(swap, i),
                explorerUrl: swap.result.successEvents[i].contains('Taker')
                    ? swap.takerExplorerUrl
                    : swap.makerExplorerUrl,
                isStepWithTransaction: swap.stepsWithTransaction
                        .contains(swap.result.successEvents[i])
                    ? true
                    : false,
                status: status,
                estimatedSpeed: _getEstimatedSpeed(i),
                estimatedDeviation: _getEstimatedDeviation(i),
                actualSpeed: _getActualSpeed(i),
                index: i,
                actualTotalSpeed: actualTotalSpeed,
                estimatedTotalSpeed: estimatedTotalSpeed,
              ))
            : list.add(DetailedSwapStep(
                title: swap.result.successEvents[i],
                status: status,
                estimatedSpeed: _getEstimatedSpeed(i),
                estimatedDeviation: _getEstimatedDeviation(i),
                actualSpeed: _getActualSpeed(i),
                index: i,
                actualTotalSpeed: actualTotalSpeed,
                estimatedTotalSpeed: estimatedTotalSpeed,
              ));
        if (i == swap.steps) break;
        if (status == SwapStepStatus.failed) {
          failedOnStep = i;
        }
      }

      if (failedOnStep != null) {
        for (int e = failedOnStep; e < swap.result.events.length; e++) {
          final String errorEventType = swap.result.events[e].event.type;
          final SwapStepStatus status =
              errorEventType.toLowerCase().contains('failed')
                  ? SwapStepStatus.failed
                  : SwapStepStatus.handled;

          list.add(DetailedSwapStep(
            title: errorEventType,
            status: status,
            actualSpeed: e == failedOnStep ? null : _getActualSpeed(e),
            index: e,
          ));
        }
      } else {}

      return list;
    }

    Widget _getSwapStatusIcon() {
      Widget icon = Container();
      switch (swap.status) {
        case Status.SWAP_SUCCESSFUL:
          icon = Icon(Icons.check_circle,
              size: 15, color: Theme.of(context).accentColor);
          break;
        case Status.ORDER_MATCHED:
        case Status.SWAP_ONGOING:
        case Status.ORDER_MATCHING:
          icon = Icon(Icons.swap_horiz,
              size: 15, color: Theme.of(context).accentColor);
          break;
        case Status.SWAP_FAILED:
          icon =
              Icon(Icons.cancel, size: 15, color: Theme.of(context).errorColor);
          break;
        default:
          icon = Icon(
            Icons.radio_button_unchecked,
            size: 15,
          );
      }

      return Container(
        child: icon,
      );
    }

    void _updateTotals() {
      if (swap.step == 0) return;

      Duration estimatedSumSpeed = const Duration(seconds: 0);
      Duration actualSumSpeed = const Duration(seconds: 0);

      for (var i = 0; i < swap.result.successEvents.length; i++) {
        final SwapStepStatus status = _getStatus(i);

        final Duration actualStepSpeed =
            _getActualSpeed(i) ?? const Duration(seconds: 0);
        actualSumSpeed = durationSum([actualSumSpeed, actualStepSpeed]);

        Duration estimatedStepSpeed = _getEstimatedSpeed(i);
        if (estimatedStepSpeed == null) {
          // If one of the steps does not have estimated speed data
          // we can not calculate total estimated swap speed
          estimatedSumSpeed = null;
          break;
        }

        if (status == SwapStepStatus.success) {
          estimatedStepSpeed = actualStepSpeed;
        } else if (status == SwapStepStatus.inProgress) {
          estimatedStepSpeed = Duration(
              milliseconds: max(actualStepSpeed.inMilliseconds,
                  estimatedStepSpeed.inMilliseconds));
        }

        estimatedSumSpeed =
            durationSum([estimatedSumSpeed, estimatedStepSpeed]);
      }

      setState(() {
        estimatedTotalSpeed = estimatedSumSpeed;
        actualTotalSpeed = actualSumSpeed;
      });
    }

    Widget _buildTotal() {
      _updateTotals();

      return Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            _getSwapStatusIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(AppLocalizations.of(context).swapTotal + ':'),
                  estimatedTotalSpeed == null
                      ? Container()
                      : ProgressStep(
                          actualTotalSpeed: actualTotalSpeed,
                          estimatedTotalSpeed: estimatedTotalSpeed,
                          actualStepSpeed: actualTotalSpeed,
                          estimatedStepSpeed: estimatedTotalSpeed,
                        ),
                  Row(
                    children: <Widget>[
                      Text(AppLocalizations.of(context).swapCurrent + ': ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).accentColor,
                          )),
                      Text(
                        durationFormat(actualTotalSpeed),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      estimatedTotalSpeed == null
                          ? Container()
                          : Row(
                              children: <Widget>[
                                const Text('|',
                                    style: TextStyle(
                                      fontSize: 13,
                                    )),
                                const SizedBox(width: 4),
                                Text(
                                    AppLocalizations.of(context).swapEstimated +
                                        ': ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).accentColor,
                                    )),
                                Text(
                                  durationFormat(estimatedTotalSpeed),
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
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
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).swapProgress + ':',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 8),
          _buildTotal(),
          const SizedBox(height: 12),
          // We assume that all kind of swaps has first step, with type of 'Started',
          // so we can show this step before actual swap data received.
          //_buildFirstStep(),
          ..._buildFollowingSteps(),
          const SizedBox(height: 12),
          Container(
            child: Text(
              _swapProvider.swapDescription(swap.result?.uuid),
              style: TextStyle(
                fontFamily: 'Monospace',
                color: Theme.of(context).accentColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
