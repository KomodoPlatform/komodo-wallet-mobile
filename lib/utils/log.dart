import 'package:komodo_dex/services/mm_service.dart';

class Log {
  /// This function can be used in a hot-reload debugging session to focus on certain sections of the log.
  static bool pass(String key, dynamic message) {
    //return message.toString().startsWith('pickMode]') || message.toString().startsWith('play]');
    return true;
  }

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

    MMService().logIntoFile(
        DateTime.now().toString() + ' ' + messageToPrint.toString());
  }
}
