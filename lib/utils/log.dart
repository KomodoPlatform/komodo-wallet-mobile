import 'package:komodo_dex/services/market_maker_service.dart';

class Log {
  static void println(dynamic message) {
    print(message.toString() + '\n');
    MarketMakerService().logOnFile(message.toString());
  }
}