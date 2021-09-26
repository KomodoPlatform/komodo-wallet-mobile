import 'dart:async';

import 'package:komodo_dex/widgets/bloc_provider.dart';

CheckPassphraseBloc checkPassphraseBloc = CheckPassphraseBloc();

class CheckPassphraseBloc extends BlocBase {
  String word = '';

  final StreamController<String> _wordController =
      StreamController<String>.broadcast();
  Sink<String> get _inWordLogin => _wordController.sink;
  Stream<String> get outWordLogin => _wordController.stream;

  bool isWordGood = false;

  final StreamController<bool> _isWordGoodController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsWordGoodLogin => _isWordGoodController.sink;
  Stream<bool> get outIsWordGoodLogin => _isWordGoodController.stream;

  bool isResetText = false;

  final StreamController<bool> _isResetTextController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsResetTextLogin => _isResetTextController.sink;
  Stream<bool> get outIsResetTextLogin => _isResetTextController.stream;

  @override
  void dispose() {
    _wordController.close();
    _isWordGoodController.close();
    _isResetTextController.close();
  }

  void setWord(String word) {
    this.word = word;
    _inWordLogin.add(this.word);
  }

  void setIsWordGood(bool isWordGood) {
    this.isWordGood = isWordGood;
    _inIsWordGoodLogin.add(this.isWordGood);
  }

  void setIsResetText(bool isResetText) {
    this.isResetText = isResetText;
    _inIsResetTextLogin.add(this.isResetText);
  }
}
