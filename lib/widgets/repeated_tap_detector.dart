import 'package:flutter/material.dart';

/// A widget which detects if a user repeatedly taps on a widget.
///
///
/// [child] The widget to be wrapped by the repeated tap detector.
/// [tapTriggerCount] The number of taps required to trigger the [onRepeatedTap] callback.
/// [onRepeatedTap] The callback to be triggered when the user taps on the widget [tapTriggerCount] times.
/// [cooldown] The maximum time in milliseconds between taps to be considered a repeated tap.
class RepeatedTapDetector extends StatefulWidget {
  const RepeatedTapDetector({
    Key key,
    @required this.child,
    @required this.tapTriggerCount,
    @required this.onRepeatedTap,
    this.cooldown = const Duration(seconds: 1),
  }) : super(key: key);

  final Widget child;
  final int tapTriggerCount;
  final VoidCallback onRepeatedTap;
  final Duration cooldown;

  @override
  _RepeatedTapDetectorState createState() => _RepeatedTapDetectorState();
}

class _RepeatedTapDetectorState extends State<RepeatedTapDetector> {
  int _tapCount = 0;
  DateTime _lastTapTime;

  bool get _isCooldownExpired =>
      _lastTapTime != null &&
      DateTime.now().difference(_lastTapTime) > widget.cooldown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(
            'RepeatedTapDetector: onTap. _tapCount: $_tapCount, _isCooldownExpired: $_isCooldownExpired');
        if (_tapCount == 0 || _isCooldownExpired) {
          _resetLastTap();
        }
        _tapCount++;
        if (_tapCount == widget.tapTriggerCount) {
          widget.onRepeatedTap?.call();
          _tapCount = 0;
        }

        _lastTapTime = DateTime.now();
      },
      child: widget.child,
    );
  }

  void _resetLastTap() {
    _lastTapTime = DateTime.now();
    _tapCount = 0;
  }
}
