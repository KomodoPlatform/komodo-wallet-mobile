import 'package:flutter/material.dart';

class ProgressStep extends StatefulWidget {
  const ProgressStep({
    @required this.estimatedTotalSpeed,
    @required this.actualTotalSpeed,
    @required this.estimatedStepSpeed,
    @required this.actualStepSpeed,
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

      double share = widget.estimatedStepSpeed.inMilliseconds /
          widget.estimatedTotalSpeed.inMilliseconds;
      if (share < 0.01) share = 0.01;
      if (share > 1) share = 1;
      return share;
    }

    double getActualShare() {
      if (widget.estimatedStepSpeed == null || widget.actualStepSpeed == null) {
        return 0;
      }

      double share = widget.actualStepSpeed.inMilliseconds /
          widget.estimatedTotalSpeed.inMilliseconds;
      if (share < 0.01) share = 0.01;
      if (share > 1) share = 1;
      return share;
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 3),
        Stack(
          children: <Widget>[
            Container(
              color: Theme.of(context).dialogBackgroundColor,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FractionallySizedBox(
                    widthFactor: getEstimatedShare(),
                    child: Container(
                      height: 2,
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                  ),
                ],
              ),
            ),
            FractionallySizedBox(
              widthFactor: getActualShare(),
              child: Container(
                height: 2,
                color: Theme.of(context).accentColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 3),
          ],
        ),
        const SizedBox(height: 3),
      ],
    );
  }
}
