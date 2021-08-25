import 'package:flutter/foundation.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';

class IntentDataProvider extends ChangeNotifier {
  IntentData _intentData;

  IntentData get intentData => _intentData;

  Future<void> grabData() async {
    final String data =
        await MMService.nativeC.invokeMethod<String>('get_intent_data');
    if (data == null) return;

    //Check if is payment uri
    final Uri uri = Uri.tryParse(data);
    if (uri == null) return;

    final PaymentUriInfo uriInfo = PaymentUriInfo.fromUri(uri);

    // ScreenSelection might be useful in the future for other types of intent
    ScreenSelection screen;
    switch (uriInfo.scheme) {
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
      payload: data.toString(),
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
  IntentData({this.screen, this.payload});

  final ScreenSelection screen;
  final String payload;
}

enum ScreenSelection { None, Bitcoin, Ethereum }
