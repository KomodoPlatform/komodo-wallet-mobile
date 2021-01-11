import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:komodo_dex/screens/dex/orders/build_item_maker.dart';
import 'package:komodo_dex/screens/dex/orders/build_item_taker.dart';

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
                final dynamic item = orderSwaps[index];
                if (item is Swap) {
                  return BuildItemSwap(context: context, swap: item);
                } else if (item is Order) {
                  switch (item.orderType) {
                    case OrderType.MAKER:
                      return BuildItemMaker(item);
                    case OrderType.TAKER:
                      return BuildItemTaker(item);
                    default:
                      return SizedBox();
                  }
                } else {
                  return SizedBox();
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
