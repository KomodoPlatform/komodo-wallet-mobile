import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:komodo_dex/utils/log_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  static final LogStorage _logStorage = LogStorage();

  /// This function can be used in a hot-reload debugging session to focus on certain sections of the log.
  static bool pass(String key, dynamic message) {
    //return message.toString().startsWith('pickMode]') || message.toString().startsWith('play]');
    //return key.startsWith('swap_provider:');
    return kDebugMode;
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
    String messageToPrint = "";
    if (key.isNotEmpty) {
      messageToPrint = '$key] $message';
    } else {
      messageToPrint = message.toString();
    }

    if (pass(key, message)) {
      print(messageToPrint);
    }

    final now = DateTime.now();
    final dateString = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
    _logStorage.appendLog(now, '$dateString $messageToPrint');
  }

  static Future<void> appendRawLog(String message) async {
    final now = DateTime.now();
    _logStorage.appendLog(now, message);
  }

  static double limitMB = 500;

  // Retrieve the last cleared date from shared preferences, return null if
  // never cleared before.
  static Future<DateTime> getLastClearedDate() async {
    return DateTime.tryParse(
      (await _getCachedPrefs()).getString('lastClearedDate') ?? '',
    );
  }

  static Future<void> _updateLastClearedDate() async {
    final prefs = await _getCachedPrefs();
    final lastClearedDate = DateTime.now();
    await prefs.setString('lastClearedDate', lastClearedDate.toString());
  }

  /// Loop through saved log files from latest to older, and delete
  /// all files above overall [limitMB] size, except the today's one
  static Future<void> maintain() async {
    final directory = await applicationDocumentsDirectory;

    DateTime lastClearedDate = await getLastClearedDate();

    final List<File> logs = (await directory.list().toList())
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList()

      // Sorted
      ..sort((File a, File b) => b.path.compareTo(a.path));

    final now = DateTime.now();
    final difference =
        lastClearedDate == null ? null : now.difference(lastClearedDate).inDays;

    // TODO: Use async compute method that runs in isolate to avoid blocking
    // the main UI thread.
    final double totalSize =
        await MMService.getDirectorySize(directory.path, endsWith: 'log');

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

    await _updateLastClearedDate();
  }
}

Future<void> maintainInSeparateIsolate(Map<String, dynamic> params) async {
  List<File> logs = params['logs'] as List<File>;
  double limitMB = params['limitMB'] as double;
  double totalSize = params['totalSize'] as double;
  final directoryPath = params['directoryPath'] as String;

  print('Log size: ${totalSize.toStringAsFixed(2)}MB for ${logs.length} files');

  // Clear logs if never cleared before
  final shouldClearAllLogFiles = params['difference'] == null;

  if (shouldClearAllLogFiles) {
    final List<Future<void>> futures = logs.map((f) => f.delete()).toList();

    return Future.wait(futures).catchError((e) {
      print('Error clearing all log files: $e');
    });
  }

  while (totalSize > limitMB) {
    try {
      if (logs.first.existsSync()) logs.first.deleteSync();
      totalSize =
          await MMService.getDirectorySize(directoryPath, endsWith: 'log');
      logs.removeAt(0);
    } catch (e) {
      print('Error deleting log files: $e');
    }
  }
}
