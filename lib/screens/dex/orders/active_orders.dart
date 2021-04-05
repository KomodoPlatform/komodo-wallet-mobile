import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/screens/dex/orders/swap/build_item_swap.dart';
import 'package:komodo_dex/screens/dex/orders/maker/build_item_maker.dart';
import 'package:komodo_dex/screens/dex/orders/taker/build_item_taker.dart';
import 'package:komodo_dex/widgets/pagination.dart';

class ActiveOrders extends StatefulWidget {
  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  final _scrollCtrl = ScrollController();
  int _currentPage = 1;
  final int _perPage = 25;

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

            final int start = (_currentPage - 1) * _perPage;
            int end = start + _perPage;
            if (end > orderSwaps.length) end = orderSwaps.length;
            final List<Widget> orderSwapsWidget = orderSwaps
                .map((dynamic item) {
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
                    return Container();
                  }
                })
                .toList()
                .sublist(start, end);

            return SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPagination(orderSwaps),
                  ...orderSwapsWidget,
                  _buildPagination(orderSwaps),
                  SizedBox(height: 10),
                ],
              ),
            );
          } else {
            return Container(
              child:
                  const Center(child: Text('No orders, please go to trade.')),
            );
          }
        });
  }

  Widget _buildPagination(List<dynamic> orderSwaps) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Pagination(
        currentPage: _currentPage,
        total: orderSwaps.length,
        perPage: _perPage,
        onChanged: (int newPage) {
          setState(() => _currentPage = newPage);
          _scrollCtrl.jumpTo(0);
        },
      ),
    );
  }
}
