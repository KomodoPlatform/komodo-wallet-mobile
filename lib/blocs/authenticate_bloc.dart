import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/media_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/wallet.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
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

  bool isPinShow = true;
  final StreamController<bool> _showPinController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inShowPin => _showPinController.sink;
  Stream<bool> get outShowPin => _showPinController.stream;

  PinStatus pinStatus = PinStatus.NORMAL_PIN;
  final StreamController<PinStatus> _pinStatusController =
      StreamController<PinStatus>.broadcast();
  Sink<PinStatus> get _inpinStatus => _pinStatusController.sink;
  Stream<PinStatus> get outpinStatus => _pinStatusController.stream;

  bool isQrCodeActive = false;
  final StreamController<bool> _isQrCodeActiveController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsQrCodeActive => _isQrCodeActiveController.sink;
  Stream<bool> get outIsQrCodeActive => _isQrCodeActiveController.stream;

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

    if(prefs.getBool('isPinIsCreated') != null && prefs.getBool('isPinIsCreated')){
      pinStatus = PinStatus.CREATE_PIN;
      _inpinStatus.add(PinStatus.CREATE_PIN);
    }
  }

  @override
  void dispose() {
    _isLoginController.close();
    _showPinController.close();
    _pinStatusController.close();
    _isQrCodeActiveController.close();
  }

  Future<void> login(String passphrase, String password) async {
    await DBProvider.db.initDB();
    mainBloc.setCurrentIndexTab(0);
    walletBloc.setCurrentWallet(await DBProvider.db.getCurrentWallet());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _checkPINStatus(password);
    await EncryptionTool().write('passphrase', passphrase);
    prefs.setBool('isPassphraseIsSaved', true);
    await initSwitchPref();

    await prefs.setBool('isPinIsSet', false);
    await prefs.setBool('switch_pin_log_out_on_exit', false);

    await MarketMakerService().runBin();
    isLogin = true;
    _inIsLogin.add(true);
  }

  Future<void> initSwitchPref() async {
    await initSwitch('switch_pin', true);
    await initSwitch('switch_pin_biometric', false);
  }

  Future<void> initSwitch(String key, bool defaultSwitch) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool(key) != null
        ? await prefs.setBool(key, prefs.getBool(key))
        : await prefs.setBool(key, defaultSwitch);
  }

  Future<void> _checkPINStatus(String password) async {
    final Wallet wallet = await DBProvider.db.getCurrentWallet();
    final EncryptionTool entryptionTool = EncryptionTool();

    String pin;
    if (wallet != null && password != null) {
      pin = await entryptionTool.readData(KeyEncryption.PIN, wallet, password);
    }
    if (pin != null) {
      await entryptionTool.write('pin', pin);
      updateStatusPin(PinStatus.NORMAL_PIN);
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if (prefs.getBool('isPassphraseIsSaved') != null &&
          prefs.getBool('isPassphraseIsSaved')) {
        updateStatusPin(PinStatus.NORMAL_PIN);
      } else {
        updateStatusPin(PinStatus.CREATE_PIN);
        await entryptionTool.delete('pin');
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
    coinsBloc.stopCheckBalance();
    await MarketMakerService().stopmm2();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await EncryptionTool().delete('passphrase');
    await prefs.setBool('isPinIsSet', false);
    await prefs.setBool('isPassphraseIsSaved', false);

    updateStatusPin(PinStatus.NORMAL_PIN);
    await EncryptionTool().delete('pin');
    coinsBloc.resetCoinBalance();
    await coinsBloc.resetCoinDefault();
    MarketMakerService().balances = <Balance>[];
    await mediaBloc.deleteAllArticles();
    walletBloc.setCurrentWallet(null);
    await DBProvider.db.deleteCurrentWallet();

    isLogin = false;
    _inIsLogin.add(false);
  }

  void showPin(bool isShow) {
    isPinShow = isShow;
    _inShowPin.add(isPinShow);
  }

  void updateStatusPin(PinStatus pinStatus) {
    this.pinStatus = pinStatus;
    _inpinStatus.add(this.pinStatus);
  }

  void setIsQrCodeActive(bool active) {
    isQrCodeActive = active;
    _inIsQrCodeActive.add(isQrCodeActive);
  }
}

enum PinStatus {
  CREATE_PIN,
  CONFIRM_PIN,
  DISABLED_PIN,
  CHANGE_PIN,
  NORMAL_PIN,
  DISABLED_PIN_BIOMETRIC
}

AuthenticateBloc authBloc = AuthenticateBloc();
