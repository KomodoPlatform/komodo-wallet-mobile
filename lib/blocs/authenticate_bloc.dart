import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/main_bloc.dart';
import 'package:komodo_dex/blocs/media_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/utils/encryption_tool.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticateBloc extends BlocBase {
  bool isLogin = false;

  StreamController<bool> _isLoginController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsLogin => _isLoginController.sink;
  Stream<bool> get outIsLogin => _isLoginController.stream;

  bool isPinShow = true;
  StreamController<bool> _showPinController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inShowPin => _showPinController.sink;
  Stream<bool> get outShowPin => _showPinController.stream;

  PinStatus pinStatus = PinStatus.NORMAL_PIN;
  StreamController<PinStatus> _pinStatusController =
      StreamController<PinStatus>.broadcast();
  Sink<PinStatus> get _inpinStatus => _pinStatusController.sink;
  Stream<PinStatus> get outpinStatus => _pinStatusController.stream;

  bool isQrCodeActive = false;
  StreamController<bool> _isQrCodeActiveController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsQrCodeActive => _isQrCodeActiveController.sink;
  Stream<bool> get outIsQrCodeActive => _isQrCodeActiveController.stream;

  AuthenticateBloc() {
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("isPassphraseIsSaved") != null &&
        prefs.getBool("isPassphraseIsSaved")) {
      this.isLogin = true;
      _inIsLogin.add(true);
    } else {
      this.isLogin = false;
      _inIsLogin.add(false);
    }
    _inpinStatus.add(PinStatus.NORMAL_PIN);
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _checkPINStatus(password);
    await new EncryptionTool().write("passphrase", passphrase);
    prefs.setBool("isPassphraseIsSaved", true);
    await initSwitchPref();

    await prefs.setBool("isPinIsSet", false);
    await prefs.setBool("switch_pin_log_out_on_exit", false);

    await mm2.runBin();
    this.isLogin = true;
    _inIsLogin.add(true);
  }

  initSwitchPref() async {
    await initSwitch('switch_pin', true);
    await initSwitch('switch_pin_biometric', false);
  }

  initSwitch(String key, bool defaultSwitch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool(key) != null
        ? await prefs.setBool(key, prefs.getBool(key))
        : await prefs.setBool(key, defaultSwitch);
  }

  _checkPINStatus(String password) async {
    var wallet = await DBProvider.db.getCurrentWallet();
    var entryptionTool = new EncryptionTool();

    String pin;
    if (wallet != null && password != null) {
      pin = await entryptionTool.readData(KeyEncryption.PIN, wallet, password);
    }
    if (pin != null) {
      await entryptionTool.write("pin", pin);
      updateStatusPin(PinStatus.NORMAL_PIN);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (prefs.getBool("isPassphraseIsSaved") != null &&
        prefs.getBool("isPassphraseIsSaved")) {
        updateStatusPin(PinStatus.NORMAL_PIN);
      } else {
        updateStatusPin(PinStatus.CREATE_PIN);
        await entryptionTool.delete("pin");
      }
    }
  }

  Future<void> loginUI(bool isLogin, String passphrase, String password) async {
    await _checkPINStatus(password);
    await new EncryptionTool().write("passphrase", passphrase);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isPassphraseIsSaved", true);
    this.isLogin = isLogin;
    _inIsLogin.add(isLogin);
  }

  Future<void> logout() async {
    coinsBloc.stopCheckBalance();
    await mm2.stopmm2();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await new EncryptionTool().delete("passphrase");
    await prefs.setBool("isPinIsSet", false);

    updateStatusPin(PinStatus.NORMAL_PIN);
    await new EncryptionTool().delete("pin");
    coinsBloc.resetCoinBalance();
    await coinsBloc.resetCoinDefault();
    mm2.balances = new List<Balance>();
    await mediaBloc.deleteAllArticles();
    walletBloc.setCurrentWallet(null);
    await DBProvider.db.deleteCurrentWallet();

    this.isLogin = false;
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
    this.isQrCodeActive = active;
    _inIsQrCodeActive.add(this.isQrCodeActive);
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

final authBloc = AuthenticateBloc();
