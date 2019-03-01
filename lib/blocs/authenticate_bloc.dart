import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticateBloc extends BlocBase {

  bool isLogin = false;
  StreamController<bool> _isLoginController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsLogin => _isLoginController.sink;
  Stream<bool> get outIsLogin => _isLoginController.stream;

  bool isPinShow = false;
  StreamController<bool> _showPinController =
        StreamController<bool>.broadcast();
  Sink<bool> get _inShowPin => _showPinController.sink;
  Stream<bool> get outShowPin => _showPinController.stream;

  PinStatus pinStatus = PinStatus.CREATE_PIN;

  StreamController<PinStatus> _pinStatusController =
  StreamController<PinStatus>.broadcast();

  Sink<PinStatus> get _inpinStatus => _pinStatusController.sink;

  Stream<PinStatus> get outpinStatus => _pinStatusController.stream;


  AuthenticateBloc() {
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("passphrase") != null) {
      _inIsLogin.add(true);
      coinsBloc.updateBalanceForEachCoin(true);
    } else {
      _inIsLogin.add(false);
    }
    if (prefs.getString("pin") == "") {
      _inpinStatus.add(pinStatus);
    } else {
      _inpinStatus.add(PinStatus.NORMAL_PIN);
    }
  }

  @override
  void dispose() {
    _isLoginController.close();
    _showPinController.close();
    _pinStatusController.close();
  }

  void login(String passphrase) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passphrase", passphrase);
    await prefs.setBool("isPinIsSet", false);
    await updateStatusPin(PinStatus.CREATE_PIN, "");
    await coinsBloc.init();
    _inIsLogin.add(true);
  }

  void logout() async {
    mm2.killmm2();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passphrase", null);
    await prefs.setBool("isPinIsSet", false);
    await updateStatusPin(PinStatus.NORMAL_PIN, "");
    print("PinStatus.CREATE_PIN");
    coinsBloc.resetCoinBalance();
    mm2.balances = new List<Balance>();
    _inIsLogin.add(false);
  }

  void showPin(bool isShow) {
    isPinShow = isShow;
    _inShowPin.add(isPinShow);
  }

  Future<void> updateStatusPin(PinStatus pinStatus, String code) async {
    if (pinStatus == PinStatus.CONFIRM_PIN) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("pin", code);
    }
    this.pinStatus = pinStatus;
    _inpinStatus.add(this.pinStatus);
  }

}

enum PinStatus {
  CREATE_PIN,
  CONFIRM_PIN,
  CHANGE_PIN,
  NORMAL_PIN
}

final authBloc = AuthenticateBloc();
