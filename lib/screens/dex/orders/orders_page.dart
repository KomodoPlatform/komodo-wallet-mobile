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
  final Map<OrdersTab, bool> _showFilters = {
    OrdersTab.active: false,
    OrdersTab.history: false,
  };
  final Map<OrdersTab, ActiveFilters> _activeFilters = {
    OrdersTab.active: ActiveFilters(),
    OrdersTab.history: ActiveFilters(),
  };
  final Map<OrdersTab, ScrollController> _scrollCtrl = {
    OrdersTab.active: ScrollController(),
    OrdersTab.history: ScrollController(),
  };

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
            _buildFiltersButton(),
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
        Flexible(
            child: _currentTab == OrdersTab.active
                ? ActiveOrders(
                    scrollCtrl: _scrollCtrl[OrdersTab.active],
                    showFilters: _showFilters[OrdersTab.active],
                    activeFilters: _activeFilters[OrdersTab.active],
                    onFiltersChange: (filters) {
                      setState(() {
                        _activeFilters[OrdersTab.active] = filters;
                      });
                    },
                  )
                : SwapHistory(
                    scrollCtrl: _scrollCtrl[OrdersTab.history],
                    showFilters: _showFilters[OrdersTab.history],
                    activeFilters: _activeFilters[OrdersTab.history],
                    onFiltersChange: (filters) {
                      setState(() {
                        _activeFilters[OrdersTab.history] = filters;
                      });
                    },
                  )),
      ],
    );
  }

  Widget _buildFiltersButton() {
    return FiltersButton(
      activeFilters: _activeFilters[_currentTab],
      onPressed: () {
        if (_scrollCtrl[_currentTab].offset > 0) {
          _scrollCtrl[_currentTab].jumpTo(0);
          if (!_showFilters[_currentTab]) {
            setState(() => _showFilters[_currentTab] = true);
          }
        } else {
          setState(
              () => _showFilters[_currentTab] = !_showFilters[_currentTab]);
        }
      },
      isActive: _showFilters[_currentTab],
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
