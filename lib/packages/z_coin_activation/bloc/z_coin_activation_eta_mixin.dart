import 'package:komodo_dex/utils/log.dart';
import 'package:meta/meta.dart';

// Define the mixin class for ETA calculation
mixin ActivationEta {
  final List<_ActivationEntry> _activationEntries = [];

  void resetEta() {
    _activationEntries.clear();
  }

  Duration calculateETA(double progress) {
    _activationEntries.add(
      _ActivationEntry(
        progress: progress,
        timeStamp: DateTime.now(),
      ),
    );

    final hasEnoughEntries = _activationEntries.length >= 6 &&
        _activationEntries.first.timeStamp
                .difference(_activationEntries.last.timeStamp)
                .inSeconds
                .abs() >
            30;

    if (!hasEnoughEntries) {
      return null;
    }

    _activationEntries.retainWhere((entry) {
      final elapsedSeconds =
          DateTime.now().difference(entry.timeStamp).inSeconds.abs();
      return elapsedSeconds <= 120;
    });

    double averageChangePerSecond = 0;

    if (_activationEntries.length > 1) {
      try {
        final sumDeltaProgress = _activationEntries
            .sublist(0, _activationEntries.length - 1)
            .map(
              (entry) => (entry.progress -
                      _activationEntries[_activationEntries.indexOf(entry) + 1]
                          .progress)
                  .abs(),
            )
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

mixin ProgressCalculator {
  DateTime _lastProgressUpdate;
  double _lastProgressValue = 0.0;

  void resetProgress() {
    _lastProgressUpdate = null;
    _lastProgressValue = 0.0;
  }

  double calculateSmoothProgress(double currentProgress) {
    if (currentProgress == 1.0) return 1.0;

    final now = DateTime.now();

    // If this is the first calculation, set the baseline
    if (_lastProgressUpdate == null || currentProgress == 1) {
      _lastProgressUpdate = now;
      _lastProgressValue = currentProgress;
      return currentProgress;
    }

    final timeDifference = now.difference(_lastProgressUpdate).inSeconds;

    // Calculate the maximum allowed progress increase
    final maxProgressIncrease = 0.01 * (timeDifference / 0.5);

    // Determine the new progress based on the allowed increase
    double newProgress = _lastProgressValue + maxProgressIncrease;

    // Ensure the new progress does not exceed the current reported progress
    if (newProgress > currentProgress) {
      newProgress = currentProgress;
    }

    // Update the last progress and timestamp
    _lastProgressValue = newProgress;
    _lastProgressUpdate = now;

    return newProgress;
  }

  double calculateOverallProgress(
      int completedCoins, int totalCoins, double currentCoinProgress) {
    // Fraction of the total progress that each coin represents.
    double coinShare = 1.0 / totalCoins;

    // Progress contributed by the coins that have already been fully activated.
    double completedCoinsProgress = completedCoins * coinShare;

    // Represents the progress of the coin currently being activated.
    double inProgressCoinContribution = currentCoinProgress * coinShare;

    // Calculating the overall progress
    double val =
        (completedCoinsProgress + inProgressCoinContribution).clamp(0.0, 1.0);

    return val;
  }
}
