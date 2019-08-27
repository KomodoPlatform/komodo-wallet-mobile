
import 'dart:async';

import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class CoinDetailBloc implements BlocBase {

  Fee customFee;

  final StreamController<Fee> _customFeeController =
      StreamController<Fee>.broadcast();

  Sink<Fee> get _inCustomFee => _customFeeController.sink;
  Stream<Fee> get outCustomFee => _customFeeController.stream;

  String amountToSend;

  final StreamController<String> _amountToSendController =
      StreamController<String>.broadcast();

  Sink<String> get _inAmountToSend => _amountToSendController.sink;
  Stream<String> get outAmountToSend => _amountToSendController.stream;


  @override
  void dispose() {
    _customFeeController.close();
  }

  void setCustomFee(Fee fee) {
    customFee = fee;
    _inCustomFee.add(customFee);
  }

  void resetCustomFee() {
    customFee = null;
    _inCustomFee.add(null);
  }
  
  void setAmountToSend(String amount) {
    amountToSend = amount;
    _inAmountToSend.add(amountToSend);
  }
}

CoinDetailBloc coinsDetailBloc = CoinDetailBloc();
