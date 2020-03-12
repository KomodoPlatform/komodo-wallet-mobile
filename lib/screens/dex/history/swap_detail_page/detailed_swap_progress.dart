import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/detailed_swap_step.dart';
import 'package:komodo_dex/utils/utils.dart';
import 'package:provider/provider.dart';

enum SwapStepStatus {
  pending,
  inProgress,
  success,
  failed,
}

class DetailedSwapProgress extends StatefulWidget {
  const DetailedSwapProgress({this.uuid});

  final String uuid;

  @override
  _DetailedSwapProgressState createState() => _DetailedSwapProgressState();
}

class _DetailedSwapProgressState extends State<DetailedSwapProgress> {
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
      if (index < swap.step) return SwapStepStatus.success;
      return SwapStepStatus.pending;
      // TODO(yurii): handle SwapStepStatus.failed
    }

    Duration _getEstimatedSpeed(int index) {
      if (index == 0) return null;

      final StepSpeed stepSpeed = _swapProvider.stepSpeed(
        widget.uuid,
        swap.result.successEvents[index - 1],
        swap.result.successEvents[index],
      );
      return Duration(milliseconds: stepSpeed.speed);
    }

    Duration _getActualSpeed(int index) {
      if (index == 0) return null; // TODO(yurii): calculate first step speed
      if (index > swap.step) return null;

      final int fromTimestamp = swap.result.events[index - 1].timestamp;
      switch (_getStatus(index)) {
        case SwapStepStatus.inProgress:
          return Duration(
              milliseconds:
                  DateTime.now().millisecondsSinceEpoch - fromTimestamp);
          break;
        case SwapStepStatus.success:
          final int toTimeStamp = swap.result.events[index].timestamp;
          return Duration(milliseconds: toTimeStamp - fromTimestamp);
          break;
        default:
          return null;
      }
    }

    Widget _buildFirstStep() {
      return DetailedSwapStep(
        title: 'Started', // TODO(yurii): localization
        status: _getStatus(0),
        estimatedSpeed: _getEstimatedSpeed(0),
        actualSpeed: _getActualSpeed(0),
        index: 0,
        actualTotalSpeed: actualTotalSpeed,
        estimatedTotalSpeed: estimatedTotalSpeed,
      );
    }

    List<Widget> _buildFollowingSteps() {
      if (swap.step == 0) return [Container()];

      final List<Widget> list = [];

      for (int i = 1; i < swap.result.successEvents.length; i++) {
        list.add(DetailedSwapStep(
          title: swap.result.successEvents[i], // TODO(yurii): localization
          status: _getStatus(i),
          estimatedSpeed: _getEstimatedSpeed(i),
          actualSpeed: _getActualSpeed(i),
          index: i,
          actualTotalSpeed: actualTotalSpeed,
          estimatedTotalSpeed: estimatedTotalSpeed,
        ));
      }

      return list;
    }

    Widget _buildTotal() {
      if (swap.step > 0) {
        Duration estimatedSumSpeed = const Duration(seconds: 0);
        Duration actualSumSpeed = const Duration(seconds: 0);

        for (var i = 0; i < swap.result.successEvents.length; i++) {
          final SwapStepStatus status = _getStatus(i);

          final Duration actualStepSpeed =
              _getActualSpeed(i) ?? const Duration(seconds: 0);

          Duration estimatedStepSpeed =
              _getEstimatedSpeed(i) ?? const Duration(seconds: 0);
          if (status == SwapStepStatus.success) {
            estimatedStepSpeed = actualStepSpeed;
          } else if (status == SwapStepStatus.inProgress) {
            estimatedStepSpeed = Duration(
                milliseconds: max(actualStepSpeed.inMilliseconds,
                    estimatedStepSpeed.inMilliseconds));
          }

          estimatedSumSpeed =
              durationSum([estimatedSumSpeed, estimatedStepSpeed]);
          actualSumSpeed = durationSum([actualSumSpeed, actualStepSpeed]);
        }

        setState(() {
          estimatedTotalSpeed = estimatedSumSpeed;
          actualTotalSpeed = actualSumSpeed;
        });
      }

      return Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).dialogBackgroundColor,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Total:'), // TODO(yurii): localization
                  Row(
                    children: <Widget>[
                      Text('act: ', // TODO(yurii): localization
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).accentColor,
                          )),
                      Text(
                        durationFormat(actualTotalSpeed),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      const Text('|',
                          style: TextStyle(
                            fontSize: 13,
                          )),
                      const SizedBox(width: 4),
                      Text('est: ', // TODO(yurii): localization
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
            ),
            const SizedBox(height: 13),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Progress details:', // TODO(yurii): localization
            style: Theme.of(context).textTheme.body2,
          ),
          const SizedBox(height: 8),
          _buildTotal(),
          // We assume that all kind of swaps has first step, with type of 'Started',
          // so we can show this step before actual swap data received.
          _buildFirstStep(),
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
