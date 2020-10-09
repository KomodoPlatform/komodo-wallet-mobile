import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/history/swap_history.dart';
import 'package:komodo_dex/screens/dex/orders/active_orders.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrdersTab currentTab = OrdersTab.active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  setState(() {
                    currentTab = OrdersTab.active;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      // TODO(yurii): localization
                      'Active ',
                      style: TextStyle(
                          color: currentTab == OrdersTab.active
                              ? null
                              : Theme.of(context).accentColor),
                    ),
                    _buildActiveOrdersNumber(),
                  ],
                )),
            FlatButton(
              onPressed: () {
                setState(() {
                  currentTab = OrdersTab.history;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    // TODO(yurii): localization
                    'History ',
                    style: TextStyle(
                        color: currentTab == OrdersTab.history
                            ? null
                            : Theme.of(context).accentColor),
                  ),
                  _buildHistoryNumber(),
                ],
              ),
            ),
          ],
        ),
        Flexible(
            child: currentTab == OrdersTab.active
                ? ActiveOrders()
                : SwapHistory()),
      ],
    );
  }

  Widget _buildHistoryNumber() {
    return StreamBuilder<Iterable<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: syncSwaps.swaps,
        builder:
            (BuildContext context, AsyncSnapshot<Iterable<Swap>> snapshot) {
          if (!snapshot.hasData) return Container();

          final List<Swap> completed = snapshot.data
              .where((Swap item) =>
                  item.status == Status.SWAP_SUCCESSFUL ||
                  item.status == Status.SWAP_FAILED ||
                  item.status == Status.TIME_OUT)
              .toList();

          return Text(
            '(${completed.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: currentTab == OrdersTab.history
                  ? null
                  : Theme.of(context).accentColor,
            ),
          );
        });
  }

  Widget _buildActiveOrdersNumber() {
    return StreamBuilder<List<dynamic>>(
      initialData: ordersBloc.orderSwaps,
      stream: ordersBloc.outOrderSwaps,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) return Container();

        final List<dynamic> active = snapshot.data
            .where((dynamic item) => item is Order || item is Swap)
            .toList();

        return Text(
          '(${active.length})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: currentTab == OrdersTab.active
                ? null
                : Theme.of(context).accentColor,
          ),
        );
      },
    );
  }
}

enum OrdersTab {
  active,
  history,
}
