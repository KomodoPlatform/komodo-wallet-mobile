import 'package:flutter/material.dart';

class ProgressStep extends StatefulWidget {
  const ProgressStep({
    @required this.estimatedTotalSpeed,
    @required this.actualTotalSpeed,
    this.estimatedStepSpeed,
    this.actualStepSpeed,
  });

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
    double getEstimatedShare() {
      if (widget.estimatedStepSpeed == null) {
        return 0;
      }

      return widget.estimatedStepSpeed.inMilliseconds /
          widget.estimatedTotalSpeed.inMilliseconds;
    }

    double getActualShare() {
      if (widget.estimatedStepSpeed == null || widget.actualStepSpeed == null) {
        return 0;
      }

      return widget.actualStepSpeed.inMilliseconds /
          widget.estimatedTotalSpeed.inMilliseconds;
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
        const SizedBox(height: 1),
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
