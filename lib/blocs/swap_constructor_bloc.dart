import 'dart:async';

import 'package:komodo_dex/widgets/bloc_provider.dart';

class ConstructorBloc implements BlocBase {
  String _sellCoin;
  String _buyCoin;

  final StreamController<String> _sellCoinCtrl =
      StreamController<String>.broadcast();
  Sink<String> get _inSellCoin => _sellCoinCtrl.sink;
  Stream<String> get outSellCoin => _sellCoinCtrl.stream;

  final StreamController<String> _buyCoinCtrl =
      StreamController<String>.broadcast();
  Sink<String> get _inBuyCoin => _buyCoinCtrl.sink;
  Stream<String> get outBuyCoin => _buyCoinCtrl.stream;

  @override
  void dispose() {
    _sellCoinCtrl?.close();
    _buyCoinCtrl?.close();
  }

  String get sellCoin => _sellCoin;
  set sellCoin(String coin) {
    _sellCoin = coin;
    _inSellCoin.add(_sellCoin);
  }

  String get buyCoin => _buyCoin;
  set buyCoin(String coin) {
    _buyCoin = coin;
    _inBuyCoin.add(_buyCoin);
  }
}

ConstructorBloc constructorBloc = ConstructorBloc();
