import 'dart:async';

import 'package:komodo_dex/model/order_book_provider.dart';

import '../blocs/coins_bloc.dart';
import '../blocs/main_bloc.dart';
import '../blocs/media_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../blocs/wallet_bloc.dart';
import '../model/balance.dart';
import '../model/wallet.dart';
import '../model/wallet_security_settings_provider.dart';
import '../services/db/database.dart';
import '../services/mm_service.dart';
import '../services/notif_service.dart';
import '../utils/encryption_tool.dart';
import '../widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticateBloc extends BlocBase {
  AuthenticateBloc() {
    init();
  }
  bool isLogin = false;

  final StreamController<bool> _isLoginController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsLogin => _isLoginController.sink;
  Stream<bool> get outIsLogin => _isLoginController.stream;

  bool _showLock = true;
  final StreamController<bool> _showLockController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inShowLock => _showLockController.sink;
  Stream<bool> get outShowLock => _showLockController.stream;

  PinStatus pinStatus = PinStatus.NORMAL_PIN;
  final StreamController<PinStatus> _pinStatusController =
      StreamController<PinStatus>.broadcast();
  Sink<PinStatus> get _inpinStatus => _pinStatusController.sink;
  Stream<PinStatus> get outpinStatus => _pinStatusController.stream;

  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isPassphraseIsSaved') != null &&
        prefs.getBool('isPassphraseIsSaved')) {
      isLogin = true;
      _inIsLogin.add(true);
    } else {
      isLogin = false;
      _inIsLogin.add(false);
    }
    pinStatus = PinStatus.NORMAL_PIN;
    _inpinStatus.add(PinStatus.NORMAL_PIN);

    if (prefs.containsKey('is_pin_creation_in_progress')) {
      pinStatus = PinStatus.CREATE_PIN;
      _inpinStatus.add(PinStatus.CREATE_PIN);
    }

    if (!(prefs.getBool('switch_pin') ?? false)) {
      showLock = false;
    }
  }

  @override
  void dispose() {
    _isLoginController.close();
    _showLockController.close();
    _pinStatusController.close();
  }

  Future<void> login(String passphrase, String password,
      {bool loadSnapshot = true}) async {
    mainBloc.setCurrentIndexTab(0);

    final currentWallet = await Db.getCurrentWallet();
    walletBloc.setCurrentWallet(currentWallet);
    if (loadSnapshot) {
      await coinsBloc.loadWalletSnapshot(wallet: currentWallet);
    }

    await walletSecuritySettingsProvider.getCurrentSettingsFromDb();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _checkPINStatus(password);
    await EncryptionTool().write('passphrase', passphrase);
    prefs.setBool('isPassphraseIsSaved', true);

    await mmSe.init(passphrase);

    await notifService.init();
    if (loadSnapshot) {
      await syncOrderbook.fullOrderbookUpdate();
    }

    isLogin = true;
    _inIsLogin.add(true);
  }

  Future<void> _checkPINStatus(String password) async {
    final Wallet wallet = await Db.getCurrentWallet();
    final EncryptionTool entryptionTool = EncryptionTool();

    String pin, camoPin;
    if (wallet != null && password != null) {
      pin = await entryptionTool.readData(KeyEncryption.PIN, wallet, password);
      camoPin = await entryptionTool.readData(
          KeyEncryption.CAMOPIN, wallet, password);
    }
    if (pin != null) {
      await entryptionTool.write('pin', pin);
      if (camoPin != null) await entryptionTool.write('camoPin', camoPin);

      updateStatusPin(PinStatus.NORMAL_PIN);
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (prefs.getBool('isPassphraseIsSaved') != null &&
          prefs.getBool('isPassphraseIsSaved')) {
        updateStatusPin(PinStatus.NORMAL_PIN);
      } else {
        updateStatusPin(PinStatus.CREATE_PIN);
        await entryptionTool.delete('pin');
        await entryptionTool.delete('camoPin');
      }
    }
  }

  Future<void> loginUI(bool isLogin, String passphrase, String password) async {
    await _checkPINStatus(password);
    await EncryptionTool().write('passphrase', passphrase);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isPassphraseIsSaved', true);
    this.isLogin = isLogin;
    _inIsLogin.add(isLogin);
  }

  Future<void> logout() async {
    isLogin = false;
    _inIsLogin.add(false);

    coinsBloc.stopCheckBalance();
    await mmSe.stopmm2();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await EncryptionTool().delete('passphrase');

    await prefs.setBool('isPassphraseIsSaved', false);
    await EncryptionTool().delete('camoPin');

    await prefs.remove('switch_pin');
    await prefs.remove('switch_pin_biometric');
    await prefs.remove('isCamoEnabled');
    await prefs.remove('isCamoActive');
    await prefs.remove('camoFraction');
    await prefs.remove('camoBalance');
    await prefs.remove('camoSessionStartedAt');
    await prefs.remove('showCancelOrderDialog1');
    settingsBloc.showCancelOrderDialog = true;

    updateStatusPin(PinStatus.NORMAL_PIN);
    await EncryptionTool().delete('pin');
    coinsBloc.resetCoinBalance();
    mmSe.balances = <Balance>[];
    await mediaBloc.deleteAllArticles();
    walletBloc.setCurrentWallet(null);
    await Db.deleteCurrentWallet();
  }

  /// Whether the lock (PIN code, fingerprint and faceid biometrics) is displayed.
  bool get showLock => _showLock;

  /// Whether to show the lock (PIN code, fingerprint and faceid biometrics).
  set showLock(bool yn) {
    _inShowLock.add(_showLock = yn);
  }

  void updateStatusPin(PinStatus pinStatus) {
    this.pinStatus = pinStatus;
    _inpinStatus.add(this.pinStatus);
  }
}

enum PinStatus {
  CREATE_PIN,
  CONFIRM_PIN,
  CREATE_CAMO_PIN,
  CONFIRM_CAMO_PIN,
  DISABLED_PIN,
  CHANGE_PIN,
  NORMAL_PIN,
  DISABLED_PIN_BIOMETRIC
}

AuthenticateBloc authBloc = AuthenticateBloc();
