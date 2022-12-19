import 'package:flutter/material.dart';
import '../../../blocs/orders_bloc.dart';
import '../../../blocs/swap_history_bloc.dart';
import '../../../localizations.dart';
import '../../../model/order.dart';
import '../../../model/swap.dart';
import '../../../model/swap_provider.dart';
import '../../dex/orders/active_orders.dart';
import '../../dex/orders/filters/filters.dart';
import '../../dex/orders/filters/filters_button.dart';
import '../../dex/orders/swap_history.dart';

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildFiltersButton(),
              Expanded(child: SizedBox()),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentTab = OrdersTab.active;
                  });
                },
                style: TextButton.styleFrom(
                  primary: _currentTab == OrdersTab.active
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).ordersActive + ' ',
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: _currentTab == OrdersTab.active
                                ? Theme.of(context).colorScheme.secondary
                                : null,
                          ),
                    ),
                    _buildActiveOrdersNumber(),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentTab = OrdersTab.history;
                  });
                },
                style: TextButton.styleFrom(
                  primary: _currentTab == OrdersTab.history
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).ordersHistory + ' ',
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: _currentTab == OrdersTab.history
                                ? Theme.of(context).colorScheme.secondary
                                : null,
                          ),
                    ),
                    _buildHistoryNumber(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
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
      onPressed: () async {
        if (_scrollCtrl[_currentTab].offset > 0) {
          if (!_showFilters[_currentTab]) {
            setState(() => _showFilters[_currentTab] = true);
          }
          await Future<dynamic>.delayed(Duration(milliseconds: 100));
          _scrollCtrl[_currentTab].animateTo(
            _scrollCtrl[_currentTab].position.minScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
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
          if (!snapshot.hasData) return SizedBox();

          final List<Swap> completed = snapshot.data
              .where((Swap item) =>
                  item.status == Status.SWAP_SUCCESSFUL ||
                  item.status == Status.SWAP_FAILED ||
                  item.status == Status.TIME_OUT)
              .toList();

          return Text(
            '(${completed.length})',
            style: Theme.of(context).textTheme.button.copyWith(
                  color: _currentTab == OrdersTab.history
                      ? Theme.of(context).colorScheme.secondary
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
        if (!snapshot.hasData) return SizedBox();

        final List<dynamic> active = snapshot.data
            .where((dynamic item) => item is Order || item is Swap)
            .toList();

        return Text(
          '(${active.length})',
          style: Theme.of(context).textTheme.button.copyWith(
                color: _currentTab == OrdersTab.active
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                fontSize: 13,
                fontWeight: FontWeight.w400,
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
