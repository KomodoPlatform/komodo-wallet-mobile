import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:komodo_dex/screens/dex/orders/item_order.dart';

class ActiveOrders extends StatefulWidget {
  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  @override
  void initState() {
    ordersBloc.updateOrdersSwaps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
        initialData: ordersBloc.orderSwaps,
        stream: ordersBloc.outOrderSwaps,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.data != null && snapshot.data.isNotEmpty) {
            List<dynamic> orderSwaps = snapshot.data;
            orderSwaps = snapshot.data.reversed.toList();
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: orderSwaps.length,
              itemBuilder: (BuildContext context, int index) {
                if (orderSwaps[index] is Swap) {
                  return BuildItemSwap(
                      context: context, swap: orderSwaps[index]);
                } else if (orderSwaps[index] is Order) {
                  return ItemOrder(orderSwaps[index]);
                } else {
                  return Container();
                }
              },
            );
          } else {
            return Container(
              child:
                  const Center(child: Text('No orders, please go to trade.')),
            );
          }
        });
  }
}
