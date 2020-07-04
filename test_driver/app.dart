import 'dart:io';

import 'package:flutter_driver/driver_extension.dart';
import 'package:komodo_dex/main.dart' as app;

void main() {
  Future<String> dataHandler(String msg) async {
    switch(msg) {
      case 'platform': {
        if (Platform.isAndroid) return 'android';
        if (Platform.isIOS) return 'ios';
        
        return 'unknown';
      }
      default: return '';
    }
  }

  // This line enables the extension
  enableFlutterDriverExtension(handler: dataHandler);

  // Call the `main()` function of your app or call `runApp` with any widget you
  // are interested in testing.
  app.main();
}