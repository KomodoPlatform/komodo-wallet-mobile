import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../services/mm_service.dart';
import '../utils/utils.dart';

class Log {
  /// Log the [message].
  /// The [key] points at the code line location
  /// (updated automatically with https://github.com/ArtemGr/log-loc-rs).
  Log(String key, dynamic message) {
    Log.println(key, message);
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

  static void println(String key, dynamic message) {
    String messageToPrint = key + message.toString() + '\n';
    if (key.isNotEmpty) {
      messageToPrint = key + '] ' + message.toString() + '\n';
    }

    if (pass(key, message)) {
      // Flutter debugging console
      // and also iOS system log.

      if (kDebugMode) print(messageToPrint);
      //  print(messageToPrint);
    }

    //via os_log://MMService.nativeC.invokeMethod<String>('log', messageToPrint);

    // We make the log lines a bit shorter by only mentioning the time
    // and not the date, as the latter is already present in the log file name.
    final now = DateTime.now();
    mmSe.log2file(
        '${twoDigits(now.hour)}'
        ':${twoDigits(now.minute)}'
        ':${twoDigits(now.second)}'
        '.${now.millisecond}'
        ' $messageToPrint',
        now: now);
  }

  static double limitMB = 500;

  /// Loop through saved log files from latest to older, and delete
  /// all files above overall [limitMB] size, except the today's one
  static Future<void> maintain() async {
    Directory directory =
        await (applicationDocumentsDirectory as FutureOr<Directory>);
    final List<File> logs = directory
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList();

    logs.sort((a, b) => b.path.compareTo(a.path));

    double totalSize = mmSe.dirStatSync(directory.path);
    while (totalSize > limitMB) {
      try {
        if (logs.first.existsSync()) logs.first.deleteSync();
      } catch (e) {
        print(e);
      }
    }
  }
}
