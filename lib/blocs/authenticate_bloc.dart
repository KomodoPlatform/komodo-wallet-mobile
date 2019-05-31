import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/blocs/media_bloc.dart';
import 'package:komodo_dex/blocs/wallet_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/services/db/database.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
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

    if (prefs.getString("passphrase") != null) {
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

  Future<void> login(String passphrase) async {
    await DBProvider.db.initDB();
    walletBloc.setCurrentWallet(await DBProvider.db.getCurrentWallet());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("passphrase") != null &&
        prefs.getString("passphrase").isNotEmpty) {
      prefs.setString("pin", prefs.getString("pin"));
      updateStatusPin(PinStatus.NORMAL_PIN);
    } else {
      updateStatusPin(PinStatus.CREATE_PIN);
      await prefs.remove("pin");
    }
    await prefs.setString("passphrase", passphrase);

    await _initSwitch('switch_pin', true);
    await _initSwitch('switch_pin_biometric', false);

    await prefs.setBool("isPinIsSet", false);
    await prefs.setBool("switch_pin_log_out_on_exit", false);

    await mm2.runBin();
    this.isLogin = true;
    _inIsLogin.add(true);
  }

  _initSwitch(String key, bool defaultSwitch) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool(key) != null ?
      await prefs.setBool(key, prefs.getBool(key)) :
      await prefs.setBool(key, defaultSwitch);
    
  }

  Future<void> loginUI(bool isLogin, String passphrase) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("passphrase") != null &&
        prefs.getString("passphrase").isNotEmpty) {
      prefs.setString("pin", prefs.getString("pin"));
      updateStatusPin(PinStatus.NORMAL_PIN);
    } else {
      updateStatusPin(PinStatus.CREATE_PIN);
      await prefs.remove("pin");
    }
    await prefs.setString("passphrase", passphrase);

    this.isLogin = isLogin;
    _inIsLogin.add(isLogin);
  }

  void logout() async {
    coinsBloc.stopCheckBalance();
    await mm2.stopmm2();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passphrase", null);
    await prefs.setBool("isPinIsSet", false);
    
    updateStatusPin(PinStatus.NORMAL_PIN);
    await prefs.remove("pin");
    coinsBloc.resetCoinBalance();
    await coinsBloc.writeJsonCoin(await mm2.loadJsonCoinsDefault());
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

enum PinStatus { CREATE_PIN, CONFIRM_PIN, DISABLED_PIN, CHANGE_PIN, NORMAL_PIN, DISABLED_PIN_BIOMETRIC }

final authBloc = AuthenticateBloc();
