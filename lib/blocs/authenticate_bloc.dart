import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/model/coin.dart';
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

  AuthenticateBloc() {
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (prefs.getString("passphrase") != null) {
      _inIsLogin.add(true);
      await coinsBloc.updateBalanceForEachCoin(true);
    } else {
      _inIsLogin.add(false);
    }
    _inpinStatus.add(PinStatus.NORMAL_PIN);
  }

  @override
  void dispose() {
    _isLoginController.close();
    _showPinController.close();
    _pinStatusController.close();
  }

  Future<void> login(String passphrase) async {
    mm2.ismm2Running = true;
    mm2.mm2Ready = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("passphrase") != null && prefs.getString("passphrase").isNotEmpty) {
      prefs.setString("pin", prefs.getString("pin"));
      updateStatusPin(PinStatus.NORMAL_PIN);
    } else {
      updateStatusPin(PinStatus.CREATE_PIN);
      await prefs.remove("pin");
    }
    await prefs.setString("passphrase", passphrase);
    await prefs.setBool('switch_pin', true);
    await prefs.setBool("isPinIsSet", false);

    List<Coin> coins = await coinsBloc.readJsonCoin();
    if (coins.isEmpty) {
      coins = await mm2.loadJsonCoinsDefault();
      await coinsBloc.writeJsonCoin(coins);
    }
    await mm2.runBin();
    _inIsLogin.add(true);
  }

  void logout() async {
    mm2.ismm2Running = false;
    mm2.mm2Ready = false;
    mm2.killmm2();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passphrase", null);
    await prefs.setBool("isPinIsSet", false);
    updateStatusPin(PinStatus.NORMAL_PIN);
    await prefs.remove("pin");
    coinsBloc.resetCoinBalance();
    coinsBloc.stopCheckBalance();
    await coinsBloc.writeJsonCoin(await mm2.loadJsonCoinsDefault());
    mm2.balances = new List<Balance>();
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
}

enum PinStatus { CREATE_PIN, CONFIRM_PIN, DISABLED_PIN, CHANGE_PIN, NORMAL_PIN }

final authBloc = AuthenticateBloc();
