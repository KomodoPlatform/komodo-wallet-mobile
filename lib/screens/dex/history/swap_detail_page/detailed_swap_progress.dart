import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
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
    final Color _disabledColor = Theme.of(context).textTheme.body2.color;
    final Color _accentColor = Theme.of(context).accentColor;

    if (swap.status == Status.SWAP_SUCCESSFUL ||
        swap.status == Status.SWAP_FAILED) {
      setState(() {
        isInProgress = false;
      });
    }

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
        default:
          {}
      }

      return Container(
        child: icon,
      );
    }

    SwapStepStatus _getStatus(int index) {
      if (index == swap.step) return SwapStepStatus.inProgress;
      if (index < swap.step) return SwapStepStatus.success;
      return SwapStepStatus.pending;
      // TODO(yurii): handle SwapStepStatus.failed
    }

    String _formatSpeed(Duration duration) {
      if (duration == null) return '-';

      final int hh = duration.inHours;
      final int mm = duration.inMinutes;
      final int ss = duration.inSeconds;
      final int ms = duration.inMilliseconds;

      if (ms < 1000) return '${ms}ms';

      String formatted = '';
      if (ss.remainder(60) > 0) {
        formatted = '${ss.remainder(60)}s';
      }
      if (mm > 0) {
        formatted = '${mm.remainder(60)}m ' + formatted;
      }
      if (hh > 0) {
        formatted = '${hh.remainder(60)}h ' + formatted;
      }

      return formatted;
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

    Widget _buildStep({
      String title,
      SwapStepStatus status,
      Duration estimatedSpeed,
      Duration actualSpeed,
      int index,
    }) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildStepStatusIcon(status),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                        color: status == SwapStepStatus.pending
                            ? _disabledColor
                            : null,
                      )),
                  Row(
                    children: <Widget>[
                      Text('act: ', // TODO(yurii): localization
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : _accentColor,
                          )),
                      Text(
                        _formatSpeed(actualSpeed),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Text('|',
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : null,
                          )),
                      const SizedBox(width: 4),
                      Text('est: ', // TODO(yurii): localization
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : _accentColor,
                          )),
                      Text(
                        _formatSpeed(estimatedSpeed),
                        style: TextStyle(
                          fontSize: 13,
                          color: status == SwapStepStatus.pending
                              ? _disabledColor
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    Widget _buildFirstStep() {
      return _buildStep(
        title: 'Started', // TODO(yurii): localization
        status: _getStatus(0),
        estimatedSpeed: _getEstimatedSpeed(0),
        actualSpeed: _getActualSpeed(0),
        index: 0,
      );
    }

    List<Widget> _buildFollowingSteps() {
      if (swap.step == 0) return [Container()];

      final List<Widget> list = [];

      for (int i = 1; i < swap.result.successEvents.length; i++) {
        list.add(_buildStep(
          title: swap.result.successEvents[i], // TODO(yurii): localization
          status: _getStatus(i),
          estimatedSpeed: _getEstimatedSpeed(i),
          actualSpeed: _getActualSpeed(i),
          index: i,
        ));
      }

      return list;
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
                color: _accentColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
