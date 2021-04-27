import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/orders_bloc.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/order.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:komodo_dex/screens/dex/orders/active_orders.dart';
import 'package:komodo_dex/screens/dex/orders/filters/filters.dart';
import 'package:komodo_dex/screens/dex/orders/filters/filters_button.dart';
import 'package:komodo_dex/screens/dex/orders/swap_history.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrdersTab _currentTab = OrdersTab.active;
  bool _showFilters = false;
  final _activeFilters = ActiveFilters();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 8),
            FiltersButton(
              activeFilters: _activeFilters,
              onPressed: () => setState(() => _showFilters = !_showFilters),
              isActive: _showFilters,
            ),
            Expanded(child: SizedBox()),
            FlatButton(
                onPressed: () {
                  setState(() {
                    _currentTab = OrdersTab.active;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).ordersActive + ' ',
                      style: TextStyle(
                          color: _currentTab == OrdersTab.active
                              ? Theme.of(context).accentColor
                              : null),
                    ),
                    _buildActiveOrdersNumber(),
                  ],
                )),
            FlatButton(
              onPressed: () {
                setState(() {
                  _currentTab = OrdersTab.history;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).ordersHistory + ' ',
                    style: TextStyle(
                        color: _currentTab == OrdersTab.history
                            ? Theme.of(context).accentColor
                            : null),
                  ),
                  _buildHistoryNumber(),
                ],
              ),
            ),
          ],
        ),
        if (_showFilters)
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top:
                          BorderSide(color: Theme.of(context).highlightColor))),
              padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Filters(),
            ),
          ),
        Flexible(
            child: _currentTab == OrdersTab.active
                ? ActiveOrders()
                : SwapHistory()),
      ],
    );
  }

  Widget _buildHistoryNumber() {
    return StreamBuilder<Iterable<Swap>>(
        stream: swapHistoryBloc.outSwaps,
        initialData: swapMonitor.swaps,
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
              color: _currentTab == OrdersTab.history
                  ? Theme.of(context).accentColor
                  : null,
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
            color: _currentTab == OrdersTab.active
                ? Theme.of(context).accentColor
                : null,
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
