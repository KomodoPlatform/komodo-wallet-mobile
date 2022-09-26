import 'dart:io';

import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';

class Log {
  /// Log the [message].
  /// The [key] points at the code line location
  /// (updated automatically with https://github.com/ArtemGr/log-loc-rs).
  factory Log(String key, dynamic message) {
    Log.println(key, message);
    return null;
  }

  /// This function can be used in a hot-reload debugging session to focus on certain sections of the log.
  static bool pass(String key, dynamic message) {
    //return message.toString().startsWith('pickMode]') || message.toString().startsWith('play]');
    //return key.startsWith('swap_provider:');
    return true;
  }

  static String twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  /// Log the [message].
  /// The [key] points at the code line location
  /// (updated automatically with https://github.com/ArtemGr/log-loc-rs).

  static final List<String> _tempLogs = [];
  static void println(String key, dynamic message) {
    String messageToPrint = key + message.toString() + '\n';
    if (key.isNotEmpty) {
      messageToPrint = key + '] ' + message.toString() + '\n';
    }

    if (pass(key, message)) {
      // Flutter debugging console
      // and also iOS system log.
      //  print(messageToPrint);
    }

    //via os_log://MMService.nativeC.invokeMethod<String>('log', messageToPrint);

    // We make the log lines a bit shorter by only mentioning the time
    // and not the date, as the latter is already present in the log file name.
    final now = DateTime.now();
    // only write to log file if the [messageToPrint] has appeared 5 times
    // within the last 2 minutes.
    if (_tempLogs.where((c) => c == messageToPrint).length < 6) {
      mmSe.log2file(
          '${twoDigits(now.hour)}'
          ':${twoDigits(now.minute)}'
          ':${twoDigits(now.second)}'
          '.${now.millisecond}'
          ' $messageToPrint',
          now: now);
      _tempLogs.add(messageToPrint);
    }
  }

  // clear temporary log file every 2 minutes
  static Future<void> clearTempLog() async {
    jobService.install('clearTempLog', 120, (j) async {
      _tempLogs.clear();
    });
  }

  static double limitMB = 500;

  /// Loop through saved log files from latest to older, and delete
  /// all files above overall [limitMB] size, except the today's one
  static Future<void> maintain() async {
    final List<File> logs = (await applicationDocumentsDirectory)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList();

    logs.sort((a, b) => b.path.compareTo(a.path));

    final DateTime now = DateTime.now();
    final String todayStr = '${now.year}'
        '-${twoDigits(now.month)}'
        '-${twoDigits(now.day)}';

    double totalMb = 0;
    bool limitExceeded = false;
    for (File logFile in logs) {
      final double fileSizeMb = logFile.statSync().size / 1000000;
      totalMb += fileSizeMb;
      if (totalMb > limitMB) limitExceeded = true;
      if (limitExceeded && !logFile.path.endsWith('$todayStr.log')) {
        logFile.deleteSync();
      }
    }
  }
}
