import 'package:komodo_dex/utils/log.dart';
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

    double averageChangePerSecond = 0;

    if (_activationEntries.length > 1) {
      try {
        final sumDeltaProgress = _activationEntries
            .sublist(0, _activationEntries.length - 1)
            .map((entry) => (entry.progress -
                    _activationEntries[_activationEntries.indexOf(entry) + 1]
                        .progress)
                .abs())
            .reduce((a, b) => a + b);

        averageChangePerSecond = sumDeltaProgress /
            _activationEntries.first.timeStamp
                .difference(_activationEntries.last.timeStamp)
                .inSeconds
                .abs();
      } catch (e) {
        Log(
          'ZCoinActivationBloc: calculateETA',
          'Error calculating ETA: $e',
        );
      }
    }

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
