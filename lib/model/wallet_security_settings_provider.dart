import 'package:flutter/foundation.dart';
import 'package:komodo_dex/model/wallet_security_settings.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

WalletSecuritySettingsProvider walletSecuritySettingsProvider =
    WalletSecuritySettingsProvider();

class WalletSecuritySettingsProvider extends ChangeNotifier {
  // MRC: Needed to support using in Blocs
  // Should prefer using Provider when possible.

  WalletSecuritySettings _walletSecuritySettings = WalletSecuritySettings();

  WalletSecuritySettingsProvider();

  Future<void> migrateSecuritySettings() async {
    final _prefs = await SharedPreferences.getInstance();
    Log('security_settings_provider', 'Migrating wallet security settings');

    // MRC: If this key isn't present, we didn't do the migration yet,
    // this key also should be present on newly created wallets.
    if (_prefs.containsKey('wallet_security_settings_migrated')) return;

    try {
      await _prefs.setBool(
          'wallet_security_settings_migration_in_progress', true);

      final tmpPinProtection = _prefs.getBool('switch_pin');
      final tmpBioProtection = _prefs.getBool('switch_pin_biometric');
      final tmpCamoEnabled = _prefs.getBool('isCamoEnabled');
      final tmpIsCamoActive = _prefs.getBool('isCamoActive');
      final tmpCamoFraction = _prefs.getInt('camoFraction');
      final tmpCamoBalance = _prefs.getString('camoBalance');
      final tmpCamoSessionStartedAt = _prefs.getInt('camoSessionStartedAt');

      // MRC: We should migrate all wallets at once, this should be safer than
      // migrating only the current one, the user can change each of them later

      final tmpWalletSecuritySettings = WalletSecuritySettings(
        activatePinProtection: tmpPinProtection ?? false,
        activateBioProtection: tmpBioProtection ?? false,
        enableCamo: tmpCamoEnabled ?? false,
        isCamoActive: tmpIsCamoActive ?? false,
        camoFraction: tmpCamoFraction,
        camoBalance: tmpCamoBalance,
        camoSessionStartedAt: tmpCamoSessionStartedAt,
      );

      _walletSecuritySettings = tmpWalletSecuritySettings;
      await _updateDb(allWallets: true);

      // Clean up shared preferences

      await _prefs.remove('isPassphraseIsSaved');
      await _prefs.remove('switch_pin');
      await _prefs.remove('pin_create');
      await _prefs.remove('switch_pin_biometric');
      await _prefs.remove('isCamoEnabled');
      await _prefs.remove('isCamoPinCreated');
      await _prefs.remove('camo_pin_create');
      await _prefs.remove('isCamoActive');
      await _prefs.remove('camoFraction');
      await _prefs.remove('camoBalance');
      await _prefs.remove('camoSessionStartedAt');

      // Old shared prefs
      // unused, was renamed to isPinIsCreated previously
      await _prefs.remove('isPinIsSet');

      // renamed to is_pin_creation_in_progress for better name
      await _prefs.remove('isPinIsCreated');
      // should have been deleted after finishing pin setup
      await _prefs.remove('pin_create');
      // renamed to is_camo_pin_creation_in_progress for better name
      await _prefs.remove('isCamoPinCreated');
      // should have been deleted after finishing camo pins etup

      await _prefs.setBool('wallet_security_settings_migrated', true);

      Log('security_settings_provider',
          'Migrated wallet security settings sucessfully');

      await Future.delayed(const Duration(milliseconds: 100));

      await _prefs.remove('wallet_security_settings_migration_in_progress');
    } catch (e) {
      Log('security_settings_provider',
          'Failed to migrate wallet security settings, error: ${e.toString()}');
    }
  }

  Future<void> getCurrentSettingsFromDb() async {
    _walletSecuritySettings = await Db.getCurrentWalletSecuritySettings();
  }

  Future<void> _updateDb({bool allWallets = false}) async {
    await Db.updateWalletSecuritySettings(_walletSecuritySettings,
        allWallets: allWallets);
  }

  bool get activatePinProtection =>
      _walletSecuritySettings.activatePinProtection;

  set activatePinProtection(bool v) {
    _walletSecuritySettings.activatePinProtection = v;

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
