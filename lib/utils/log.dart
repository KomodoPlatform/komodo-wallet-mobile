import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/mm_service.dart';
import '../utils/utils.dart';

class Log {
  /// Log the [message].
  /// The [key] points at the code line location
  /// (updated automatically with https://github.com/ArtemGr/log-loc-rs).
  factory Log(String key, dynamic message) {
    Log.println(key, message);
    _getCachedPrefs() /*.ignore()*/;
    return null;
  }

  /// This function can be used in a hot-reload debugging session to focus on certain sections of the log.
  static bool pass(String key, dynamic message) {
    //return message.toString().startsWith('pickMode]') || message.toString().startsWith('play]');
    //return key.startsWith('swap_provider:');
    return true;
  }

  static SharedPreferences _prefs;

  static Future<SharedPreferences> _getCachedPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
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
      print(messageToPrint);
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

  // Retrieve the last cleared date from shared preferences, return null if
  // never cleared before.
  static Future<DateTime> getLastClearedDate() async {
    return DateTime.tryParse(
      (await _getCachedPrefs()).getString('lastClearedDate'),
    );
  }

  /// Loop through saved log files from latest to older, and delete
  /// all files above overall [limitMB] size, except the today's one
  static Future<void> maintain() async {
    final prefs = await _getCachedPrefs();
    final directory = await applicationDocumentsDirectory;

    DateTime lastClearedDate = await getLastClearedDate();

    final List<File> logs = (await directory.list().toList())
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList()

      // Sorted
      ..sort((File a, File b) => b.path.compareTo(a.path));

    final now = DateTime.now();
    final difference = now.difference(lastClearedDate).inDays;

    // TODO: Use async compute method that runs in isolate to avoid blocking
    // the main UI thread.
    final double totalSize = mmSe.dirStatSync(directory.path);

    // Use compute function to run maintainInSeparateIsolate in a separate isolate.
    Map<String, dynamic> params = {
      'logs': logs,
      'limitMB': limitMB,
      'totalSize': totalSize,
      'difference': difference,
      'directoryPath': directory.path,
    };

    // await compute(maintainInSeparateIsolate, params);
    await maintainInSeparateIsolate(params);

    // Save the new last cleared date to shared preferences.
    lastClearedDate = DateTime.now();
    await prefs.setString('lastClearedDate', lastClearedDate.toString());
  }
}

Future<void> maintainInSeparateIsolate(Map<String, dynamic> params) async {
  List<File> logs = params['logs'] as List<File>;
  double limitMB = params['limitMB'] as double;
  double totalSize = params['totalSize'] as double;
  final directoryPath = params['directoryPath'] as String;

  // Clear logs if never cleared before
  if (params['difference'] == null) {
    final futures = logs.map((f) => f.delete());

    return Future.wait(futures);
  }

  while (totalSize > limitMB) {
    try {
      if (logs.first.existsSync()) logs.first.deleteSync();
      totalSize = mmSe.dirStatSync(directoryPath);
    } catch (e) {
      print(e);
    }
  }
}
