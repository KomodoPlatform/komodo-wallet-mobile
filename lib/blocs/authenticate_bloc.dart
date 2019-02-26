import 'dart:async';

import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/model/balance.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticateBloc extends BlocBase {
  bool isLogin = false;

  // Streams to handle the list coin
  StreamController<bool> _isLoginController =
      StreamController<bool>.broadcast();

  Sink<bool> get _inIsLogin => _isLoginController.sink;

  Stream<bool> get outIsLogin => _isLoginController.stream;

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
  }

  @override
  void dispose() {
    _isLoginController.close();
  }

  void login(String passphrase) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passphrase", passphrase);
    coinsBloc.init();
    _inIsLogin.add(true);
  }

  void logout() async {
    mm2.killmm2();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("passphrase", null);
    coinsBloc.resetCoinBalance();
    mm2.balances = new List<Balance>();
    _inIsLogin.add(false);
  }
}

final authBloc = AuthenticateBloc();
