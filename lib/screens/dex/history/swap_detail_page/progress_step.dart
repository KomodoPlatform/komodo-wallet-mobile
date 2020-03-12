import 'dart:math';

import 'package:flutter/material.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:provider/provider.dart';

class ProgressStep extends StatefulWidget {
  const ProgressStep({
    @required this.uuid,
    @required this.estimatedTotalSpeed,
    @required this.actualTotalSpeed,
    this.step,
    this.estimatedStepSpeed,
    this.actualStepSpeed,
  });

  final String uuid;
  final int step;
  final Duration estimatedTotalSpeed;
  final Duration actualTotalSpeed;
  final Duration estimatedStepSpeed;
  final Duration actualStepSpeed;

  @override
  _ProgressStepState createState() => _ProgressStepState();
}

class _ProgressStepState extends State<ProgressStep> {
  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    final Swap swap = _swapProvider.swap(widget.uuid);

    double _getStepShare() {
      final int stepMilliseconds = max(
        widget.estimatedStepSpeed.inMilliseconds,
        widget.actualStepSpeed.inMilliseconds,
      );

      double share =
          stepMilliseconds / widget.estimatedTotalSpeed.inMilliseconds;
      if (share < 0.01) share = 0.01;
      return share;
    }

    double getEstimatedShare() {
      if (widget.estimatedStepSpeed == null) {
        return 0;
      }
      
      return (widget.estimatedStepSpeed.inMilliseconds /
              widget.estimatedTotalSpeed.inMilliseconds);
    }

    double getActualShare() {
      if (widget.estimatedStepSpeed == null || widget.actualStepSpeed == null) {
        return 0;
      }
      
      return (widget.actualStepSpeed.inMilliseconds /
              widget.estimatedTotalSpeed.inMilliseconds);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 3),
        FractionallySizedBox(
          widthFactor: getActualShare(),
          child: Container(
            height: 1,
            color: Theme.of(context).accentColor,
          ),
        ),
        SizedBox(height: 1),
        Container(
          color: Theme.of(context).dialogBackgroundColor,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: getEstimatedShare(),
                child: Container(
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
      ],
    );
  }
}
