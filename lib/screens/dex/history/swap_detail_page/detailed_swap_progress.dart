import 'package:flutter/material.dart';
import 'package:komodo_dex/model/recent_swaps.dart';
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
  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    swap = _swapProvider.swap(widget.uuid) ?? Swap();

    Widget _buildStepStatusIcon(SwapStepStatus status) {
      Widget icon = Container();
      switch (status) {
        case SwapStepStatus.pending:
          icon = Icon(Icons.radio_button_unchecked, size: 15);
          break;
        case SwapStepStatus.success:
          icon = Icon(Icons.check_circle,
              size: 15, color: Colors.lightGreenAccent);
          break;
        case SwapStepStatus.inProgress:
          icon = Container(
            width: 15,
            height: 15,
            padding: const EdgeInsets.all(1),
            child: Container(
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                )),
          );
          break;
        default:
          {}
      }

      return Container(
        child: icon,
      );
    }

    Widget _buildStep({
      String title,
      SwapStepStatus status,
      Duration estimatedTime,
      Duration actualTime,
      int index,
    }) {
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _buildStepStatusIcon(status),
              const SizedBox(width: 8),
              Text('${index + 1}. $title'),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    SwapStepStatus _getStatus(int idx) {
      if (idx == swap.step) return SwapStepStatus.inProgress;
      if (idx < swap.step) return SwapStepStatus.success;
      return SwapStepStatus.pending;
      // TODO(yurii): handle SwapStepStatus.failed
    }

    Duration _getEstimatedTime(int idx) {
      // TODO(yurii): implement estimated time
      return null;
    }

    Duration _getActualTime(int idx) {
      // TODO(yurii): implement actual time
      return null;
    }

    Widget _buildFirstStep() {
      return _buildStep(
        title: 'Started', // TODO(yurii): localization
        status: _getStatus(0),
        estimatedTime: _getEstimatedTime(0),
        actualTime: _getActualTime(0),
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
          estimatedTime: _getEstimatedTime(i),
          actualTime: _getActualTime(i),
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
        ],
      ),
    );
  }
}
