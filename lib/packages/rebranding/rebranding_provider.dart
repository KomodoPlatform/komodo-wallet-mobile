import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RebrandingProvider extends ChangeNotifier {
  bool _closedPermanently = false;
  bool _closedThisSession = false;
  SharedPreferences _prefs;

  Future<void> get prefsLoaded => _loadPrefs();

  RebrandingProvider();

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _closedPermanently =
        _prefs.getBool('rebrandingDialogClosedPermanently') ?? false;
    notifyListeners();
  }

  bool get closedPermanently => _closedPermanently;
  bool get closedThisSession => _closedThisSession;

  void closePermanently() async {
    _closedPermanently = true;
    _closedThisSession = true;
    _prefs.setBool('rebrandingDialogClosedPermanently', _closedPermanently);
    notifyListeners();
  }

  void closeThisSession() {
    _closedThisSession = true;
    notifyListeners();
  }
}
