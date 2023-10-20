import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RebrandingProvider extends ChangeNotifier {
  RebrandingProvider();

  // TODO! Remove code/assets for rebranding after the date below
  final rebrandingExpirationDate = DateTime(2023, 12, 1);
  bool get isRebrandingExpired =>
      DateTime.now().isAfter(rebrandingExpirationDate);

  bool _closedPermanently = false;
  bool _closedThisSession = false;
  SharedPreferences _prefs;

  Future<void> get prefsLoaded => _loadPrefs();

  bool get shouldShowRebrandingDialog =>
      !isRebrandingExpired && !closedPermanently && !closedThisSession;

  bool get shouldShowRebrandingNews =>
      !isRebrandingExpired && !closedPermanently;

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
