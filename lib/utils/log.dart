import 'package:komodo_dex/services/mm_service.dart';

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
}
