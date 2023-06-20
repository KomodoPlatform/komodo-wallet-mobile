import 'package:meta/meta.dart';

// Define the mixin class for ETA calculation
mixin ActivationEta {
  final List<_ActivationEntry> _activationEntries = [];

  Duration calculateETA(double progress) {
    _activationEntries.add(_ActivationEntry(
      progress: progress,
      timeStamp: DateTime.now(),
    ));

    final hasEnoughEntries = _activationEntries.length >= 6 &&
        _activationEntries.first.timeStamp
                .difference(_activationEntries.last.timeStamp)
                .inSeconds
                .abs() >
            50;

    _activationEntries.retainWhere((entry) {
      final elapsedSeconds =
          DateTime.now().difference(entry.timeStamp).inSeconds;
      return elapsedSeconds <= 60 || !hasEnoughEntries;
    });

    if (!hasEnoughEntries) {
      return null;
    }

    final sumDeltaProgress = _activationEntries
        .sublist(0, _activationEntries.length - 1)
        .map((entry) => (entry.progress -
                _activationEntries[_activationEntries.indexOf(entry) + 1]
                    .progress)
            .abs())
        .reduce((a, b) => a + b);

    final sumDeltaSeconds = _activationEntries
        .sublist(0, _activationEntries.length - 1)
        .map((entry) => entry.timeStamp
            .difference(
                _activationEntries[_activationEntries.indexOf(entry) + 1]
                    .timeStamp)
            .inSeconds
            .abs())
        .reduce((a, b) => a + b);

    final averageChangePerSecond = sumDeltaProgress /
        _activationEntries.first.timeStamp
            .difference(_activationEntries.last.timeStamp)
            .inSeconds
            .abs();

    if (averageChangePerSecond == 0 ||
        averageChangePerSecond == double.infinity) {
      return null;
    }

    final remainingProgress = 1 - _activationEntries.last.progress;

    if (remainingProgress <= 0) {
      return Duration.zero;
    }

    final remainingSeconds = remainingProgress / averageChangePerSecond;

    return Duration(seconds: remainingSeconds.toInt());
  }
}

class _ActivationEntry {
  _ActivationEntry({@required this.progress, @required this.timeStamp});

  final double progress;
  final DateTime timeStamp;
}
