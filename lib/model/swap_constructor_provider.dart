import 'package:flutter/material.dart';

class ConstructorProvider extends ChangeNotifier {
  String _sellCoin;
  String _buyCoin;

  String get sellCoin => _sellCoin;
  set sellCoin(String value) {
    _sellCoin = value;
    notifyListeners();
  }

  String get buyCoin => _buyCoin;
  set buyCoin(String value) {
    _buyCoin = value;
    notifyListeners();
  }
}
