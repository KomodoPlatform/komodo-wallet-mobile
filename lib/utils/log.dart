import 'package:komodo_dex/services/market_maker_service.dart';

class Log {
  static void println(String key, dynamic message) {
    String messageToPrint = key + message.toString() + '\n';
    if (key.isNotEmpty) {
      messageToPrint = key + ' :' + message.toString() + '\n';
    }
    print(messageToPrint);
    MarketMakerService().logIntoFile(
        DateTime.now().toString() + ' ' + messageToPrint.toString());
  }
}
