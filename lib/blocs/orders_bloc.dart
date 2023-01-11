import 'dart:async';

import 'package:decimal/decimal.dart';
import '../model/base_service.dart';
import '../model/get_cancel_order.dart';
import '../model/order.dart';
import '../model/orders.dart';
import '../model/swap.dart';
import '../model/swap_provider.dart';
import '../services/mm.dart';
import '../services/mm_service.dart';
import '../services/music_service.dart';
import '../utils/log.dart';
import '../widgets/bloc_provider.dart';

OrdersBloc ordersBloc = OrdersBloc();

class OrdersBloc implements BlocBase {
  List<Order> orders;

  final StreamController<List<Order>> _ordersController =
      StreamController<List<Order>>.broadcast();
  Sink<List<Order>> get _inOrders => _ordersController.sink;
  Stream<List<Order>> get outOrders => _ordersController.stream;

  Orders currentOrders;

  final StreamController<Orders> _currentOrdersController =
      StreamController<Orders>.broadcast();
  Sink<Orders> get _inCurrentOrders => _currentOrdersController.sink;
  Stream<Orders> get outCurrentOrders => _currentOrdersController.stream;

  List<dynamic> orderSwaps = <dynamic>[];
  final StreamController<List<dynamic>> _orderSwapsController =
      StreamController<List<dynamic>>.broadcast();
  Sink<List<dynamic>> get _inOrderSwaps => _orderSwapsController.sink;
  Stream<List<dynamic>> get outOrderSwaps => _orderSwapsController.stream;

  @override
  void dispose() {
    _currentOrdersController.close();
    _ordersController.close();
    _orderSwapsController.close();
  }

  Future<void> updateOrders() async {
    try {
      final dynamic newOrders =
          await MM.getMyOrders(mmSe.client, BaseService(method: 'my_orders'));
      if (newOrders is Orders) {
        final List<Order> orders = <Order>[];

        for (MapEntry<String, TakerOrder> entry
            in newOrders.result.takerOrders.entries) {
          orders.add(Order(
              cancelable: entry.value.cancellable,
              base: entry.value.request.base,
              rel: entry.value.request.rel,
              orderType: OrderType.TAKER,
              createdAt: entry.value.createdAt ~/ 1000,
              baseAmount: entry.value.request.baseAmount,
              relAmount: entry.value.request.relAmount,
              uuid: entry.key));
        }

        for (MapEntry<String, MakerOrder> entry
            in newOrders.result.makerOrders.entries) {
          orders.add(Order(
              cancelable: entry.value.cancellable,
              baseAmount: entry.value.maxBaseVol,
              minVolume: double.tryParse(entry.value.minBaseVol),
              base: entry.value.base,
              rel: entry.value.rel,
              orderType: OrderType.MAKER,
              startedSwaps: entry.value.startedSwaps,
              createdAt: entry.value.createdAt ~/ 1000,
              relAmount: (Decimal.parse(entry.value.price) *
                      Decimal.parse(entry.value.maxBaseVol))
                  .toString(),
              uuid: entry.key));
        }
        this.orders = orders;
        _inOrders.add(this.orders);

        currentOrders = newOrders;
        _inCurrentOrders.add(currentOrders);
      }
    } catch (e) {
      Log('orders_bloc:88', e);
      rethrow;
    }
  }

  /// Orders and active swaps (both displayed on orders_page)
  Future<void> updateOrdersSwaps() async {
    await updateOrders();

    final List<Swap> swaps = swapMonitor.swaps.toList();
    for (Swap swap in swaps) {
      if (swap.result.uuid.startsWith('e852'))
        Log('orders_bloc:100', 'swap status: ${swap.status}');
    }
    swaps.removeWhere((Swap swap) =>
        swap.status == Status.SWAP_FAILED ||
        swap.status == Status.SWAP_SUCCESSFUL ||
        swap.status == Status.TIME_OUT);

    final List<Order> orders = this.orders;

    final MusicMode newMode = musicService.pickMode(orders);
    await musicService.play(newMode);

    final List<dynamic> ordersSwaps = <dynamic>[];
    ordersSwaps.addAll(orders);
    ordersSwaps.addAll(swaps);
    ordersSwaps.sort((dynamic a, dynamic b) {
      if (a is Order && b is Order) {
        return b.compareToOrder(a);
      } else if (a is Order && b is Swap) {
        return b.compareToOrder(a);
      } else if (a is Swap && b is Order) {
        return b.compareToSwap(a);
      } else {
        return b.compareToSwap(a);
      }
    });
    orderSwaps = ordersSwaps;
    _inOrderSwaps.add(ordersSwaps);
  }

  Future<void> cancelOrder(String uuid) async {
    try {
      await ApiProvider().cancelOrder(mmSe.client, GetCancelOrder(uuid: uuid));
      orderSwaps.removeWhere((dynamic orderSwap) {
        if (orderSwap is Order) {
          return orderSwap.uuid == uuid;
        } else {
          return false;
        }
      });
      _inOrderSwaps.add(orderSwaps);
    } catch (e) {
      Log('orders_bloc:160', e);
      rethrow;
    }
  }
}
