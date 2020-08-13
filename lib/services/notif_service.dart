import 'package:flutter/services.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/mm_service.dart';

NotifService notifService = NotifService();

class NotifService {
  bool initialized = false;
  MethodChannel chanell = MMService.nativeC;

  void init() {
    if (initialized) return;
    _subscribeOrdersStatus();

    initialized = true;
  }

  Future<void> show(NotifObj notif) async {
    await chanell.invokeMethod<void>('show_notification', <String, dynamic>{
      'title': notif.title,
      'text': notif.text,
    });
  }

  void _subscribeOrdersStatus() {
    ordersBloc.outOrderSwaps.listen((List<dynamic> orders) {
      if (orders == null || orders.isEmpty) return;

      _checkOrdersStatusChange(orders);
      _saveOrders(orders);
    });
  }

  void _checkOrdersStatusChange(List<dynamic> orders) {}

  void _saveOrders(List<dynamic> orders) {
    for (dynamic order in orders) {
      String uuid;
      if (order is Order) {
        uuid = order.uuid;
      } else if (order is Swap) {
        uuid = order.result?.uuid;
      }
      print(uuid);
    }
  }
}

class NotifObj {
  NotifObj({
    this.title,
    this.text,
  });

  String title;
  String text;
}
