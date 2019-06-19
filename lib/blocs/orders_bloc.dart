import 'dart:async';

import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/orders.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/services/market_maker_service.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

final ordersBloc = OrdersBloc();

class OrdersBloc implements BlocBase {
  List<Order> orders;

  StreamController<List<Order>> _ordersController =
      StreamController<List<Order>>.broadcast();
  Sink<List<Order>> get _inOrders => _ordersController.sink;
  Stream<List<Order>> get outOrders => _ordersController.stream;

  Orders currentOrders;

  StreamController<Orders> _currentOrdersController =
      StreamController<Orders>.broadcast();
  Sink<Orders> get _inCurrentOrders => _currentOrdersController.sink;
  Stream<Orders> get outCurrentOrders => _currentOrdersController.stream;

  @override
  void dispose() {
    _currentOrdersController.close();
    _ordersController.close();
  }

  Future<void> updateOrders() async {
    Orders newOrders = await mm2.getMyOrders();
    List<Order> orders = new List<Order>();

    for (var entry in newOrders.result.takerOrders.entries) {
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

    for (var entry in newOrders.result.makerOrders.entries) {
      orders.add(Order(
          cancelable: entry.value.cancellable,
          baseAmount: entry.value.maxBaseVol,
          base: entry.value.base,
          rel: entry.value.rel,
          orderType: OrderType.MAKER,
          createdAt: entry.value.createdAt ~/ 1000,
          relAmount: (double.parse(entry.value.price) *
                  double.parse(entry.value.maxBaseVol))
              .toString(),
          uuid: entry.key));
    }
    this.orders = orders;
    _inOrders.add(this.orders);

    this.currentOrders = newOrders;
    _inCurrentOrders.add(this.currentOrders);
  }

  List<dynamic> orderSwaps = new List<dynamic>();
  StreamController<List<dynamic>> _orderSwapsController =
      StreamController<List<dynamic>>.broadcast();
  Sink<List<dynamic>> get _inOrderSwaps => _orderSwapsController.sink;
  Stream<List<dynamic>> get outOrderSwaps => _orderSwapsController.stream;

  void updateOrdersSwaps(int limit, String fromUuid) async {
    await updateOrders();
    // all orders update
    await swapHistoryBloc.updateSwaps(limit, fromUuid);
    // all swaps update

    //combine two list to one list dynamic
    this.orderSwaps.clear();
    this.orders.removeWhere((order) => order.cancelable = false);
    this.orderSwaps.addAll(this.orders);

    swapHistoryBloc.swaps.removeWhere((swap) =>
        swap.status == Status.SWAP_SUCCESSFUL ||
        swap.status == Status.TIME_OUT);
    this.orderSwaps.addAll(swapHistoryBloc.swaps);
    this.orderSwaps.sort((a, b) {
      if (a is Order && b is Order) {
        return a.createdAt.compareTo(b.createdAt);
      } else if (a is Swap && b is Order) {
        return a.result.myInfo.startedAt.compareTo(b.createdAt);
      } else if (a is Order && b is Swap) {
        return a.createdAt.compareTo(b.result.myInfo.startedAt);
      } else {
        return a.result.myInfo.startedAt.compareTo(b.result.myInfo.startedAt);
      }
    });
    print(this.orderSwaps);
  }

  Future<void> cancelOrder(String uuid) async {
    await mm2.cancelOrder(uuid);
    updateOrders();
  }
}
