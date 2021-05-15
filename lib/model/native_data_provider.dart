import 'package:flutter/foundation.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/utils.dart';

class NativeDataProvider extends ChangeNotifier {
  NativeData _nativeData;

  NativeData get nativeData => _nativeData;

  Future<void> grabData() async {
    final dynamic js =
        await MMService.nativeC.invokeMethod<dynamic>('get_native_data');
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

    final nd = NativeData(
      screen: screen,
      extraData: uri.toString(),
    );

    _nativeData = nd;
    notifyListeners();
  }

  void emptyNativeData() {
    _nativeData = null;
    notifyListeners();
  }
}

class NativeData {
  NativeData({this.screen, this.extraData});

  final ScreenSelection screen;
  final String extraData;
}

enum ScreenSelection { None, Bitcoin, Ethereum }
