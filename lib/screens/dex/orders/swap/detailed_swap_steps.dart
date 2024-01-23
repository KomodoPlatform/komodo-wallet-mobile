import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../localizations.dart';
import '../../../../model/swap.dart';
import '../../../../model/swap_provider.dart';
import '../../../../utils/utils.dart';
import '../../../dex/orders/swap/detailed_swap_step.dart';
import '../../../dex/orders/swap/progress_step.dart';

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
  bool _openSpoiler = false;

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
        if (index + 1 > swap.result.successEvents.length) {
          return SwapStepStatus.failed;
        }
        if (swap.result.successEvents
            .any((String e) => e == swap.result.events[index].event.type)) {
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
        fromTimestamp = extractStartedAtFromSwap(swap.result) * 1000;
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

    String _getTxHash(Swap swap, int i) {
      if (i > swap.result.events.length - 1) return '';
      if (i > swap.result.successEvents.length - 1) return '';

      if (swap.result.successEvents[i] != 'TakerPaymentSpent') {
        return swap.result.events[i].event.data?.txHash ?? '';
      } else {
        if (swap.isTaker) {
          return swap.result.events[i].event.data?.transaction?.txHash ?? '';
        } else {
          return swap.result.events[i].event.data?.txHash ?? '';
        }
      }
    }

    Widget _buildFirstStep() {
      return DetailedSwapStep(
        title: AppLocalizations.of(context).swapStarted,
        status: _getStatus(0),
        estimatedSpeed: _getEstimatedSpeed(0),
        estimatedDeviation: _getEstimatedDeviation(0),
        actualSpeed: _getActualSpeed(0),
        txHash: '',
        index: 0,
        actualTotalSpeed: actualTotalSpeed,
        estimatedTotalSpeed: estimatedTotalSpeed,
      );
    }

    List<Widget> _buildFollowingSteps() {
      if (swap.step == 0) return [SizedBox()];

      final List<Widget> list = [];

      int failedOnStep;
      for (int i = 1; i < swap.result.successEvents.length; i++) {
        final SwapStepStatus status = _getStatus(i);
        if (failedOnStep != null) break;
        list.add(DetailedSwapStep(
          title: swap.result.successEvents[i],
          txHash: swap.result.successEvents[i].toLowerCase().contains('taker')
              ? swap.takerCoin == null
                  ? null
                  : swap.doWeNeed0xPrefixForTaker
                      ? '0x' + _getTxHash(swap, i)
                      : _getTxHash(swap, i)
              : swap.makerCoin == null
                  ? null
                  : swap.doWeNeed0xPrefixForMaker
                      ? '0x' + _getTxHash(swap, i)
                      : _getTxHash(swap, i),
          explorerUrl:
              swap.result.successEvents[i].toLowerCase().contains('taker')
                  ? swap.takerExplorerUrl
                  : swap.makerExplorerUrl,
          coinType: swap.result.successEvents[i].toLowerCase().contains('taker')
              ? swap.takerCoin.type
              : swap.makerCoin.type,
          status: status,
          estimatedSpeed: _getEstimatedSpeed(i),
          estimatedDeviation: _getEstimatedDeviation(i),
          actualSpeed: _getActualSpeed(i),
          index: i,
          actualTotalSpeed: actualTotalSpeed,
          estimatedTotalSpeed: estimatedTotalSpeed,
        ));
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
            txHash: _getTxHash(swap, e),
            explorerUrl: errorEventType.contains('Taker')
                ? swap.takerExplorerUrl
                : swap.makerExplorerUrl,
            coinType: errorEventType.contains('Taker')
                ? swap.takerCoin.type
                : swap.makerCoin.type,
            status: status,
            actualSpeed: e == failedOnStep ? null : _getActualSpeed(e),
            index: e,
          ));
        }
      }

      return list;
    }

    Widget _getSwapStatusIcon() {
      Widget icon = SizedBox();
      switch (swap.status) {
        case Status.SWAP_SUCCESSFUL:
          icon = Icon(Icons.check_circle,
              size: 15, color: Theme.of(context).colorScheme.secondary);
          break;
        case Status.ORDER_MATCHED:
        case Status.SWAP_ONGOING:
        case Status.ORDER_MATCHING:
          icon = Icon(Icons.swap_horiz,
              size: 15, color: Theme.of(context).colorScheme.secondary);
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
                  if (estimatedTotalSpeed != null)
                    ProgressStep(
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
                            color: Theme.of(context).colorScheme.secondary,
                          )),
                      Text(
                        durationFormat(actualTotalSpeed),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      estimatedTotalSpeed == null
                          ? SizedBox()
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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

    String swapDesc = _swapProvider.swapDescription(swap.result?.uuid);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).swapProgress + ':',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 8),
          _buildTotal(),
          const SizedBox(height: 12),
          // We assume that all kind of swaps has first step,
          // with type of 'Started', so we can show this
          // step before actual swap data received.
          _buildFirstStep(),
          ..._buildFollowingSteps(),
          const SizedBox(height: 12),
          if (swap.status == Status.SWAP_FAILED) ...[
            InkWell(
              onTap: () => setState(() => _openSpoiler = !_openSpoiler),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _openSpoiler
                        ? AppLocalizations.of(context).closeMessage
                        : AppLocalizations.of(context).openMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.red),
                  ),
                  SizedBox(height: 6),
                  Icon(
                    _openSpoiler
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.red,
                    size: 20,
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      copyToClipBoard(context, swapDesc);
                    },
                    icon: Icon(Icons.copy),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),
            if (_openSpoiler) _buildSwapDesc(swapDesc),
          ] else
            _buildSwapDesc(swapDesc)
        ],
      ),
    );
  }

  _buildSwapDesc(String _swapDesc) {
    return Text(
      _swapDesc,
      style: TextStyle(
        fontFamily: 'Monospace',
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 14,
      ),
    );
  }
}
