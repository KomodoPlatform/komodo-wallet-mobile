import 'package:flutter/foundation.dart';
import 'package:komodo_dex/model/wallet_security_settings.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletSecuritySettingsProvider extends ChangeNotifier {
  // MRC: Needed to support using in AuthenticateBloc
  // Should prefer using Provider when possible.

  WalletSecuritySettings _walletSecuritySettings = WalletSecuritySettings();
  SharedPreferences _sharedPreferences;

  WalletSecuritySettingsProvider() {
    _init();
  }

  void _init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _getCurrentSettingsFromDb();
  }

  // MRC: If this key isn't present, we didn't do the migration yet,
  // this key also should be present on newly created wallets.
  bool get shouldMigrate =>
      !_sharedPreferences.containsKey('wallet_security_settings_migrated');

  Future<void> migrateSecuritySettings() async {
    Log('security_settings_provider', 'Migrating wallet security settings');

    if (!shouldMigrate) return;

    try {
      await _sharedPreferences.setBool(
          'wallet_security_settings_migration_in_progress', true);

      final tmpIsPassphraseSaved =
          _sharedPreferences.getBool('isPassphraseIsSaved');
      final tmpLogOutOnExit =
          _sharedPreferences.getBool('switch_pin_log_out_on_exit');
      final tmpPinProtection = _sharedPreferences.getBool('switch_pin');
      final tmpIsPinCreated = _sharedPreferences.getBool('isPinIsCreated');
      final tmpCreatedPin = _sharedPreferences.getString('pin_create');
      final tmpBioProtection =
          _sharedPreferences.getBool('switch_pin_biometric');
      final tmpCamoEnabled = _sharedPreferences.getBool('isCamoEnabled');
      final tmpIsCamoPinCreated =
          _sharedPreferences.getBool('isCamoPinCreated');
      final tmpCamoPin = _sharedPreferences.getString('camo_pin_create');
      final tmpIsCamoActive = _sharedPreferences.getBool('isCamoActive');
      final tmpCamoFraction = _sharedPreferences.getInt('camoFraction');
      final tmpCamoBalance = _sharedPreferences.getString('camoBalance');
      final tmpCamoSessionStartedAt =
          _sharedPreferences.getInt('camoSessionStartedAt');

      // MRC: We should migrate all wallets at once, this should be safer than
      // migrating only the current one, the user can change each of them later

      final tmpWalletSecuritySettings = WalletSecuritySettings(
        isPassphraseSaved: tmpIsPassphraseSaved,
        logOutOnExit: tmpLogOutOnExit,
        activatePinProtection: tmpPinProtection,
        isPinCreated: tmpIsPinCreated,
        createdPin: tmpCreatedPin,
        activateBioProtection: tmpBioProtection,
        enableCamo: tmpCamoEnabled,
        isCamoPinCreated: tmpIsCamoPinCreated,
        camoPin: tmpCamoPin,
        isCamoActive: tmpIsCamoActive,
        camoFraction: tmpCamoFraction,
        camoBalance: tmpCamoBalance,
        camoSessionStartedAt: tmpCamoSessionStartedAt,
      );

      _walletSecuritySettings = tmpWalletSecuritySettings;
      await _updateDb(allWallets: true);
      await _getCurrentSettingsFromDb();

      // Clean up shared preferences

      await _sharedPreferences.remove('isPassphraseIsSaved');
      await _sharedPreferences.remove('switch_pin_log_out_on_exit');
      await _sharedPreferences.remove('switch_pin');
      await _sharedPreferences.remove('isPinIsCreated');
      await _sharedPreferences.remove('pin_create');
      await _sharedPreferences.remove('switch_pin_biometric');
      await _sharedPreferences.remove('isCamoEnabled');
      await _sharedPreferences.remove('isCamoPinCreated');
      await _sharedPreferences.remove('camo_pin_create');
      await _sharedPreferences.remove('isCamoActive');
      await _sharedPreferences.remove('camoFraction');
      await _sharedPreferences.remove('camoBalance');
      await _sharedPreferences.remove('camoSessionStartedAt');

      // This shared pref seems like it hasn't been used for a long time
      await _sharedPreferences.remove('isPinIsSet');

      await _sharedPreferences.setBool(
          'wallet_security_settings_migrated', true);

      Log('security_settings_provider',
          'Migrated wallet security settings sucessfully');

      await Future.delayed(const Duration(milliseconds: 100));

      await _sharedPreferences
          .remove('wallet_security_settings_migration_in_progress');
      notifyListeners();
    } catch (e) {
      Log('security_settings_provider',
          'Failed to migrate wallet security settings, error: ${e.toString()}');
    }
  }

  Future<void> _getCurrentSettingsFromDb() async {
    _walletSecuritySettings = await Db.getCurrentWalletSecuritySettings();
  }

  Future<void> _updateDb({bool allWallets = false}) async {
    await Db.updateWalletSecuritySettings(_walletSecuritySettings,
        allWallets: allWallets);
  }

  bool get isPassphraseSaved => _walletSecuritySettings.isPassphraseSaved;

  set isPassphraseSaved(bool v) {
    _walletSecuritySettings.isPassphraseSaved = v;
    _updateDb().then((value) => notifyListeners());
  }

  bool get logOutOnExit => _walletSecuritySettings.logOutOnExit;

  set logOutOnExit(bool v) {
    _walletSecuritySettings.logOutOnExit = v;
    _updateDb().then((value) => notifyListeners());
  }

  bool get activatePinProtection =>
      _walletSecuritySettings.activatePinProtection;

  set activatePinProtection(bool v) {
    _walletSecuritySettings.activatePinProtection = v;

    _updateDb().then((value) => notifyListeners());
  }

  bool get isPinCreated => _walletSecuritySettings.isPinCreated;

  set isPinCreated(bool v) {
    _walletSecuritySettings.isPinCreated = v;

    _updateDb().then((value) => notifyListeners());
  }

  String get createdPin => _walletSecuritySettings.createdPin;

  set createdPin(String v) {
    _walletSecuritySettings.createdPin = v;

    _updateDb().then((value) => notifyListeners());
  }

  bool get activateBioProtection =>
      _walletSecuritySettings.activateBioProtection;

  set activateBioProtection(bool v) {
    _walletSecuritySettings.activateBioProtection = v;

    _updateDb().then((value) => notifyListeners());
  }

  bool get enableCamo => _walletSecuritySettings.enableCamo;

  set enableCamo(bool v) {
    _walletSecuritySettings.enableCamo = v;

    _updateDb().then((value) => notifyListeners());
  }

  bool get isCamoPinCreated => _walletSecuritySettings.isCamoPinCreated;

  set isCamoPinCreated(bool v) {
    _walletSecuritySettings.isCamoPinCreated = v;

    _updateDb().then((value) => notifyListeners());
  }

  String get camoPin => _walletSecuritySettings.camoPin;

  set camoPin(String v) {
    _walletSecuritySettings.camoPin = v;

    _updateDb().then((value) => notifyListeners());
  }

  bool get isCamoActive => _walletSecuritySettings.isCamoActive;

  set isCamoActive(bool v) {
    _walletSecuritySettings.isCamoActive = v;

    _updateDb().then((value) => notifyListeners());
  }

  int get camoFraction => _walletSecuritySettings.camoFraction;

  set camoFraction(int v) {
    _walletSecuritySettings.camoFraction = v;

    _updateDb().then((value) => notifyListeners());
  }

  String get camoBalance => _walletSecuritySettings.camoBalance;

  set camoBalance(String v) {
    _walletSecuritySettings.camoBalance = v;

    _updateDb().then((value) => notifyListeners());
  }

  int get camoSessionStartedAt => _walletSecuritySettings.camoSessionStartedAt;

  set camoSessionStartedAt(int v) {
    _walletSecuritySettings.camoSessionStartedAt = v;

    _updateDb().then((value) => notifyListeners());
  }
}
