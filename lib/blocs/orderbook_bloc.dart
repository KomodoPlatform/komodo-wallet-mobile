import 'dart:async';

import 'package:komodo_dex/model/coin.dart';
import 'package:komodo_dex/model/orderbook.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

class OrderbookBloc implements BlocBase {
  Orderbook _orderBook;

  StreamController<Orderbook> _orderBookController =
      StreamController<Orderbook>.broadcast();
  Sink<Orderbook> get _inOrderbook => _orderBookController.sink;
  Stream<Orderbook> get outOrderbook => _orderBookController.stream;

  @override
  void dispose() {
    _orderBookController.close();
  }

  void updateOrderbook(Coin coinBase, Coin coinRel) async {
    if (mm2.ismm2Running) {
      Orderbook orderbook = await mm2.getOrderbook(coinBase, coinRel);
      _orderBook = orderbook;
      _inOrderbook.add(_orderBook);
    }
  }
}
