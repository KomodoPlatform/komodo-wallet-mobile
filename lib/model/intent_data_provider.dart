import 'package:flutter/foundation.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';

class IntentDataProvider extends ChangeNotifier {
  IntentData _intentData;

  IntentData get intentData => _intentData;

  Future<void> grabData() async {
    final dynamic js =
        await MMService.nativeC.invokeMethod<dynamic>('get_intent_data');
    if (js == null) return;

    //Check if is payment uri
    final uri = Uri.tryParse(js);
    if (uri == null) return;

    final map = parsePaymentUri(uri);

    ScreenSelection screen;
    switch (map['scheme']) {
      case 'bitcoin':
        screen = ScreenSelection.Bitcoin;
        break;
      case 'ethereum':
        screen = ScreenSelection.Ethereum;
        break;
      default:
        screen = ScreenSelection.None;
    }

    final nd = IntentData(
      screen: screen,
      extraData: uri.toString(),
    );

    _intentData = nd;
    notifyListeners();
  }

  void emptyIntentData() {
    _intentData = null;
    notifyListeners();
  }
}

class IntentData {
  IntentData({this.screen, this.extraData});

  final ScreenSelection screen;
  final String extraData;
}

enum ScreenSelection { None, Bitcoin, Ethereum }
